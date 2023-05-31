# TCR2Rep Pipeline (for win64)

### Pipeline description :  
The pipeline processes raw TCR sequences and exports a data table containing all IgBlast annotation, clonal assignment and clonal frequency data (for the 10 biggest clone).
The pipeline also performs bioinformatic analyses, such as: clonal size distribution ,  CDR3 lengths distribution and VDJ segments frequencies.

## Installation (manual): 
1. **Download** and Install the latest version of **Anaconda** from here: 

   https://www.anaconda.com/download

2. From the Start menu, search for and **open "Anaconda Prompt"**.
3. From "Anaconda Prompt" **install git** by typing: 

   ```conda install -c anaconda git```

4. From "Anaconda Prompt" **download TCR2Rep pipeline** scripts by typing: 

   ```git clone https://github.com/morhavap/TCR2Rep_win64.git```

5. Get into "TCR2Rep_win64" folder: ```cd TCR2Rep_win64```
6. Create the **environment for TCR2Rep** in "Anaconda Prompt" by typing:	

   ```conda env create -f TCR2Rep.yml ```

7. Then opreate the enviroment:

   ```conda activate TCR2Rep```

8. Run this commands at "Anaconda Prompt":
   
   -	Add bash cmd environment:

    ```conda install m2-base``` 

   - Add PERL cmd environment:

    ```conda install -c anaconda perl```

   -	Add seqkit package:

    ```conda install -c derkevinriehl seqkit```

9. download and **install IGBlast** for windows from here: 

   https://ncbi.github.io/igblast/cook/How-to-set-up.html

   (Important - Save your IgBlast download directory. 

   This is usually saved under a folder "C:\Program Files\NCBI")

   Move "igblast-1.21.0 " folder into "TCR2Rep" folder.

   (you can find "TCR2Rep" path by typing: "pwd" in "Anaconda Prompt").

10. Download **Imgt database**: (You can get a more extensive explanation here - https://www.imgt.org/vquest/refseqh.html#VQUEST.)
     
     a.	At "igblast-1.21.0 " folder create new folder with the name – "database" by typing:
      
      ```mkdir database```
      
      ```cd databas```
   
     b.	Create 3 new txt file at "database" folder. (right button -> new -> text document)
        Save the files with this names: "Human_TRV","Human_TRD","Human_TRJ".
     
     c.	Go here - https://www.imgt.org/vquest/refseqh.html#VQUEST, and copy all Human v genes of TCR (i.e. -  TRAV, TRBV, TRGV, TRDV) into "Human_TRV" file (one after the other), all D genes of TCR into " Human_TRD" file and all J genes of TCR into "Human_TRJ" file. 
    
    d.	Now, run this commands for each file to filter out duplicate sequences and prepare the files to igblast: (change just the gene segment V\D\J in the filename)
       
       ```seqkit rmdup -s < Human_TRV > human_TRV_filtered```
       
       ```<your_path_to_bin_dir>/edit_imgt_file.pl human_TRV_filtered > "human_TRV_igblast"```
       
       ```<your_path_to_bin_dir>/makeblastdb -parse_seqids -dbtype nucl -in "human_TRV_igblast"```

        Note: "database" folder contains IMGT VDJ TCR database. It is important to update this folder once in a while according to the changes published here. 

## **Run TCR2Rep pip** 

Typing at "Anaconda Prompt":

```cd TCR2Rep_win64```

```conda activate TCR2Rep```

#### ```bash <your/tcR2Rep_pipeline_folder/path>TCR2Rep_pipeline.bash <fastq_file_path> <sample_name> <length_threshold> <quality_threshold> <output_path> <igblastn_path> <igblast_dir_path> <TCR2Rep_pipeline_folder_path> ```

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

```bash "TCR2Rep_pipeline_[win64].bash" AL11_S1_L001_R1_001.fastq AL11 240 25 C:\Users\user\TCR2Rep_win64\ C:\Users\user\TCR2Rep_win64\NCBI\igblast-1.21.0\bin\igblastn.exe C:\Users\user\TCR2Rep_win64\NCBI\igblast-1.21.0 C:\Users\user\TCR2Rep_win64```



