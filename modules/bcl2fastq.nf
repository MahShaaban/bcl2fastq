process BCL2FASTQ {
    tag "${cohort}"

    label 'simple'
    label 'bcl2fastq'

    publishDir("${params.output_dir}/fastq", mode: 'copy')

    input:
    tuple val(cohort), path(bcl_dir), path(sample_sheet)

    output:
    // samplename_sampleorder_lanenumber_readnumber_001.fastq.gz
    tuple val(cohort),
          path("*.fastq.gz"),
          path("${cohort}_reports"),
          path("${cohort}_interop"),
          path("${cohort}_stats/Stats.json")

    script:
    """
    #!/bin/bash
    bcl2fastq \
        --runfolder-dir ${bcl_dir} \
        --input-dir ${bcl_dir}/Data/Intensities/BaseCalls/L008 \
        --sample-sheet ${sample_sheet} \
        --adapter-stringency ${params.stringency} \
        --fastq-compression-level ${params.compression} \
        --barcode-mismatches ${params.mismatches} \
        --processing-threads ${task.cpus} \
        --loading-threads 4 \
        --writing-threads 4 \
        --ignore-missing-bcls \
        --find-adapters-with-sliding-window \
        --no-bgzf-compression \
        --stats-dir ${cohort}_stats \
        --reports-dir ${cohort}_reports \
        --interop-dir ${cohort}_interop \
        --output-dir .
    """
}
