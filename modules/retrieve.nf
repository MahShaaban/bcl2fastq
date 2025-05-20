process RETRIEVE {
    tag "${cohort}:${sampleid}:${index}:chunk_${from}-${to}"

    label 'simple'
    label 'seqkit'

    publishDir("${params.output_dir}/fastq_retrieved", mode: 'copy')

    input:
    tuple val(cohort), val(sampleid), val(index), val(from), val(to),
          path(fastq), path(fastq_ids)

    output:
    tuple val(cohort), val(sampleid), val(index), val(from), val(to),
          path("${cohort}.${sampleid}.${index}.chunk_${from}-${to}.fastq.gz")

    script:
    """
    #!/bin/bash
	# Extract reads from fastq file based on id
	seqkit grep \
    -j ${task.cpus} \
    -f ${fastq_ids} \
    ${fastq} \
    -o ${cohort}.${sampleid}.${index}.chunk_${from}-${to}.fastq.gz
    """
}