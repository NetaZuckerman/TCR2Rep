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
A2_jun <- junction_freq(A2)
A3_jun <- junction_freq(A3)
A4_jun <- junction_freq(A4)

#CHOOSE JUST JUNCTIONS/CLONES THAT APEAR in CARE T
A1_comm_T <- A1_jun[A1_jun$junction %in% T_jun$junction,]
A2_comm_T <- A2_jun[A2_jun$junction %in% T_jun$junction,]
A3_comm_T <- A3_jun[A3_jun$junction %in% T_jun$junction,]
A4_comm_T <- A4_jun[A4_jun$junction %in% T_jun$junction,]

print("A1_in_T:")
print(nrow(A1_comm_T) )
print("A2_in_T:")
print(nrow(A2_comm_T))
print("A3_in_T:")
print(nrow(A3_comm_T))
print("A4_in_T:")
print(nrow(A4_comm_T))

#ORDER BY CLONE SIZE
A1_comm_T <- A1_comm_T[order(A1_comm_T$clone_size,decreasing = TRUE),]
A2_comm_T <- A2_comm_T[order(A2_comm_T$clone_size,decreasing = TRUE),]
A3_comm_T <- A3_comm_T[order(A3_comm_T$clone_size,decreasing = TRUE),]
A4_comm_T <- A4_comm_T[order(A4_comm_T$clone_size,decreasing = TRUE),]

#A1_comm_T <- head(A1_comm_T,100)
#A2_comm_T <- head(A2_comm_T,100)
#A3_comm_T <- head(A3_comm_T,100)
#A4_comm_T <- head(A4_comm_T,100)

#commen_clone<-A1_comm_T$junction
#commen_clone<-append(commen_clone,A2_comm_T$junction)
#commen_clone<-append(commen_clone,A3_comm_T$junction)
#commen_clone<-append(commen_clone,A4_comm_T$junction)
#unq_commen_clone<-unique(commen_clone)

#CRAERE CLONE TRAKING TABLE
junction_AA<- subset(T_care,productive=='TRUE' & cdr3!= 'NULL' & junction!='NULL',select=c("junction","junction_aa","locus"))
junction_AA <- junction_AA[!duplicated(junction_AA[ , "junction"]), ]

A1_T<- merge(T_jun,A1_comm_T,by="junction" ,all=TRUE)
VST_id_col_name<-paste0("Clone_ID[",table_name,"]")
VST_size_col_name<-paste0(table_name)
sample_id_col_name<-paste0("Samp",A1_name,"_clone_id")
sample_size_col_name<-paste0(A1_name)
colnames(A1_T)<-c("junction",VST_id_col_name,VST_size_col_name,sample_id_col_name,sample_size_col_name)

A2_T<- merge(T_jun,A2_comm_T,by="junction" ,all=TRUE)
A2_T<-table_cosmetic(A2_T,A2_name)

A3_T<- merge(T_jun,A3_comm_T,by="junction" ,all=TRUE)
A3_T<-table_cosmetic(A3_T,A3_name)

A4_T<- merge(T_jun,A4_comm_T,by="junction" ,all=TRUE)
A4_T<-table_cosmetic(A4_T,A4_name)

#merge by junction
all_sample <- full_join(junction_AA, A1_T, by = "junction") %>%              # Full outer join of multiple data frames
  full_join(., A2_T, by = "junction") %>%              # Full outer join of multiple data frames
  full_join(., A3_T, by = "junction") %>%              # Full outer join of multiple data frames
  full_join(., A4_T, by = "junction")

#delete id clone of the samples
all_sample$Samp41F_S1_clone_id <-NULL
all_sample$Samp42F_S2_clone_id<-NULL
all_sample$Samp43F_S3_clone_id<-NULL
all_sample$Samp44F_S4_clone_id<-NULL
colnames(all_sample)
#null to 0
#all_sample[all_sample=='NULL'] <- 0

##Set output file with clone
outname <- paste0(path,table_name,"_Clones_Tracking_[percent][by_locus].xlsx")
print(outname)
write_xlsx(all_sample,outname)
print("Clones Tracking process - Done!")
print("~~~~~~")
