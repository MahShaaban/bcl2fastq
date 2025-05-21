process BCL2FASTQ {
    tag "${cohort}"

    label 'simple'
    label 'bcl2fastq'

    publishDir("${params.output_dir}/fastq", mode: 'copy')

    input:
    tuple val(cohort), path(bcl_dir), path(sample_sheet)

    output:
    tuple val(cohort),
          path("*_*_*_R1_001.fastq.gz"), // samplename_sampleorder_lanenumber_readnumber_001.fastq.gz
          path("${cohort}_reports"),
          path("${cohort}_stats/Stats.json")

    script:
    """
    #!/bin/bash
    bcl2fastq \
        -R ${bcl_dir} \
        -o . \
        --sample-sheet ${sample_sheet} \
        --adapter-stringency ${params.stringency} \
        --fastq-compression-level ${params.compression} \
        --barcode-mismatches ${params.mismatches} \
        --ignore-missing-bcls \
        --find-adapters-with-sliding-window \
        --no-bgzf-compression \
        --loading-threads ${task.cpus} \
        --processing-threads ${task.cpus} \
        --writing-threads ${task.cpus} \
        --stats-dir ${cohort}_stats \
        --reports-dir ${cohort}_reports
    """
}
