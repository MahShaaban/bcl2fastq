#!/usr/bin/bash

#SBATCH --time=3:00:00
#SBATCH --partition=batch
#SBATCH --mem=100M
#SBATCH --cpus-per-task=1
#SBATCH --job-name=fastqc_wrapper
#SBATCH --output=logs/fastqc_wrapper_%j.log

# run this script from folder where run_bcl2fastq.sh was also run
# that way, log file is in same directory for future reference

# conda activate env with fastqc v.0.12 or higher
source ${CONDA_PREFIX}/etc/profile.d/conda.sh
conda activate fastqc

# example command to run script:
## sbatch 2-run_fastqc.sh

# set fastq_folder path and runtime parameters
## folder paths should have no slash (/) at end
## fastq folder(s) are where the R1 and R2 FASTQ files are stored
## - example: "/home/groups/MaxsonLab/input-data2/CUTTAG/241213_VH00711_179_AAG5GK5M5_CUTTAG/demultiplexed/241213_HCarlson_CUTTAG"
## outdir is relative path to where FastQC reports will be stored (default = "FastQC")
## nthreads is number of threads used to run FastQC for each FASTQ file
fastq_folder1=""
fastq_folder2=""
outdir="FastQC"
nthreads=1

# echo current date/time into log file
echo -e "$(date)\n"

# if output directory doesn't exist, then create it
if [ ! -d "$outdir" ]
then
	echo "Creating output directory: $outdir"
	mkdir -p $outdir
fi

# sbatch run fastqc for each fastq file, 
for file in $(find $fastq_folder1 -maxdepth 1 -name "*.gz")
do
	echo "$file"
	job_outfile="logs/fastqc/fastqc_%j.log"
	sbatch --partition=batch -o $job_outfile --job-name "fastqc" --time "02:00:00" --cpus-per-task=$nthreads --mem=4G --wait --wrap="fastqc -t $nthreads --outdir $outdir $file" &
done

# for file in $(find $fastq_folder2 -maxdepth 1 -name "*.gz")
# do
# 	echo "$file"
# 	job_outfile="logs/fastqc/fastqc_%j.log"
# 	sbatch --partition=batch -o $job_outfile --job-name "fastqc" --time "02:00:00" --cpus-per-task=$nthreads --mem=4G --wait --wrap="fastqc -t $nthreads --outdir $outdir $file" &
# done

# wait for spawned batch jobs to finish
wait

# echo current date/time into log file
echo -e "$(date)\n"

exit
