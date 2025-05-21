process FASTQC {
    tag "${cohort}:${sampleid}:${sample}:${read}"

    label 'simple'
    label 'fastqc'

    publishDir("${params.output_dir}/fastqc", mode: 'copy')

    input:
    tuple val(cohort), val(sampleid), val(sample), val(read), path(fastq)

    output:
    tuple val(cohort), val(sampleid), val(sample), val(read),
          path("${sample}_fastqc.html"), path("${sample}_fastqc.zip")

    script:
    """
    #!/bin/bash
    fastqc ${fastq}
    """
}
