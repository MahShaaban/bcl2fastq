process BCL2FASTQ {
    tag "${cohort}"

    label 'simple'
    label 'bcl2fastq'

    publishDir("${params.output_dir}/fastq", mode: 'copy')

    input:
    tuple val(cohort), path(bcl_dir), path(sample_sheet)

    output:
    tuple val(cohort), path("*.fastq.gz"), path("Reports"), path("Stats/Stats.json")

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
        --writing-threads ${task.cpus}
    """
}
