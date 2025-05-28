process SEQSTATS {
    tag "${cohort}:${sampleid}:${sample}:${read}"

    label 'simple'
    label 'seqkit'

    publishDir("${params.output_dir}/seqstats", mode: 'copy')

    input:
    tuple val(cohort), val(sampleid), val(sample), val(read), path(fastq)

    output:
    tuple val(cohort), val(sampleid), val(sample), val(read),
          path("${sample}_seqstats.txt")

    script:
    """
    #!/bin/bash
    seqkit stats ${fastq} > ${sample}_seqstats.txt
    """
}
