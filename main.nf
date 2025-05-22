#!/usr/bin/env nextflow

nextflow.enable.dsl=2

// Include modules
include { BCL2FASTQ }   from './modules/bcl2fastq.nf'
include { FASTQC }      from './modules/fastqc.nf'
include { MULTIQC }     from './modules/multiqc.nf'
include { STATS }       from './modules/stats.nf'
include { EXTRACT }     from './modules/extract.nf'
include { RETRIEVE }    from './modules/retrieve.nf'
include { SPLIT }       from './modules/split.nf'
include { COMBINE }     from './modules/combine.nf'
include { PAIR }        from './modules/pair.nf'

// Demultiplexing bcl files
workflow demultiplex_bcl_files {
    take: 
        cohorts
    
    main:
    // Convert bcl files to fastq
    cohorts
        | BCL2FASTQ
        | multiMap {
            fastq   : [ it[0], it[1] ]
            reports : [ it[0], it[2] ]
            stats   : [ it[0], it[3] ]
        }
        | set { bcl_out }
    
    // Split fastq files into determined and undetermined
    bcl_out.fastq
        | transpose
        | map { [
            it.first(),
            it.last().simpleName.split('_')[0] == 'Undetermined' ? 'Undetermined' : 'Determined',
            it.last().simpleName,
            it.last().simpleName.split('_')[3],
            it.last() 
        ] }
        | branch {
            undetermined : it[1] == 'Undetermined'
            determined   : it[1] != 'Undetermined'
        }
        | set { fastq }

    emit:
        determined   = fastq.determined
        undetermined = fastq.undetermined
        reports      = bcl_out.reports
        stats        = bcl_out.stats
}

// Extract reads from fastq files based on index sequences
workflow extract_by_index {
    take: 
        undetermined
        stats

    main:
    // Generate ranges channel
    ranges_ch = Channel.from( (1..params.nseq).step(params.chunk).collect { i -> 
            def end = Math.min(i + params.chunk - 1, params.nseq)
            [ i, end ]
        })

    undetermined
        | combine(ranges_ch)
        | SPLIT
        | set { fastq }

    // Get index sequences from fastq files
    stats
        | STATS
        | map { [ it.first(), it.last() ] }
        | splitCsv(header: true, sep: '\t')
        | map { cohort, row -> [cohort, [ Flowcell: row.Flowcell, LaneNumber: row.LaneNumber, IndexSequence: row.IndexSequence, ReadNumber: row.ReadNumber ]]}
        | unique
        | filter { it.last().ReadNumber.toInteger() > params.min_read } 
        | combine(fastq, by: 0)
        | EXTRACT
        | filter { it.last().size() > 0 }
        | RETRIEVE
        | filter { it.last().size() > 0 }
        | groupTuple(by: [0, 1, 2, 3])
        | COMBINE
        | groupTuple(by: [0, 1, 2])
        | ( params.paired ? PAIR : map { it } )
        | transpose
        | map { [ it[0], it[1], "${it[0]}.${it[1]}.${it[2]}.${it[3]}", it[3], it[4] ] }
        | set { retrieved }

    emit:
        retrieved = retrieved
}

// Check quality of fastq files
workflow check_quality {
    take: 
        fastq

    main:
    // Check quality of fastq files
    fastq
        | FASTQC
        | groupTuple(by: [0, 1])
        | MULTIQC
    // TODO: add seqkit fx2tab, and stats
    emit:
        qc = MULTIQC.out
}

workflow {
    // Conditional on step:
    //   - params.step == 'demultiplex' -> demultiplex_bcl_files | extract_by_index
    //   - params.step == 'extract'     -> extract_by_index
    //   - params.check                 -> check_quality

    if ( params.step == 'demultiplex' ) {
        // Requires: cohort, bcl, sample_sheet
        cohorts_ch = Channel.fromPath(params.cohorts)
            | splitCsv(header: true, sep: ',')
            | map { row -> [ row.cohort, file(row.bcl), file(row.sample_sheet) ] }
            | unique
        
        // Demultiplex and extract reads
        fastq            = demultiplex_bcl_files(cohorts_ch)
        fastq_retrieved  = extract_by_index(fastq.undetermined, fastq.stats)
    } else if ( params.step == 'extract' ) {
        // Requires: cohort, undetermined, stats, read
        // Generates: fastq.undetermined, fastq.stats
        undetermined = Channel.fromPath(params.cohorts)
            | splitCsv(header: true, sep: ',')
            | map { row -> [ row.cohort, 'Undetermined', row.undetermined.split('/|\\.')[1], row.read, file(row.undetermined) ] }

        stats = Channel.fromPath(params.cohorts)
            | splitCsv(header: true, sep: ',')
            | map { row -> [ row.cohort, file(row.stats) ] }

        // Extract reads from fastq files
        fastq_retrieved  = extract_by_index(undetermined, stats)
    }

    if ( params.check ) {
        // Check quality of fastq files
        // Adding fastq.determined if step == 'demultiplex'
        fastq_all = fastq_retrieved.retrieved 
            | ( params.step == 'demultiplex' ? concat(fastq.determined) : map { it })
        qc        = check_quality(fastq_all)
    }
}
