#!/bin/bash
# ---------TCR pipeline------------------
# Author:  Mor Hava Pereg
# Date:    07.05.2023
#if need do dos2unix "/home/mor/TCR_pipeline/Run_all_TCR_pip.bash"
echo
echo
echo _____________***-TCR2Rep Pipeline-***_______________
echo
echo
echo "-----------------Run Detail:---------------------"
#echo "Total arguments : $#"
echo "Fastq file path = $1"
echo "Sample name = $2"
echo "Length thresould = $3"
echo "Quality thresould = $4"
echo "Output path = $5"
echo "IgBlastn path = $6"
echo "IgBlast dir path = $7"
echo "TCR2Rep dir path = $8"
echo
cd $5
mkdir -p $2
echo
echo
echo ----------------Filter by length--------------------
python $8\\Filter_by_Length.py $1 $2 $3 $5\\$2
echo -------------Filter by length- DONE-----------------
echo
echo
echo ----------------Filter by quality--------------------
python $8\\Filter_by_Quality.py $5\\$2\\$2_length-pass.fastq $2 $4 $5\\$2
echo -------------Filter by quality- DONE-----------------
echo
echo
echo ----------------Convert fastq to fasta...------------
sed -n '1~4s/^@/>/p;2~4p' $5\\$2\\$2_quality-pass.fastq > $5\\$2\\$2_quality-pass.fasta
echo
echo
echo -----------------Annotation--------------------------
cd $7
#cd /home/mor/TCR_Pipeline_old/ncbi-igblast-1.20.0/
#run igblastn on imgt database -  need fasta file format
#export $IGDATA="/home/mor/TCR_Pipeline_old/ncbi-igblast-1.20.0/internal_data/"
$6 -germline_db_V database/imgt_human_TRV_igblast -germline_db_J database/imgt_human_TRJ_igblast -germline_db_D database/imgt_human_TRD_igblast -organism human -query $5\\$2\\$2_quality-pass.fasta  -ig_seqtype TCR -auxiliary_data optional_file/human_gl.aux -show_translation -outfmt 19  > $5\\$2\\$2_after_annotation.tsv 
echo Perform annotation step by IgBlast...
echo Output File - $5\\$2\\$2_after_annotation.tsv
echo -----------------Annotation- DONE----------------------
echo
echo   
echo ------------Assign into Clonal groups------------------
echo Main steps:
echo  1. Filter by productive=TRUE and cdr3=TRUE
echo  2. Remove and count duplicate 
echo  3. Assign into Clonal groups
Rscript $8\\Assign_into_Clones_[T_CELL].R $5\\$2\\$2_after_annotation.tsv $2 $5\\$2 
#> $5\\$2\\$2_Assign_into_Clones_log.txt
#echo Output File - $5\\$2\\$2_after_clonnig.csv
echo ---------Assign into Clonal groups- DONE---------------
echo
echo
echo --------Create Clone Frequency Summary Table------------
echo Create table that summary for the 10 biggest clone of each chain alpha and beta the clone size frequency and vdj usage.
Rscript $8\\Clone_Freq_Summary.R $5\\$2\\$2_after_clonnig.csv $2 $5\\$2 $8
#> $5\\$2\\$2_TCR_Summary_clone_log.txt
#echo Output File - $5\\$2\\$2_Clone_Summary_Table.xlsx    
echo -----create Clone Frequency Summary Table- DONE----------
echo
echo
echo --------Clonal Size Distribition Analysis------------
echo Create clonal size distribition graph for all clones and for alpha and beta chains separetly.
echo Output Files:
echo   1. $5\\$2\\$2_Clone_size_Distribution[ALL].pdf
echo   2. $5\\$2\\$2_Clone_size_Distribution[TRA].pdf
echo   3. $5\\$2\\$2_Clone_size_Distribution[TRB].pdf
Rscript $8\\Clonal_Size_Distribition.R $5\\$2\\$2_after_clonnig.csv $2 $5\\$2\\ 
echo -----clonal Size Distribition Analysis- DONE---------
echo
echo
echo --------CDR3 Length distribution Analysis------------
echo Create CDR3 Length distribution graphs [x axis -continuous/discrete]
echo Output Files:
echo   1. $5\\$2\\$2_CDR3_Length_Distribution_[x-continuous].pdf
echo   2. $5\\$2\\$2_CDR3_Length_Distribution_[x-discrete].pdf
Rscript $8\\CDR3_Length_distribution.R $5\\$2\\$2_after_clonnig.csv $2 $5\\$2\\ 
echo -----CDR3 Length distribution Analysis- DONE------------
echo
echo
echo --------VDJ Segments Frequencies Analysis------------
echo Calculate and create VDJ Segments Frequencies graphs for alpha and beta chains separetly.
echo Output Files:
echo   1. $5\\$2\\$2_segment_V_frequency[TRB].pdf
echo   2. $5\\$2\\$2_segment_V_frequency[TRA].pdf
echo   3. $5\\$2\\$2_segment_J_frequency[TRB].pdf
echo   4. $5\\$2\\$2_segment_J_frequency[TRA].pdf
echo   5. $5\\$2\\$2_segment_D_frequency[TRB].pdf
Rscript $8\\VDJ_Segments_Frequencies.R $5\\$2\\$2_after_clonnig.csv $2 $5\\$2\\
echo ------VDJ Segments Frequencies Analysis- DONE---------
echo
echo
echo ---------------***-TCR2Rep Pipeline-***-----------------
echo ------------------**-All - Stages-**-------------------- 
echo -----------------------*-DONE-*--------------------------