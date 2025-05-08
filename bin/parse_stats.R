#!/usr/bin/env Rscript

# Capture command-line arguments
args <- commandArgs(trailingOnly = TRUE)

cohort  <- args[1]
stats   <- args[2]

# stats <- "/data/rds/DGE/DUDGE/MOPOPGEN/mahmed03/pipelines/demultiplex-bcl-files/test/results/fastq/Stats/Stats.json"

# Read the JSON file
stats_data <- jsonlite::fromJSON(stats)

# Runs
run <- tibble::as_tibble(stats_data[c('Flowcell', 'RunId', 'RunNumber')])

# Lanes
lanes <- dplyr::bind_cols(
  tibble::as_tibble(stats_data$ReadInfosForLanes['LaneNumber']),
  tibble::as_tibble(stats_data$ReadInfosForLanes['ReadInfos'])
)
lanes <- tidyr::unnest(lanes)

# ConversionResults
res <- dplyr::bind_cols(
  tibble::as_tibble(stats_data$ConversionResults['LaneNumber']),
  tibble::as_tibble(stats_data$ConversionResults['DemuxResults'])
)

res <- tidyr::unnest(res)
res <- tidyr::unnest(res)
res <- tidyr::unnest(res)

und <- dplyr::bind_cols(
  tibble::as_tibble(stats_data$ConversionResults['LaneNumber']),
  SampleId = 'Undetermined', SampleName = 'Undetermined',
  tibble::as_tibble(stats_data$ConversionResults['Undetermined'])
)
und <- tidyr::unnest(und)
und <- tidyr::unnest(und)

res <- dplyr::bind_rows(res, und)

known <- dplyr::bind_cols(run, lanes)
known <- dplyr::left_join(known, res)

readr::write_tsv(known, paste(cohort, 'known', 'tsv', sep = '.'))

# UnknownBarcodes
barcodes <- tibble::tibble(
  LaneNumber = stats_data$UnknownBarcodes$Lane,
  IndexSequence = names(stats_data$UnknownBarcodes$Barcodes),
  ReadNumber = unname(unlist(stats_data$UnknownBarcodes$Barcodes))
)

unknown <- dplyr::bind_cols(run, lanes)
unknown <- dplyr::inner_join(unknown, barcodes)

readr::write_tsv(unknown, paste(cohort, 'unknown', 'tsv', sep = '.'))
