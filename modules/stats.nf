process STATS {
    tag "${cohort}"

    label 'simple'
    label 'rocker'

    publishDir("${params.output_dir}/stats", mode: 'copy')

    input:
    tuple val(cohort), path(stats)

    output:
    tuple val(cohort), path("${cohort}.known.tsv"), path("${cohort}.unknown.tsv")

    script:
    """
    #!/bin/bash
    parse_stats.R ${cohort} ${stats}
    """
}