# TCR2Rep Pipeline 

### Pipeline description :  
The pipeline processes raw TCR sequences and exports a data table containing all IgBlast annotation, clonal assignment and clonal frequency data (for the 10 biggest clone).
The pipeline also performs bioinformatic analyses, such as: clonal size distribution ,  CDR3 lengths distribution and VDJ segments frequencies.

## Installation (manual): 

TCR2Rep for linux - look README_linux.md

TCR2Rep for windows - look README_win64.md

## **Run TCR2Rep pip** 

First, Operate TCR2Rep pip enviroment by typing:

```cd TCR2Rep```

```conda activate TCR2Rep```

- For windows 64x  - run the following command line:
### ```bash <your/tcR2Rep_pipeline_folder/path>TCR2Rep_pipeline_win64.bash <fastq_file_path> <sample_name> <length_threshold> <quality_threshold> <output_path> <igblastn_path> <igblast_dir_path> <TCR2Rep_pipeline_folder_path> ```

- For linux - run the following command line:
### ```bash <your/tcR2Rep_pipeline_folder/path>TCR2Rep_pipeline_linux.bash <fastq_file_path> <sample_name> <length_threshold> <quality_threshold> <output_path> <igblastn_path> <igblast_dir_path> <TCR2Rep_pipeline_folder_path> ```

|Argument number|Argument|Description|
|--|:----|:------|
|1 |<fastq_file_path>|A file that contains all TCR sequences|
|2 |<sample_name>|A unique sample name of your choice to be added to the output files|
|3 |<length_threshold>|Select a minimum length threshold for filtering [Usually - 240]|
|4 |<quality_threshold>|Select a minimum quality threshold for filtering [Usually - 240]|
|5 |<output_path>|Choose directory path for the output files|
|6 |<igblastn_path>|igblastn path (Usually found in "bin" folder of igblast program|
|7 |<igblast_directory_path>|igblast directory path|
|8 |<tcR2Rep_pipeline_folder_path>|tcR2Rep folder directory [where you just created the folder in your system|

**Run Example:**

```bash "TCR2Rep_pipeline_win64.bash" AL11_S1_L001_R1_001.fastq AL11 240 25 ~\TCR2Rep\ <your/igblastn_direcrory/path>\bin\igblastn.exe <your/igblastn_direcrory/path> <your/tcR2Rep_pipeline_folder/path>```

## **Clones Tracking Analysis**
This analysis allow you track clone size of overlap clones between 4 samples or between T-care treatment and 4 samples.

A. **First**, Run this commands to get a clones tracking tables:
```cd <your/Clones_Tracking_Scripts_folder/path>```

1. All clones tracking - in all samples and T CARE treatment.

Inputs: XXX_after_annotation.tsv files of the treatment and all the samples.

* ```Tracking_overlapping_clones_percent.R treatment_after_annotation.tsv sample1_after_annotation.tsv sample2_after_annotation.tsv sample3_after_annotation.tsv sample4_after_annotation.tsv```

2. All clones tracking – just in samples.
 
 Inputs: XXX_after_annotation.tsv files of all the samples.

* ```Tracking_overlapping_clones_percent.R treatment_after_annotation.tsv sample1_after_annotation.tsv sample2_after_annotation.tsv sample3_after_annotation.tsv sample4_after_annotation.tsv ```

3. Just common clones tracking - in all samples and T CARE treatment.

Inputs: XXX_after_annotation.tsv files of the treatment and all the samples.

* ```Tracking_overlapping_clones_percent.R treatment_after_annotation.tsv sample1_after_annotation.tsv sample2_after_annotation.tsv sample3_after_annotation.tsv sample4_after_annotation.tsv ```

B. **Next**, Run this commands to create Clones Tracking graphs:

1.All clones tracking - in all samples and T CARE treatment.

Inputs: The outputs files from the previous step [all the excel tables].

* ```Clones_tracking_graph.R XXX_ALL_Clones_Tracking.xlsx XXX_Just_Samples_Clones_Tracking.xlsx XXX_Common_Clones_Tracking.xlsx```

2.All clones tracking – just in samples. [for better visualization]

Inputs: The outputs files from the previous step [all the excel tables].

* ```Clones_tracking_graph[just_samples].R XXX_ALL_Clones_Tracking.xlsx XXX_Just_Samples_Clones_Tracking.xlsx XXX_Common_Clones_Tracking.xlsx```

