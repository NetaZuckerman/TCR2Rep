#_Author_: Mor Hava Pereg
#_version_: 008
#_Date_: 11/12/2022
#CDR3 length dist
suppressPackageStartupMessages({
library(plyr)
library(ggplot2)
library(readxl)
library(stringr)
})


#Set Path and Arg
args = commandArgs(trailingOnly=TRUE)
# test if there is at least one argument: if not, return an error
if (length(args)==0) {
  input_data_source <- read_xlsx("/mnt/project2/projects/Tcells/Batch2/fastq/CD8-hexon-mini_S1/CD8-hexon-mini_S1_after_clonnig.xlsx")
  table_name <- "CD8-hexon-mini_S1"
  path = "/mnt/project2/projects/Tcells/Batch2/fastq/CD8-hexon-mini_S1/"
  #setwd(path)
  #stop("At least one argument must be supplied (input file).tsv", call.=FALSE)
} else if (length(args)>0) {
  # default output file
  input_data_source<- read.csv(file = args[1],sep=',')
  #input_data_source<-read_excel(args[1])
  table_name <- args[2] 
  path=args[3]
  #setwd(path)
}

#subset the table for cdr3 and locus
sub_data<-input_data_source[c("cdr3","locus")]
sub_data$cdr3_length <- str_length(sub_data$cdr3)
sub_data$cdr3<-NULL
sub_data<-subset(sub_data, locus %in% c('TRB','TRA'))
sub_data_count <- ddply(sub_data,.(locus,cdr3_length),nrow)
sum_seq=sum(sub_data_count$V1)
sub_data_count$V1 <-  sub_data_count$V1/sum_seq
max_value<-max(sub_data_count$cdr3_length)

#set outname plot
outname <- paste0(path,table_name,"_CDR3_Length_Distribution_[x-discrete].pdf")

#Create histograme
counts <- table(sub_data$locus , sub_data$cdr3_length )
pdf(file = outname,width=10, height=7)
#par(mar=c(8,14,8,14))
barplot(counts, main="CDR3 Length Distribution",
        xlab="CDR3 Length",ylab = "Sequences", col=c("#649cfc", "#fc746c"),border="white",
        legend = rownames(counts), beside=TRUE ,  cex.lab = 1 ,cex.axis = 2 , cex.main=2 )
dev.off()

#color - BLUE"#56B4E9", RED"#F8766D"
outname2 <- paste0(path,table_name,"_CDR3_Length_Distribution_[x-continuous].pdf")
p <- ggplot(sub_data_count, aes(x = cdr3_length, y = V1)) +
  geom_bar(
    aes(color = locus, fill = locus),
    stat = "identity", position = position_dodge(0.8),
    width = 0.7
  ) +
  theme_bw()+ theme(panel.grid.major = element_blank(), 
                    panel.grid.minor = element_blank())+
  labs(x="CDR3 Length" , y="Percent")+
  theme(text=element_text(size=20))+
  scale_color_manual(values = c("#56B4E9", "#F8766D"))+
  scale_fill_manual(values = c("#56B4E9", "#F8766D"))+
  theme(axis.text.x = element_text(size = 15))+
  theme(axis.text.y = element_text(size = 15))
ggsave(outname2 ,  height = 4 , width = 8)
#ggsave(outname2,path=path ,  height = 4 , width = 8)


#t=(max_value/100)+20








#, cex.lab = 2 ,cex.axis = 1.6 , cex.main=2 , col='#F8766D', border='red'