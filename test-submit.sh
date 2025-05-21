#!/bin/bash

#SBATCH -o test/test.out
#SBATCH -e test/test.err
#SBATCH -J test
#SBATCH -p master-worker
#SBATCH -t 120:00:00

# Setup test directory
mkdir -p test/ test/input
cd test/

# curl -o input/SampleSheet.csv https://raw.githubusercontent.com/nf-core/test-datasets/demultiplex/testdata/NovaSeq6000/SampleSheet.csv
# curl -o input/200624_A00834_0183_BHMTFYDRXX.tar.gz https://raw.githubusercontent.com/nf-core/test-datasets/demultiplex/testdata/NovaSeq6000/200624_A00834_0183_BHMTFYDRXX.tar.gz
# untar -xzf input/200624_A00834_0183_BHMTFYDRXX.tar.gz -C input/

# After running the workflow once in -profile test,
# cp results/Undetermined_S0_L001_R1_001.fastq.gz input/
# cp results/Stats.json input/

# Make inputs
echo -e "cohort,bcl,sample_sheet,undetermined,stats,read" > input/cohorts.info.csv
echo -e "pheno,input/200624_A00834_0183_BHMTFYDRXX,input/SampleSheet.csv,input/Undetermined_S0_L001_R1_001.fastq.gz,input/Stats.json,R1" >> input/cohorts.info.csv
echo -e "pheno,input/200624_A00834_0183_BHMTFYDRXX,input/SampleSheet.csv,input/Undetermined_S0_L001_R2_001.fastq.gz,input/Stats.json,R2" >> input/cohorts.info.csv

# Run nextflow
module load Nextflow

nextflow run ../main.nf \
    --output_dir ./results/ \
    -profile test_extract,local \
    -resume

# mv .nextflow.log nextflow.log
