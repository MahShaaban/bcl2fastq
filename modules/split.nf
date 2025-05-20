process SPLIT {
    tag "${cohort}:${sampleid}"

    label 'max'
    label 'seqkit'

    publishDir("${params.output_dir}/fastq_split", mode: 'copy')

    input:
    tuple val(cohort), val(sampleid), val(sample), path(fastq)

    output:
    tuple val(cohort), val(sampleid), val(sample),
          path("chunk_*")

    script:
    """
    #!/bin/bash
    seqkit split \
        --by-size ${params.chunk} \
        --by-size-prefix chunk_ \
        --out-dir . \
        --extension .gz \
        --threads ${task.cpus} \
        ${fastq}
    """
}