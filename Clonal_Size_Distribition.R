#_Author_: Mor Hava Pereg
#_version_: 008
#_Date_: 11/12/2022
#clonal size distribition
suppressPackageStartupMessages({
library(ggplot2)
library(readxl)
})

#Set Path and Arg

#Set Path and Arg
args = commandArgs(trailingOnly=TRUE)
# test if there is at least one argument: if not, return an error
if (length(args)==0) {
  input_data_source <- read_xlsx("/home/orz/TCR_Pipeline/Data/Batch2/fastq/CD8-hexon-mini_S1_after_clonnig.xlsx")
  table_name <- "CD8-hexon-mini_S1"
  path = "/home/orz/TCR_Pipeline/Data/Batch2/fastq/"
  #setwd(path)
  #stop("At least one argument must be supplied (input file).tsv", call.=FALSE)
} else if (length(args)>0) {
  # default output file
  input_data_source<-read.csv(file = args[1],sep=',')
  #input_data_source<-read_excel(args[1]) 
  table_name <- args[2] 
  path=args[3]
  #setwd(path)
}

#just B chain
sub_data<- subset(input_data_source,locus=='TRB')
#subset the table for clone and clone size
sub_clone_tb<-sub_data[c("clone","clone_size_without_duplicate_seq")]

#sort by clone size
sub_clone_tb <- sub_clone_tb[order(sub_clone_tb$clone_size_without_duplicate_seq ,decreasing = TRUE),]

#remove duplicates 
sub_clone_tb<-sub_clone_tb[!duplicated(sub_clone_tb),]

#remove clones < 10
my_data<- subset(sub_clone_tb,clone_size_without_duplicate_seq>10)

#color - BLUE"#56B4E9", RED"#F8766D"
# Give the chart file a name
outname <- paste0(path,table_name,"_Clone_size_Distribution[TRB].pdf")
main_name <- paste0("Clone size Distribution\n",table_name," - TRB")
pdf(file = outname)
# Create the bar chart
par(mar=c(8,8,8,8))
barplot(my_data$clone_size_without_duplicate_seq, main=main_name, sub = "(clones with clone size < 10 are not displayed)" ,
        xlab="#TRB clones",ylab = "clone size" , cex.lab = 2 ,cex.axis = 1.6 , cex.main=2 , col='#F8766D', border='red')
# Save the file
dev.off()
#print("clone size distribution - TRB - DONE")
###########################################################
#just A chain
sub_data<- subset(input_data_source,locus=='TRA')
#subset the table for clone and clone size
sub_clone_tb<-sub_data[c("clone","clone_size_without_duplicate_seq")]

#sort by clone size
sub_clone_tb <- sub_clone_tb[order(sub_clone_tb$clone_size_without_duplicate_seq ,decreasing = TRUE),]

#remove duplicates 
sub_clone_tb<-sub_clone_tb[!duplicated(sub_clone_tb),]

#remove clones < 10
my_data<- subset(sub_clone_tb,clone_size_without_duplicate_seq>10)

# Give the chart file a name
outname <- paste0(path,table_name,"_Clone_size_Distribution[TRA].pdf")
main_name <- paste0("Clone size Distribution\n",table_name," - TRA")
pdf(file = outname)
# Create the bar chart
par(mar=c(8,8,8,8))
barplot(my_data$clone_size_without_duplicate_seq, main=main_name, sub = "(clones with clone size < 10 are not displayed)" ,
        xlab="#TRA clones",ylab = "clone size", cex.lab = 2 ,cex.axis = 1.6 , cex.main=2, col='#56B4E9', border='#00A9FF')
# Save the file
dev.off()
#print("clone size distribution - TRA - DONE")
###############################################################
#all data 

#subset the table for clone and clone size
sub_clone_tb<-input_data_source[c("clone","clone_size_without_duplicate_seq")]

#sort by clone size
sub_clone_tb <- sub_clone_tb[order(sub_clone_tb$clone_size_without_duplicate_seq ,decreasing = TRUE),]

#remove duplicates 
sub_clone_tb<-sub_clone_tb[!duplicated(sub_clone_tb),]

#remove clones < 10
my_data<- subset(sub_clone_tb,clone_size_without_duplicate_seq>10)


# Give the chart file a name
outname <- paste0(path,table_name,"_Clone_size_Distribution[ALL].pdf")
main_name <- paste0("Clone size Distribution\n",table_name)
pdf(file = outname)
# Create the bar chart
par(mar=c(8,8,8,8))
barplot(my_data$clone_size_without_duplicate_seq, main=main_name, sub = "(clones with clone size < 10 are not displayed)" ,
        xlab="#Clones",ylab = "clone size", cex.lab = 2 ,cex.axis = 1.6 , cex.main=2)
# Save the file
dev.off()
#print("clone size distribution -All data - DONE")
