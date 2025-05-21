process COMBINE {
    tag "${cohort}:${sampleid}:${index}:${read}"

    label 'max'
    label 'seqkit'

    publishDir("${params.output_dir}/fastq_combined", mode: 'copy')

    input:
    tuple val(cohort), val(sampleid), val(index), val(read), val(from), val(to), path(fastq)

    output:
    tuple val(cohort), val(sampleid), val(index), val(read),
          path("${cohort}.${sampleid}.${index}.${read}.fastq.gz")

    script:
    """
    #!/bin/bash
	seqkit concate \
		--full ${fastq} \
		--threads ${task.cpus} \
		--out-file ${cohort}.${sampleid}.${index}.${read}.fastq.gz
    """
}