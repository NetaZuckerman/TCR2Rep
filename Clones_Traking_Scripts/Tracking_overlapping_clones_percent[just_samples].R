library(writexl)
library(readxl)
library(dplyr)
library(tidyverse)
library(openxlsx)
library(data.table)

# Author - Mor Hava Pereg
# date - 14/12/2022
#run ex:



#___TCR_assign_clone_fun____
TCR_assign_clone_fun <- function(my_table) {
  db_clone_id <- transform(my_table,clone = as.numeric(factor(junction)))
  #calculate clone size
  db_clone_size<-setDT(db_clone_id)[, .N, clone]
  clone_table<- merge(db_clone_id,db_clone_size,by="clone")
  #table cosmetics
  colnames(clone_table)[which(names(clone_table) == "N")] <- "clone_size"
  clone_table <- clone_table %>% relocate(clone, .before = clone_size)
  return(clone_table)
}

#___TCR_calculate_junc_freq____
junction_freq <- function(my_table) {
  my_table<- subset(my_table,productive=='TRUE' & cdr3!= 'NULL' & junction!='NULL',select=c("junction","junction_aa"))
  my_table<-TCR_assign_clone_fun(my_table)
  my_table<-subset(my_table,select = (c("junction","clone","clone_size")))
  n_seq<- nrow(my_table)
  print(nrow(my_table))
  my_table$clone_size<-(my_table$clone_size/n_seq)*100
  my_table <- my_table[!duplicated(my_table[ , "junction"]), ]
  return(my_table)
}

#TABLE_COSMETIC
table_cosmetic <- function(my_table,table_name) {
  my_table$clone.x<-NULL
  my_table$clone_size.x<-NULL
  id<-paste0("Samp",table_name,"_clone_id")
  size<-paste0(table_name)
  colnames(my_table)<-c("junction",id,size)
  return(my_table)
}

#without_dup:
args = commandArgs(trailingOnly=TRUE)
# test if there is at least one argument: if not, return an error
if (length(args)==0) {
  T_care <- read_tsv("/mnt/project2/projects/Tcells/Batch3_jan2023/fastq/raw/12F_S10/12F_S10_after_annotation.tsv")
  table_name <- "PP65_Minimal_CD8+"
    
  A1<-read_tsv("/mnt/project2/projects/Tcells/Batch3_jan2023/fastq/raw/41F_S1/41F_S1_after_annotation.tsv")
  A1_name<-"41F_S1"
  
  A2<-read_tsv("/mnt/project2/projects/Tcells/Batch3_jan2023/fastq/raw/42F_S2/42F_S2_after_annotation.tsv")
  A2_name<-"42F_S2"
  
  A3<-read_tsv("/mnt/project2/projects/Tcells/Batch3_jan2023/fastq/raw/43F_S3/43F_S3_after_annotation.tsv")
  A3_name<-"43F_S3"
  
  A4<-read_tsv("/mnt/project2/projects/Tcells/Batch3_jan2023/fastq/raw/44F_S4/44F_S4_after_annotation.tsv")
  A4_name<-"44F_S4"
  
  path = "/mnt/project2/projects/Tcells/Batch3_jan2023/"
  setwd(path)
  #stop("At least one argument must be supplied (input file).tsv", call.=FALSE)
} else if (length(args)>0) {
  # default output file
  T_care <- read_tsv(args[1])
  table_name <- args[2] 
  
  A1<-read_tsv("/mnt/project2/projects/Tcells/Batch3_jan2023/fastq/raw/41F_S1/41F_S1_after_annotation.tsv")
  A1_name<-"41F_S1"
  
  A2<-read_tsv("/mnt/project2/projects/Tcells/Batch3_jan2023/fastq/raw/42F_S2/42F_S2_after_annotation.tsv")
  A2_name<-"42F_S2"
  
  A3<-read_tsv("/mnt/project2/projects/Tcells/Batch3_jan2023/fastq/raw/43F_S3/43F_S3_after_annotation.tsv")
  A3_name<-"43F_S3"
  
  A4<-read_tsv("/mnt/project2/projects/Tcells/Batch3_jan2023/fastq/raw/44F_S4/44F_S4_after_annotation.tsv")
  A4_name<-"44F_S4"
  
  path = "/mnt/project2/projects/Tcells/Batch3_jan2023/"
  setwd(path)
  
  #A1<-read_tsv(args[3])
  #A1_name<-args[4]
  
  #A2<-read_tsv(args[5])
  #A2_name<-args[6]
  
  #A3<-read_tsv(args[7])
  #A3_name<-args[8]
  
  #A4<-read_tsv(args[9])
  #A4_name<-args[10]
  
  #path=args[11]
  #setwd(path)
}

#assign into clonal group by junction 
T_jun <- junction_freq(T_care)
A1_jun <- junction_freq(A1)
A1_jun$clone <- NULL
colnames(A1_jun)<-c("junction","41F_S1") 
A2_jun <- junction_freq(A2)
A2_jun$clone <- NULL
colnames(A2_jun)<-c("junction","42F_S2") 
A3_jun <- junction_freq(A3)
A3_jun$clone <- NULL
colnames(A3_jun)<-c("junction","43F_S3") 
A4_jun <- junction_freq(A4)
A4_jun$clone <- NULL
colnames(A4_jun)<-c("junction","44F_S4") 


aa<-rbind(A1[,c("junction","junction_aa","locus","productive","cdr3")],A2[,c("junction","junction_aa","locus","productive","cdr3")],A3[,c("junction","junction_aa","locus","productive","cdr3")],A4[,c("junction","junction_aa","locus","productive","cdr3")])


data_new<- subset(aa,productive=='TRUE' & cdr3!= 'NULL' & junction!='NULL')
data_new <- data_new[!duplicated(data_new[ , "junction"]), ] 
data_new$productive<-NULL

all_sample <- full_join(data_new, A1_jun, by = "junction")%>%              # Full outer join of multiple data frames
  full_join(., A2_jun, by = "junction") %>%              # Full outer join of multiple data frames
  full_join(., A3_jun, by = "junction") %>%              # Full outer join of multiple data frames
  full_join(., A4_jun, by = "junction") 

#all_sample[all_sample=='NULL'] <- 0
##Set output file with clone
outname <- paste0(path,"Just_samples","_Clones_Tracking_[percent][by_locus].xlsx")
print(outname)
write_xlsx(all_sample,outname)
print("Clones Tracking process - Done!")
print("~~~~~~")
