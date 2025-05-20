process SEQKIT {
    tag "${cohort}:${sampleid}:${index}"

    label 'simple'
    label 'seqkit'

    publishDir("${params.output_dir}/fastq_retrieved", mode: 'copy')

    input:
    tuple val(cohort), val(index), path(ids),
          val(sampleid), val(sample), path(fastq)

    output:
    tuple val(cohort), val(sampleid), val("${cohort}.${sampleid}.${index}"),
          path("${cohort}.${sampleid}.${index}.fastq.gz")

    script:
    """
    #!/bin/bash
    # Get reads in fastq file
    seqkit grep \
    -j ${task.cpus} \
    -f ${ids} \
    ${fastq} \
    -o ${cohort}.${sampleid}.${index}.fastq.gz
    """
}