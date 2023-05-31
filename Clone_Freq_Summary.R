suppressPackageStartupMessages({
library(writexl)
library(dplyr)
library(tidyverse)
library(openxlsx)
library(zip)
})


#library(readxl)
#library(xlsx)
#library(XLS)

# Create clone summary table with freq and 10 biggest clone details
# Author - Mor Hava Pereg
# date - 19/01/2023
#print("________start create clone summary table_________")
args = commandArgs(trailingOnly=TRUE)

#Set Path and Arg
args = commandArgs(trailingOnly=TRUE)
# test if there is at least one argument: if not, return an error
if (length(args)==0) {
  #exel names
  a="/mnt/project2/projects/Tcells/Batch1/fastq/AL11/AL11_S1_after_clonnig.xlsx"
  path = "/mnt/project2/projects/Tcells/Batch1/fastq/AL11/"
  setwd(path)
  table_name <- "al11"
  #b="/mnt/project2/projects/Tcells/Batch1/fastq/AL11/AL11_S1_10_biggest_clone_summery.xlsx"
  #stop("At least one argument must be supplied (input file).tsv", call.=FALSE)
} else if (length(args)>0) {
  # default output file
  #exel names
  a= args[1]#after_clonnig.xlsx"
  #b= args[2]#10_biggest_clone_summery.xlsx"
  table_name <- args[2] 
  path = args[3]
  setwd(path)
}


#____________________________________________
name_txt_file<-paste0(table_name,"_Clones_report.txt")
fileConn<-file(name_txt_file)
writeLines("", fileConn)
cat(c("__________Sample - ",table_name," - Clones Report:___________"), file=name_txt_file,append = TRUE)
#writeLines(c(name_txt_file,":"), fileConn)

all_details <- read.csv(file = a,sep=',')
#all_details <- read_excel(a,sheet = 1)
#all_details<-input_data_source
all_details <- all_details[order(all_details$clone_size_with_duplicate_seq,decreasing = TRUE),]

#LOCUS A - sub for 10 top 
data_all_A<-subset(all_details,locus=="TRA")
data_A<-subset(data_all_A,select=c("clone","clone_size_with_duplicate_seq"))
#just unique A clones
data_A<-unique(data_A)
cat(c("\n\nAll sequnces:",nrow(all_details)), file=name_txt_file,append = TRUE)
cat("\n\n_________TRA LOCUS:__________", file=name_txt_file,append = TRUE)
cat(c("\nTRA sequnces:",nrow(data_all_A)), file=name_txt_file,append = TRUE)
cat(c("\nTRA Clones:",nrow(data_A)), file=name_txt_file,append = TRUE)
cat(c("\nBiggest clone size:",data_A$clone_size_with_duplicate_seq[[1]]), file=name_txt_file,append = TRUE)
cat(c("\nAverage clone size:",mean(data_A$clone_size_with_duplicate_seq)), file=name_txt_file,append = TRUE)
cat(c("\nMadian clone size:",median(data_A$clone_size_with_duplicate_seq)), file=name_txt_file,append = TRUE)
name_A<-paste0(table_name,"-TRA")
#subset table for 10 biggest clone
clone_size_list_A<-lapply(data_A$clone_size_with_duplicate_seq,sort,decreasing=TRUE)
top_ten_until_A <- clone_size_list_A[[10]]
data_A<-subset(data_all_A,clone_size_with_duplicate_seq>=top_ten_until_A)


#LOCUS B - sub for 10 top
data_all_B<-subset(all_details,locus=="TRB")
data_B<-subset(data_all_B,select=c("clone","clone_size_with_duplicate_seq"))
#just unique B clones
data_B<-unique(data_B)
cat("\n\n_________TRB LOCUS:_________", file=name_txt_file,append = TRUE)
cat(c("\nTRB sequnces:",nrow(data_all_B)), file=name_txt_file,append = TRUE)
cat(c("\nTRB Clones:",nrow(data_B)), file=name_txt_file,append = TRUE)
cat(c("\nBiggest clone size:",data_B$clone_size_with_duplicate_seq[[1]]), file=name_txt_file,append = TRUE)
cat(c("\nAverage clone size:",mean(data_B$clone_size_with_duplicate_seq)), file=name_txt_file,append = TRUE)
cat(c("\nMadian clone size:",median(data_B$clone_size_with_duplicate_seq)), file=name_txt_file,append = TRUE)
close(fileConn)
name_B<-paste0(table_name,"-TRB")
#subset table for 10 biggest clone
clone_size_list_B<-lapply(data_B$clone_size_with_duplicate_seq,sort,decreasing=TRUE)
top_ten_until_B <- clone_size_list_B[[10]]
data_B<-subset(data_all_B,clone_size_with_duplicate_seq>=top_ten_until_B)




#TRA clone -summary

data_A_clone<-subset(data_A,select=c("v_call","j_call","cdr3","clone","clone_size_with_duplicate_seq","clone_size_without_duplicate_seq"))
A_clone<-unique(data_A_clone)
#new table for sumerry all v and j in one row
df_A <- unique( data_A_clone[ , c("clone","clone_size_with_duplicate_seq","clone_size_without_duplicate_seq","cdr3") ] )
df_A$v_call <- NA
df_A$j_call <- NA
#summnery all v and j in each clone
for (c in df_A$clone){
  v_call_list<-unique(subset(A_clone,clone==c,select="v_call"))$v_call
  v_call<-paste(v_call_list,collapse = ' or ')
  df_A[which(df_A$clone == c),"v_call"]<- v_call
  j_call_list<-unique(subset(A_clone,clone==c,select="j_call"))$j_call
  j_call<-paste(j_call_list,collapse = ' or ')
  df_A[which(df_A$clone == c),"j_call"]<- j_call
  }
#Calculate cdr3 length
df_A$cdr3_length <- NA
df_A$cdr3_length <- lapply(df_A$cdr3, str_length)
df_A <- df_A %>% relocate(cdr3_length, .after = cdr3)


#TRB clone -summary

data_B_clone<-subset(data_B,select=c("v_call","d_call","j_call","cdr3","clone","clone_size_with_duplicate_seq","clone_size_without_duplicate_seq"))
B_clone<-unique(data_B_clone)
#new table for sumerry all v and j in one row
df_B <- unique( data_B_clone[ , c("clone","clone_size_with_duplicate_seq","clone_size_without_duplicate_seq","cdr3") ] )
df_B$v_call <- NA
df_B$d_call <- NA
df_B$j_call <- NA
#summnery all v and j in each clone
for (c in df_B$clone){
  v_call_list<-unique(subset(B_clone,clone==c,select="v_call"))$v_call
  v_call<-paste(v_call_list,collapse = ' or ')
  df_B[which(df_B$clone == c),"v_call"]<- v_call
  d_call_list<-unique(subset(B_clone,clone==c,select="d_call"))$d_call
  d_call<-paste(d_call_list,collapse = ' or ')
  df_B[which(df_B$clone == c),"d_call"]<- d_call
  j_call_list<-unique(subset(B_clone,clone==c,select="j_call"))$j_call
  j_call<-paste(j_call_list,collapse = ' or ')
  df_B[which(df_B$clone == c),"j_call"]<- j_call
}
#Calculate cdr3 length
df_B$cdr3_length <- NA
df_B$cdr3_length <- lapply(df_B$cdr3, str_length)
df_B <- df_B %>% relocate(cdr3_length, .after = cdr3)


#list of excel df
my_data <- list()
#list of excel sheet
name_sheet<-list()

#create sheets and calculate freq of each clone:

#1. all_seq_sheet
df1 <- read.csv(file = a,sep=',')
#df1 <- read_excel(a,sheet = 1)
#for a
sub_data_a<- subset(df1,locus=='TRA')
seq_a_with_dup <-sum(sub_data_a$duplicate_seq)
seq_a_without_dup<-nrow(sub_data_a)
sub_data_a$clone_percent_without_dup <- (sub_data_a$clone_size_without_duplicate_seq/seq_a_without_dup)*100
sub_data_a$clone_percent_with_dup <- (sub_data_a$clone_size_with_duplicate_seq/seq_a_with_dup)*100
#for b
sub_data_b<- subset(df1,locus=='TRB')
seq_b_with_dup <-sum(sub_data_b$duplicate_seq)
seq_b_without_dup<-nrow(sub_data_b)
sub_data_b$clone_percent_without_dup <- (sub_data_b$clone_size_without_duplicate_seq/seq_b_without_dup)*100
sub_data_b$clone_percent_with_dup <- (sub_data_b$clone_size_with_duplicate_seq/seq_b_with_dup)*100
#merge 
df1<- rbind(sub_data_a,sub_data_b)
#add sheet to list of exel file 
my_data[[1]] <- df1
name_sheet[[1]]<- "all_seq" 

print("TRA sequences with duplicates:")
print(seq_a_with_dup)
print("TRA sequences without duplicates:")
print(seq_a_without_dup)
print("")
print("TRB sequences with duplicates:")
print(seq_b_with_dup)
print("TRB sequences without duplicates:")
print(seq_b_without_dup)


#2. 10_TRA_clone_sheet

data_A$clone_percent_without_dup <- (data_A$clone_size_without_duplicate_seq/seq_a_without_dup)*100
data_A$clone_percent_with_dup <- (data_A$clone_size_with_duplicate_seq/seq_a_with_dup)*100
my_data[[2]] <- data_A
name_sheet[[2]]<- "10_TRA_clone" 


#3. 10_TRA_summery_sheet

df_A$clone_percent_without_dup <- (df_A$clone_size_without_duplicate_seq/seq_a_without_dup)*100
df_A$clone_percent_with_dup <- (df_A$clone_size_with_duplicate_seq/seq_a_with_dup)*100
my_data[[3]] <- df_A
name_sheet[[3]]<- "10_TRA_summery"


#4. 10_TRB_clone_sheet

data_B$clone_percent_without_dup <- (data_B$clone_size_without_duplicate_seq/seq_b_without_dup)*100
data_B$clone_percent_with_dup <- (data_B$clone_size_with_duplicate_seq/seq_b_with_dup)*100
my_data[[4]] <- data_B
name_sheet[[4]]<- "10_TRB_clone" 


#5. 10_TRB_summery_sheet

df_B$clone_percent_without_dup <- (df_B$clone_size_without_duplicate_seq/seq_b_without_dup)*100
df_B$clone_percent_with_dup <- (df_B$clone_size_with_duplicate_seq/seq_b_with_dup)*100
my_data[[5]] <- df_B
name_sheet[[5]]<- "10_TRB_summery" 

outname <- paste0(table_name,"_clone_summary_Table.xlsx")
write.xlsx(my_data,outname,sheetName=name_sheet )
print("output file:")
print(outname )
#print("DONE - summary clone table")

