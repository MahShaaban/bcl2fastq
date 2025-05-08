process SEQKIT {
    tag "${cohort}:${index.IndexSequence}"

    label 'simple'
    label 'seqkit'

    publishDir("${params.output_dir}/fastq_retrieved", mode: 'copy')

    input:
    tuple val(cohort), val(sampleid), val(sample), path(fastq), path(ids), val(index)

    output:
    tuple val(cohort), val(sampleid), val("${cohort}.${index.IndexSequence}"),
          path("${cohort}.${index.IndexSequence}.fastq.gz")

    script:
    """
    #!/bin/bash
    # List read ids in fastq file 
    cat ${ids} | \
    grep ${index.IndexSequence} | \
    cut -d ' ' -f1 \
    > ${cohort}.${index.IndexSequence}.ids.txt

    # List reads in fastq file
    seqkit grep \
    -f ${cohort}.${index.IndexSequence}.ids.txt \
    ${fastq} \
    -o ${cohort}.${index.IndexSequence}.fastq.gz

    # Count number of reads in fastq file
    n_reads=\$(wc -l ${cohort}.${index.IndexSequence}.ids.txt)
    """
}