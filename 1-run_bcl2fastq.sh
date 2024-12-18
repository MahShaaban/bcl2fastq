#!/usr/bin/bash

#SBATCH --time=3:00:00
#SBATCH --partition=batch
#SBATCH --mem=10G
#SBATCH --cpus-per-task=10
#SBATCH --job-name=bcl2fastq
#SBATCH --output=logs/bcl2fastq_%j.log


# run this script from target output directory where demultiplexed FASTQ folder will be placed
# that way, log file is in that directory for future reference

# conda activate env with bcl2fastq v.2.20 or higher
source ${CONDA_PREFIX}/etc/profile.d/conda.sh
conda activate bcl2fastq

# example command to run script:
## sbatch 1-run_bcl2fastq.sh

# set folder paths
## folder paths should have no slash (/) at end
## runfolder is the parent directory containing the raw sequencer output. In the runfolder, there should be a RunParameters.xml
## - example: "/home/groups/MaxsonLab/input-data2/CUTTAG/241213_VH00711_179_AAG5GK5M5_CUTTAG/nondemultiplexed"
## output directory is the parent directory in which the subfolder containing demultiplexed FASTQs will be outputted
## - example: "/home/groups/MaxsonLab/input-data2/CUTTAG/241213_VH00711_179_AAG5GK5M5_CUTTAG/demultiplexed"
## samplesheet_path is path to the SampleSheet.csv file used by bcl2fastq
## note that for index 2 (i5 index) in samplesheet, you may need to use the reverse complement of the index sequence provided to you if the RunInfo.xml file in the runfolder says that the index is reverse complemented.
runfolder_directory=""
output_directory=""
samplesheet_path="SampleSheet.csv"


# echo current date/time into log file
echo -e "$(date)\n"

# echo bcl2fastq parameters to log file
echo "bcl2fastq parameters:"
echo "|-- Runfolder: ${runfolder_directory}"
echo "|-- Output directory: ${output_directory}"
echo "|-- Samplesheet: ${samplesheet_path}"


# run bcl2fastq
bcl2fastq -R ${runfolder_directory} \
-o ${output_directory} \
--sample-sheet ${samplesheet_path} \
--no-bgzf-compression \
--fastq-compression-level=9 \
--processing-threads ${SLURM_CPUS_PER_TASK}

# echo current date/time into log file
echo -e "$(date)\n"

exit
