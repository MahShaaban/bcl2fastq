process SPLIT {
    tag "${cohort}:${sampleid}:${read}:${from}-${to}"

    label 'max'
    label 'seqkit'

    publishDir("${params.output_dir}/fastq_split", mode: 'copy')

    input:
    tuple val(cohort), val(sampleid), val(sample), val(read), path(fastq),
          val(from), val(to)

    output:
    tuple val(cohort), val(sampleid), val(sample), val(read), val(from), val(to),
          path("${read}_chunk_${from}-${to}.fastq.gz")

    script:
    """
    #!/bin/bash
    seqkit range \
        -r ${from}:${to} \
        -j ${task.cpus} \
        ${fastq} \
        -o ${read}_chunk_${from}-${to}.fastq.gz
    """
}