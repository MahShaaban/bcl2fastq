#!/usr/bin/env nextflow

nextflow.enable.dsl=2

// Include modules
include { FASTQC }      from '../modules/fastqc.nf'
include { SEQSTATS }    from '../modules/seqstats.nf'
include { MULTIQC }     from '../modules/multiqc.nf'

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
