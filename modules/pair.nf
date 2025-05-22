process PAIR {
    tag "${cohort}:${sampleid}:${index}"

    label 'max'
    label 'seqkit'

    publishDir("${params.output_dir}/fastq_paired", mode: 'copy')

    input:
    tuple val(cohort), val(sampleid), val(index), val(read), path(fastq)

    output:
    tuple val(cohort), val(sampleid), val(index), val(read),
          path("${cohort}.${sampleid}.${index}.{${read.join(',')}}.fastq.gz")

    script:
    """
    #!/bin/bash
    seqkit pair \
        --save-unpaired \
        --read1 ${fastq.join(',').split(',')[0]} \
        --read2 ${fastq.join(',').split(',')[1]} \
		--threads ${task.cpus}
    """
}
