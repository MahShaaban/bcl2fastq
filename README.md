# bcl2fastq

This repo contains a workflow that takes sequencing output from an Illumina sequencer, uses bcl2fastq to demultiplex reads and convert them to FASTQ format, and runs basic quality control.

## Data Prep

### SampleSheet.csv

In the `SampleSheet.csv`, you will need to change the RunName, Read1Cycles, Read2Cycles, Index1Cycles, Index2Cycles.

The number of read and index cycles can be found in the `RunParameters.xml` file inside the non-demultiplexed folder outputted by the sequencer. 

You will also need to change Data columns such as Sample_ID, Sample_Project, index, and index2.

* __Sample_ID__: a unique name given to each sample. 
* __Sample_Project__: a descriptive project name (no spaces or unusual characters). This name will also be used for the folder in which the demultiplexed FASTQ files will be outputted. 
	- Example: 230724_MT_MH_CUTnTag (YYMMDD_initials_seqtype)
* __index__: Index 1 (i7) sequences
* __index2__: Index 2 (i5) sequences, if used. If Index2Cycles is set to 0 and no unique i5 indexes were used in sequencing libraries, then exclude this column from samplesheet. If i5 indexes were used, then note that you may need to use the reverse complement of the index sequence provided to you if the `RunInfo.xml` file in the non-demultiplexed folder says that the index is reverse complemented.
