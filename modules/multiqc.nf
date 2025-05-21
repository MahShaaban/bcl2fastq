process MULTIQC {
    tag "${cohort}:${sampleid}"

    label 'simple'
    label 'multiqc'

    publishDir("${params.output_dir}/multiqc", mode: 'copy')

    input:
    tuple val(cohort), val(sampleid), val(sample), val(read),
          path(html), path(zip)

    output:
    tuple val(cohort), val(sampleid),
          path("${cohort}.${sampleid}_multiqc_report.html"),
          path("${cohort}.${sampleid}_multiqc_report_data/*.{txt,log,json}")

    script:
    """
    #!/bin/bash
    multiqc . -i ${cohort}.${sampleid}
    """
}
