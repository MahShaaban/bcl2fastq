#!/usr/bin/env nextflow

nextflow.enable.dsl=2

// Include modules
include { BCLCONVERT }  from './modules/bclconvert.nf'
include { FASTQC }      from './modules/fastqc.nf'
include { SEQSTATS }    from './modules/seqstats.nf'
include { MULTIQC }     from './modules/multiqc.nf'
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
        | BCLCONVERT
        | multiMap {
            fastq   : [ it[0], it[1] ]
            reports : [ it[0], it[2] ]
            logs    : [ it[0], it[3] ]
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
    
    bcl_out.reports
        | transpose 
        | branch { 
            known:   it.last().simpleName == 'Demultiplex_Stats'
            unknown: it.last().simpleName == 'Top_Unknown_Barcodes'
        }
        | set { barcodes }

    emit:
        determined   = fastq.determined
        undetermined = fastq.undetermined
        reports      = bcl_out.reports
        logs         = bcl_out.logs
        known_barcodes   = barcodes.known
        unknown_barcodes = barcodes.unknown
}

// Extract reads from fastq files based on index sequences
workflow extract_by_index {
    take: 
        undetermined
        unkown

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
    unkown
        | splitCsv(header: true, sep: ',')
        | map { cohort, row -> [cohort, [ lane: row.Lane, index1: row.index, index2: row.index2, nread: row.'# Reads', punknown: row.'% of Unknown Barcodes', pall: row.'% of All Reads' ]]}
        | unique
        | filter { it.last().nread.toInteger() > params.min_read } 
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
        | map { [ it[0], it[1], "${it[4].name.replaceAll(/\.fastq\.gz$/, '')}", it[3], it[4] ] }
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
        | set { multiqc }

    // seqkit stats
    fastq
        | SEQSTATS
        | map { it.last() }
        | collectFile (
            keepHeader: true,
            storeDir: "${params.output_dir}/seqstats",
            name: "seqstats_summary.tsv"
        )
        | set { seqstats }

    emit:
        multiqc
        seqstats
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
        fastq_retrieved  = extract_by_index(fastq.undetermined, fastq.unknown_barcodes)
    } else if ( params.step == 'extract' ) {
        // Requires: cohort, undetermined, stats, read
        // Generates: fastq.undetermined, fastq.stats
        undetermined = Channel.fromPath(params.cohorts)
            | splitCsv(header: true, sep: ',')
            | map { row -> [ row.cohort, 'Undetermined', row.undetermined.split('/|\\.')[1], row.read, file(row.undetermined) ] }

        unknown = Channel.fromPath(params.cohorts)
            | splitCsv(header: true, sep: ',')
            | map { row -> [ row.cohort, file(row.unknown) ] }

        // Extract reads from fastq files
        fastq_retrieved  = extract_by_index(undetermined, unknown)
    }

    if ( params.check ) {
        // Check quality of fastq files
        // Adding fastq.determined if step == 'demultiplex'
        fastq_all = fastq_retrieved.retrieved 
            | ( params.step == 'demultiplex' ? concat(fastq.determined) : map { it })
        qc        = check_quality(fastq_all)
    }
}
