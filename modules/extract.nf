process EXTRACT {
    tag "${cohort}:${sampleid}:${index.index1}+${index.index2}:${read}:${from}-${to}"

    label 'simple'
    label 'seqkit'

    publishDir("${params.output_dir}/fastq_ids", mode: 'copy')

    input:
    tuple val(cohort), val(index),
          val(sampleid), val(sample), val(read), val(from), val(to), path(fastq)

    output:
    tuple val(cohort), val(sampleid), val("${index.index1}+${index.index2}"), val(read), val(from), val(to),
		  path(fastq),
		  path("${cohort}.${sampleid}.${index.index1}+${index.index2}.${read}_chunk_${from}-${to}.ids.txt")

    script:
    """
    #!/bin/bash
    # Get read ids in fastq file based on index
    seqkit seq ${fastq} --name -j ${task.cpus} | \
    grep ${index.index1}+${index.index2} | \
    cut -d ' ' -f 1 \
    > ${cohort}.${sampleid}.${index.index1}+${index.index2}.${read}_chunk_${from}-${to}.ids.txt
    """
}