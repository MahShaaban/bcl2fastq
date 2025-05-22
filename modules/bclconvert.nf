process BCLCONVERT {
    tag "${cohort}"

    label 'simple'
    label 'bclconvert'

    publishDir("${params.output_dir}/fastq", mode: 'copy')

    input:
    tuple val(cohort), path(bcl_dir), path(sample_sheet)

    output:
    // samplename_sampleorder_lanenumber_readnumber_001.fastq.gz
    tuple val(cohort),
          path("*.fastq.gz"),
          path("Reports/*"),
          path("Logs/*")

    script:
    """
    #!/bin/bash
    bcl-convert \
        --force \
        --output-directory . \
        --bcl-input-directory ${bcl_dir} \
        --sample-sheet ${sample_sheet}
    """
}
