# bcl2fastq

This repo contains a workflow that takes sequencing output from an Illumina sequencer, uses bcl2fastq to demultiplex reads and convert them to FASTQ format, and runs basic quality control on the raw data.

## Part A: Setup

**NOTE:** Some of the setup instructions are tailored for working on Oregon Health and Science University's Linux-based high-performance computing cluster (ARC, formerly Exacloud). If you have access to another computing cluster, then some steps may need to be modified accordingly.


### 1. Create file/folder structure

This section is intended to help users create a consistent folder structure for data.

First, create a folder specifically for your dataset. Within this main folder, create two subfolders: (1) for demultiplexed data and (2) for non-demultiplexed data coming from the sequencer (example folder structure below).

Example folder structure:

```bash
EXP250101JM_CUTTAG
├── demultiplexed
└── nondemultiplexed
```

On the command line, navigate into the main dataset folder, then clone this Github repo into the `demultiplexed` folder:

```bash
# navigate to the main dataset folder
cd /path/to/main/dataset/folder

# git clone repo into demultiplexed folder
git clone https://github.com/maxsonBraunLab/bcl2fastq.git demultiplexed
```

Example file structure after git cloning repo:

```bash
EXP250101JM_CUTTAG
├── demultiplexed
│   ├── 1-run_bcl2fastq.sh
│   ├── 2-run_fastqc.sh
│   ├── 3-run_multiqc.sh
│   ├── README.md
│   ├── SampleSheet.csv
│   └── envs
└── nondemultiplexed
```


### 2. Transfer sequencing data

If you have limited access to the original raw sequencer output, then you can make a temporary copy of it in the `nondemultiplexed` folder.

If you do not have access to the original sequencer output, then you can request that someone in the lab with access copy the data for you. They may also need to add group-level read/write permissions to the main dataset folders so that you are able to run the demultiplexing and generate necessary files.


### 3. Prepare SampleSheet.csv

In the `SampleSheet.csv`, you will need to change the RunName, Read1Cycles, Read2Cycles, Index1Cycles, Index2Cycles.

The number of read and index cycles can be found in the `RunParameters.xml` file inside the non-demultiplexed folder outputted by the sequencer. 

You will also need to change Data columns such as Sample_ID, Sample_Project, index, and index2.

* __Sample_ID__: A unique name given to each sample. No spaces or unusual characters allowed, but dashes (-) and underscores (_) are permitted.
	- Examples: 
		- SETBP1-D868N_1_H3K4me3
		- SETBP1-D868N_2_H3K4me3
		- SETBP1-D868N_3_H3K4me3
		- LUC_1_H3K4me3
		- LUC_2_H3K4me3
		- LUC_3_H3K4me3

* __Sample_Project__: A descriptive project name. No spaces or unusual characters allowed, but dashes (-) and underscores (_) are permitted. This name will also be used for the folder in which the demultiplexed FASTQ files will be outputted. 
	- Example: 230724_MT_MH_CUTnTag (YYMMDD_initials_seqtype)

	If you have multiple separate experiments that were pooled together, then you can separate the FASTQ files for each experiment into a separate folder by specifying different project names.

* __index__: Index 1 (i7) sequences
* __index2__: Index 2 (i5) sequences, if used. If Index2Cycles is set to 0 and no unique i5 indexes were used in sequencing libraries, then exclude this column from samplesheet. If i5 indexes were used, then note that you may need to use the reverse complement of the index sequence provided to you if the `RunInfo.xml` file in the non-demultiplexed folder says that the index is reverse complemented.


### 4. Set runtime parameters in scripts

You will need to set a few runtime paths/parameters as described in the instructions in each of the following scripts:

* __1-run_bcl2fastq.sh__: Set the `runfolder_directory` and `output_directory` paths
* __2-run_fastqc.sh__: Set the `fastq_folders_array` path(s)
* __3-run_multiqc.sh__: Set the `report_title`


### 5. Install Conda environments

Conda environments for bcl2fastq and QC tools can be created from specifications in the YML/YAML files in the `envs` folder. If you don't have these Conda environments set up yet, then you will need to create them. To create a Conda environment from a YML/YAML file, you can run:

```bash
conda env create -f <path/to/your/environment_specs.yml>
```


## Part B: Run workflow

On the command line, navigate into the `demultiplexed` folder. 

To run the demultiplexing script with ARC computing resources, you can submit a job to SLURM:

```bash
sbatch 1-run_bcl2fastq.sh
```

You can check the job log file to see if demultiplexing ran successfully. If it did, then you can proceed to QC report generation.

First, run FastQC to generate QC reports for each FASTQ file:

```bash
sbatch 2-run_fastqc.sh
```

Then, run MultiQC to aggregate all QC info and demultiplexing stats into a single HTML report:

```bash
sbatch 3-run_multiqc.sh
```

After checking the QC reports and verifying that the demultiplexing stats look fine, you can remove the `nondemultiplexed` folder if you have limited data storage space.
