process SPLIT {
    tag "${cohort}:${sampleid}:chunk_${from}-${to}"

    label 'max'
    label 'seqkit'

    publishDir("${params.output_dir}/fastq_split", mode: 'copy')

    input:
    tuple val(cohort), val(sampleid), val(sample), path(fastq),
          val(from), val(to)

    output:
    tuple val(cohort), val(sampleid), val(sample), val(from), val(to),
          path("chunk_${from}-${to}.fastq.gz")

    script:
    """
    #!/bin/bash
    seqkit range \
        -r ${from}:${to} \
        -j ${task.cpus} \
        ${fastq} \
        -o chunk_${from}-${to}.fastq.gz
    """
}