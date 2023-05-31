suppressPackageStartupMessages({
 library(readxl)
 library(dplyr)
 library(ggplot2)
})


#library(ggpubr)
#theme_set(theme_pubr())
#Set Path and Arg
args = commandArgs(trailingOnly=TRUE)
# test if there is at least one argument: if not, return an error
if (length(args)==0) {
  input_data_source <- read_xlsx("/mnt/project2/projects/Tcells/Batch1/fastq/AL15/AL15_S3_after_clonnig.xlsx")
  table_name <- "AL15_S3"
  path = "/mnt/project2/projects/Tcells/Batch1/fastq/AL15/"
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

#select v & j call
data_select <- input_data_source %>% 
  select(v_call, j_call, d_call,locus) 

#DF<- head(data_select)


#substring for v and j call
for(i in 1:length(data_select$v_call))
{
  #V_CALL
  data_select[i,1]<-strsplit(as.character(data_select[i,1]),",")[[1]][1]
  data_select[i,1]<-strsplit(as.character(data_select[i,1]),"/")[[1]][1]
  data_select[i,1]<-strsplit(as.character(data_select[i,1]),"*",fixed = TRUE)[[1]][1]
  data_select[i,1] <- substring(data_select[i,1],4)

  #J_CALL
  data_select[i,2]<-strsplit(as.character(data_select[i,2]),",")[[1]][1]
  data_select[i,2]<-strsplit(as.character(data_select[i,2]),"/")[[1]][1]
  data_select[i,2]<-strsplit(as.character(data_select[i,2]),"*",fixed = TRUE)[[1]][1]
  data_select[i,2] <- substring(data_select[i,2],4)
  
  #D_CALL
  data_select[i,3]<-strsplit(as.character(data_select[i,3]),",")[[1]][1]
  data_select[i,3]<-strsplit(as.character(data_select[i,3]),"/")[[1]][1]
  #data_select[i,3]<-strsplit(as.character(data_select[i,3]),"*",fixed = TRUE)[[1]][1]
  data_select[i,3] <- substring(data_select[i,3],4)
}

#B chain______________________________________________
B_data<- subset(data_select,locus=='TRB') 

#calculate freq of v-d-j separetly
#V_call
B_data_v<- as.data.frame(table(B_data$v_call))
B_data_v["TR_locus"]<-"TRB"
sum_v<-sum(B_data_v$Freq)
B_data_v$Freq<-as.double(B_data_v$Freq/sum_v)*100 

#J_call
B_data_j<- as.data.frame(table(B_data$j_call))
B_data_j["TR_locus"]<-"TRB"
sum_j<-sum(B_data_j$Freq)
B_data_j$Freq<-as.double(B_data_j$Freq/sum_j)*100  

#D_call
B_data_d<- as.data.frame(table(B_data$d_call))
B_data_d["TR_locus"]<-"TRB"
sum_d<-sum(B_data_d$Freq)
B_data_d$Freq<-as.double(B_data_d$Freq/sum_d)*100  


#A chain_______________________________________________
A_data<- subset(data_select,locus=='TRA') 
#A_data_vv<- subset(A_data,select=c("v_call",)) 
#V_call
A_data_v<- as.data.frame(table(A_data$v_call))
A_data_v["TR_locus"]<-"TRA"
sum_v<-sum(A_data_v$Freq)
A_data_v$Freq<-as.double(A_data_v$Freq/sum_v)*100  

#J_call
A_data_j<- as.data.frame(table(A_data$j_call))
A_data_j["TR_locus"]<-"TRA"
sum_j<-sum(A_data_j$Freq)
A_data_j$Freq<-as.double(A_data_j$Freq/sum_j)*100  


#combine_for_V&J_freq_graph
v_call_all_chain<-rbind(B_data_v,A_data_v)
j_call_all_chain<-rbind(B_data_j,A_data_j)

#TRB-graph:
#V_call
v_call_B<- subset(v_call_all_chain,TR_locus=='TRB')
main_title <- paste0(table_name," - V gene usage")
outname <- paste0(path,table_name,"_segment_V_frequency[TRB].pdf")
g <- ggplot(data = v_call_B,
            mapping = aes(x = reorder(Var1,Freq), y = Freq, fill = TR_locus)) +
  geom_bar(stat = "identity", position = "dodge", alpha=.9, width=.4) +
  #coord_flip() +
  labs(x = "TRB V gene segments", y = "V usage (%)", fill = "TCR locus") +
  ggtitle(main_title)+
  theme_bw()+ theme(panel.grid.major = element_blank(), 
                    panel.grid.minor = element_blank(),
                    panel.border = element_blank())+
  theme(axis.text.x = element_text(size = 8))+
  theme(axis.text.y = element_text(size = 7))+
  theme(plot.title = element_text(size=8, hjust = 0.5 ))+
  theme(legend.text = element_text(size =8),legend.title = element_text(size = 8))+
  coord_flip()+
  theme(axis.line = element_line(color = 'gray',size = 0.4))+
  theme(text = element_text(size = 8))   

g
ggsave(outname, width = 2.5, height = 5)
  
#J_call
j_call_B<- subset(j_call_all_chain,TR_locus=='TRB')
main_title <- paste0(table_name," - J gene usage")
outname <- paste0(path,table_name,"_segment_J_frequency[TRB].pdf")
g <- ggplot(data = j_call_B,
            mapping = aes(x = reorder(Var1,Freq), y = Freq, fill = TR_locus)) +
  geom_bar(stat = "identity", position = "dodge", alpha=.7, width=.4) +
  #coord_flip() +
  labs(x = "TRB J gene segments", y = "J usage (%)", fill = "TCR locus") +
  ggtitle(main_title)+
  theme_bw()+ theme(panel.grid.major = element_blank(), 
                    panel.grid.minor = element_blank(),
                    panel.border = element_blank())+
  theme(axis.text.x = element_text(size = 8))+
  theme(axis.text.y = element_text(size = 7))+
  theme(plot.title = element_text(size=8, hjust = 0.5 ))+
  theme(legend.text = element_text(size =8),legend.title = element_text(size = 8))+
  coord_flip()+
  theme(axis.line = element_line(color = 'gray',size = 0.4))+
  theme(text = element_text(size = 8))   

g
ggsave(outname , width = 2.5, height = 5)


#D_call
d_call_B<- subset(B_data_d,TR_locus=='TRB')
outname <- paste0(path,table_name,"_segment_D_frequency[TRB].pdf")
main_title <- paste0(table_name," - D gene usage")
g <- ggplot(data = d_call_B,
            mapping = aes(x = reorder(Var1,Freq), y = Freq, fill = TR_locus)) +
  geom_bar(stat = "identity", position = "dodge", alpha=.5, width=.2) +
  #coord_flip() +
  labs(x = "TRB D gene segments", y = "D usage (%)", fill = "TCR locus") +
  ggtitle(main_title)+
  theme_bw()+ theme(panel.grid.major = element_blank(), 
                    panel.grid.minor = element_blank(),
                    panel.border = element_blank())+
  theme(axis.text.x = element_text(size = 8))+
  theme(axis.text.y = element_text(size = 6))+
  theme(plot.title = element_text(size=8, hjust = 0.5 ))+
  theme(legend.text = element_text(size =8),legend.title = element_text(size = 8))+
  coord_flip()+
  theme(axis.line = element_line(color = 'gray',size = 0.4))+
  theme(text = element_text(size = 8))   
g
ggsave(outname , width = 2.5, height = 1.8)


#TRAV-graph
#v_call
v_call_A<- subset(v_call_all_chain,TR_locus=='TRA')
outname <- paste0(path,table_name,"_segment_V_frequency[TRA].pdf")
main_title <- paste0(table_name," - V gene usage")
g <- ggplot(data = v_call_A,
            mapping = aes(x = reorder(Var1,Freq), y = Freq, fill = TR_locus)) +
  geom_bar(stat = "identity", position = "dodge", alpha=.9, width=.4) +
  #coord_flip() +
  labs(x = "TRA V gene segments", y = "V usage (%)", fill = "TCR locus") +
  ggtitle(main_title)+
  theme_bw()+ theme(panel.grid.major = element_blank(), 
                    panel.grid.minor = element_blank(),
                    panel.border = element_blank())+
  theme(axis.text.x = element_text(size = 8))+
  theme(axis.text.y = element_text(size = 7))+
  theme(plot.title = element_text(size=8, hjust = 0.5 ))+
  theme(legend.text = element_text(size =8),legend.title = element_text(size = 8))+
  coord_flip()+
  theme(axis.line = element_line(color = 'gray',size = 0.4))+
  scale_fill_manual(values=c("#56B4E9", "#E69F00"))+
  theme(text = element_text(size = 8))   

g
ggsave(outname , width = 2.5, height = 5)

#j_call
j_call_A<- subset(j_call_all_chain,TR_locus=='TRA')
outname <- paste0(path,table_name,"_segment_J_frequency[TRA].pdf")
main_title <- paste0(table_name," - J gene usage")
g <- ggplot(data = j_call_A,
            mapping = aes(x = reorder(Var1,Freq), y = Freq, fill = TR_locus)) +
  geom_bar(stat = "identity", position = "dodge", alpha=.7, width=.4) +
  #coord_flip() +
  labs(x = "TRA J gene segments", y = "J usage (%)", fill = "TCR locus") +
  ggtitle(main_title)+
  theme_bw()+ theme(panel.grid.major = element_blank(), 
                    panel.grid.minor = element_blank(),
                    panel.border = element_blank())+
  theme(axis.text.x = element_text(size = 8))+
  theme(axis.text.y = element_text(size = 7))+
  theme(plot.title = element_text(size=8, hjust = 0.5 ))+
  theme(legend.text = element_text(size =8),legend.title = element_text(size = 8))+
  coord_flip()+
  theme(axis.line = element_line(color = 'gray',size = 0.4))+
  scale_fill_manual(values=c("#56B4E9", "#E69F00"))+
  theme(text = element_text(size = 8))   

g
ggsave(outname, width = 2.5, height = 5)








