#!/usr/bin/bash

#SBATCH --time=2:00:00
#SBATCH --partition=batch
#SBATCH --mem=500M
#SBATCH --cpus-per-task=1
#SBATCH --job-name run_multiqc
#SBATCH --output=logs/run_multiqc_%j.log

# This script runs multiqc to aggregate FastQC and other BCL sequencing info present in the folders of a sequencing experiment downloaded from Nix or another lab's sequencer. 

# This script should be run from the parent folder of the FastQC, Reports, and Stats folders for a sequencing run.

# conda activate multiqc environment with v.1.12 or higher
source ${CONDA_PREFIX}/etc/profile.d/conda.sh
conda activate multiqc

# set runtime parameters
## report title is just a name you want to give the experiment
## - example: "241213_HCarlson_CUTTAG"
report_title=""
output_dir="MultiQC" #create output directory within current working directory 

multiqc -i $report_title -o $output_dir FastQC Reports Stats

exit
