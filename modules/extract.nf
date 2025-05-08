process EXTRACT {
    tag "${cohort}:${sampleid}"

    label 'simple'

    publishDir("${params.output_dir}/fastq_ids", mode: 'copy')

    input:
    tuple val(cohort), val(sampleid), val(sample), path(fastq)

    output:
    tuple val(cohort), val(sampleid), val(sample), path(fastq),
          path("${cohort}.${sampleid}.ids.txt")

    script:
    """
    #!/bin/bash
    zgrep '^@' ${fastq} > ${cohort}.${sampleid}.ids.txt
    """
}