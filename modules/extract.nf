process EXTRACT {
    tag "${cohort}:${sampleid}"

    label 'simple'
    label 'seqkit'

    publishDir("${params.output_dir}/fastq_ids", mode: 'copy')

    input:
    tuple val(cohort), val(index),
          val(sampleid), val(sample), path(fastq)

    output:
    tuple val(cohort), val("${index.IndexSequence}"),
          path("${cohort}.${index.IndexSequence}.ids.txt")

    script:
    """
    #!/bin/bash
    seqkit seq ${fastq} --name -j ${task.cpus} | \
    grep ${index.IndexSequence} | \
    cut -d ' ' -f 1 \
    > ${cohort}.${index.IndexSequence}.ids.txt
    """
}