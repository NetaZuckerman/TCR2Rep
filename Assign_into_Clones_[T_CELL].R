#_Author_: Mor Hava Pereg
#_version_: 008
#_Date_: 11/12/2022
#_assign TCR sequences into clones by junction___ 
#print(" ")
#print("____________Process - Assign TCR sequences into clones (by cdr3)______________")

#___TCR_assign_clone_fun____
TCR_assign_clone_fun <- function(my_table) {
  db_clone_id <- transform(my_table,clone = as.numeric(factor(cdr3)))
  #calculate clone size
  db_clone_size<-setDT(db_clone_id)[, .N, clone]
  clone_table<- merge(db_clone_id,db_clone_size,by="clone")
  #table cosmetics
  colnames(clone_table)[which(names(clone_table) == "N")] <- "clone_size"
  clone_table <- clone_table %>% relocate(clone, .before = clone_size)
  return(clone_table)
}

print("Rscript install packages start..")
suppressPackageStartupMessages({
if (!require("BiocManager", quietly = TRUE)){
     install.packages("BiocManager", quietly = TRUE, repos = "http://cran.us.r-project.org")
     library(BiocManager, quietly = TRUE)}
if (!require("Biostrings", quietly = TRUE)){
     BiocManager::install("Biostrings",force = TRUE, dependencies = TRUE, quietly = TRUE)
     library(Biostrings, quietly = TRUE)  }
if(!require("scoper")){
    install.packages("scoper", repos = "http://cran.us.r-project.org")
    library(scoper, quietly = TRUE)}
if(!require("GenomicAlignments")){
    BiocManager::install("GenomicAlignments", repos = "http://cran.us.r-project.org")
    library(GenomicAlignments, quietly = TRUE)}
   # not need instlation:
   library(tidyverse, quietly = TRUE)
   library(data.table, quietly = TRUE)
   library(writexl, quietly = TRUE)
   library(dplyr, quietly = TRUE)
})



#if(!require("Biostrings")){
#   if (!require("BiocManager", quietly = TRUE))
#        install.packages("BiocManager", repos = "http://cran.us.r-project.org")
#    BiocManager::install("Biostrings", repos = "http://cran.us.r-project.org")
#    suppressPackageStartupMessages({
#    library(Biostrings, quietly = TRUE))    })
#}

print("Rscript instll packages end")


#Set Path and Arg
args = commandArgs(trailingOnly=TRUE)
# test if there is at least one argument: if not, return an error
if (length(args)==0) {
  input_data <- read_tsv("/home/orz/TCR_Pipeline/Data/Batch1/fastq/AL11/AL11_S1_after_annotation.tsv",col_names = TRUE)
  table_name <- "AL_11_S1"
  path = "/home/orz/TCR_Pipeline/Data/Batch1/fastq/AL11/"
  setwd(path)
  #stop("At least one argument must be supplied (input file).tsv", call.=FALSE)
} else if (length(args)>0) {
  # default output file
  input_data<-read_tsv(args[1],col_names = TRUE,show_col_types = FALSE)
  table_name <- args[2] 
  path = args[3]
  setwd(path)
}


#my_data<- subset(input_data,productive=='TRUE' & cdr3!= 'NULL' ,select=c("sequence_id","sequence","rev_comp","locus","productive","v_call","d_call","j_call","cdr3","cdr3_start","cdr3_end","junction","junction_length"))
print("~~~~~~")
print("Assign TCR sequences into clones (by cdr3) details:")
print("Sequences:")
print(nrow(input_data))
print("")
#filter by productive=T 
my_data<- subset(input_data,productive=='TRUE')
print("Sequences pass Productive filter:")
print(nrow(my_data))
print("")
#filter by cdr3=T
my_data<- subset(my_data,cdr3!= 'NULL' )
print("Sequences pass CDR3 filter:")
print(nrow(my_data))
print("")


#find source seq by apply reverse Complement
my_data$source_sequence<- my_data$sequence
a<-1
for (i in my_data$source_sequence ){
  if (my_data$rev_comp[[a]] == TRUE){
    my_data$source_sequence[[a]]<-toString(reverseComplement(DNAString(i)))
      a=a+1}
  else {
    a=a+1
  }
}

#table cosmetics
colnames(my_data)[which(names(my_data) == "sequence")] <- "annotated_sequence"
my_data <- my_data %>% relocate(source_sequence, .before = annotated_sequence)

#data 1 
#clone size - include duplicate seq 
#assign into clone by identical junction region (with duplicates seq)
clone_tb_with_dup<- TCR_assign_clone_fun(my_data)
#remove dup seq and rename clone size column for - clone_size_with_duplicate_seq
clone_tb_with_dup <- clone_tb_with_dup[!duplicated(clone_tb_with_dup$annotated_sequence), ]
colnames(clone_tb_with_dup)[colnames(clone_tb_with_dup) == 'clone_size'] <- 'clone_size_with_duplicate_seq'

#data 2 
#clone size - not include duplicate seq 
#remove duplicate
count_dup<-setDT(my_data)[, .N, annotated_sequence]
count_dup_table<- merge(my_data,count_dup,by="annotated_sequence")
count_dup_table <- count_dup_table[order(count_dup_table$N,decreasing = TRUE),]
count_dup_table <- count_dup_table[!duplicated(count_dup_table$annotated_sequence), ]
print("Sequences left after remove duplicate:")
print(nrow(count_dup_table))
colnames(count_dup_table)[which(names(count_dup_table) == "N")] <- "duplicate_seq"
count_dup_table <- count_dup_table %>% relocate(annotated_sequence, .after =source_sequence)

#assign into clone by identical junction region (without duplicates seq)_____________________________________________
clone_tb_without_dup <- TCR_assign_clone_fun(count_dup_table) 

#merge all data
clone_tb_with_dup<- unique(clone_tb_with_dup[,c("clone","clone_size_with_duplicate_seq")])
all_data<- merge(clone_tb_without_dup,clone_tb_with_dup)
colnames(all_data)[which(names(all_data) == "clone_size")] <- "clone_size_without_duplicate_seq"
all_data <- all_data %>% relocate(clone, .before = clone_size_without_duplicate_seq)

##Set output file with clone
outname <- paste0(path,"/",table_name,"_after_clonnig.csv")
print("Output file path:")
print(outname)
#write_xlsx(all_data,paste(outname,sep = ''),)
write.csv(all_data,outname)
#print("Assign into clone process - Done!")
#print("~~~~~~")
#tb1<-read_excel("/home/orz/TCR_Pipeline/Data/Batch1/fastq/AL11/AL_11_S1_Annotation_Table_clone.xlsx",col_names = TRUE)
#tb2<-read_excel("/home/orz/TCR_Pipeline/Data/Batch1/fastq/AL11/AL_11_S1_Annotation_Table_clone2.xlsx",col_names = TRUE)
#sss<- all_equal(tb1,tb2)








#merge all data
#sub_dup <- clone_tb_with_dup[,c("clone","clone_size_with_duplicate_seq")]
#sub_dup<- unique(sub_dup)
#all_data<- merge(merge_clone_undup,sub_dup)
#colnames(all_data)[which(names(all_data) == "clone_size")] <- "clone_size_without_duplicate_seq"
#all_data <- all_data %>% relocate(clone, .before = clone_size_without_duplicate_seq)













