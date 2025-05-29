#!/usr/bin/env nextflow

nextflow.enable.dsl=2

// Include modules
include { demultiplex_bcl_files }   from './subworkflows/demultiplex_bcl_files.nf'
include { extract_by_index }        from './subworkflows/extract_by_index.nf'
include { check_quality }           from './subworkflows/check_quality.nf'

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
