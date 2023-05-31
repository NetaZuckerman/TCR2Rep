library(data.table)
library(ggplot2)
library(dplyr)
library(tidyverse)
library(openxlsx)

path= "/home/mor/"


#___TCR_assign_clone_fun____
TCR_assign_clone_fun <- function(my_table) {
  db_clone_id <- transform(my_table,clone = as.numeric(factor(cdr3_aa)))
  #calculate clone size
  db_clone_size<-setDT(db_clone_id)[, .N, clone]
  clone_table<- merge(db_clone_id,db_clone_size,by="clone")
  #table cosmetics
  colnames(clone_table)[which(names(clone_table) == "N")] <- "clone_size"
  clone_table <- clone_table %>% relocate(clone, .before = clone_size)
  return(clone_table)
}

args = commandArgs(trailingOnly=TRUE)
#CAR T
input_data_source_vst <- read_tsv(args[2])
#input_data_source_vst <- read_tsv("/mnt/project2/projects/Tcells/Batch3_jan2023/fastq/raw/45F_S5/45F_S5_after_annotation.tsv")
input_data_source_vst<- subset(input_data_source_vst,productive=='TRUE' ,select=c("cdr3","cdr3_aa"))
input_data_source_vst<- subset(input_data_source_vst,cdr3!= 'NULL')
input_data_source_vst<- subset(input_data_source_vst,str_length(cdr3_aa)>=10)
VST_clone_table<-TCR_assign_clone_fun(input_data_source_vst)
VST_name <- "VST product"
#remove clones < 10
#VST_clone_table<- subset(VST_clone_table,clone_size>10)
 # ggplot(VST_clone_table, aes(clone, clone_size)) +  # 
 #   geom_bar(stat = 'identity') 
VST_clone_table_SET<- unique(VST_clone_table$cdr3_aa) 
# uniq cdr3_aa
VST_clone_table_uniq<-VST_clone_table[!duplicated(VST_clone_table[,c('cdr3_aa')]),]

#sample 1
input_data_source_s1 <- read_tsv(args[3])
#input_data_source_s1 <- read_tsv("/mnt/project2/projects/Tcells/Batch3_jan2023/fastq/raw/41F_S1/41F_S1_after_annotation.tsv")
input_data_source_s1<- subset(input_data_source_s1,productive=='TRUE' ,select=c("cdr3","cdr3_aa"))
input_data_source_s1<- subset(input_data_source_s1,cdr3!= 'NULL')
input_data_source_s1<- subset(input_data_source_s1,str_length(cdr3_aa)>=10)
s1_clone_table<-TCR_assign_clone_fun(input_data_source_s1)
S1_name <- "S1[29.9.22]"
#s1_clone_table<- subset(s1_clone_table,clone_size>10)
# ggplot(s1_clone_table, aes(clone, clone_size)) +  # 
#   geom_bar(stat = 'identity') 
s1_clone_table_SET<- unique(s1_clone_table$cdr3_aa) 

#vs vst
s1_clone_table<-s1_clone_table[!duplicated(s1_clone_table[,c('cdr3_aa')]),]
csr3_s1<- as.vector(VST_clone_table_uniq$cdr3_aa) 
vst_s1<- subset(s1_clone_table, cdr3_aa %in% csr3_s1)
vst_s1$clone<-NULL
vst_merge<-subset(VST_clone_table_uniq,select=c("cdr3_aa","clone","clone_size"))
vst_s1<-merge(vst_s1,vst_merge, by="cdr3_aa",suffixes = c(".S1",".VST"))
vst_s1<- vst_s1 %>% relocate("clone", .before = "clone_size.S1")


#sample 2
input_data_source_s2 <- read_tsv(args[4])
#input_data_source_s2 <- read_tsv("/mnt/project2/projects/Tcells/Batch3_jan2023/fastq/raw/42F_S2/42F_S2_after_annotation.tsv")
S2_name <- "S2[26.10.22]"
input_data_source_s2<- subset(input_data_source_s2,productive=='TRUE' ,select=c("cdr3","cdr3_aa"))
input_data_source_s2<- subset(input_data_source_s2,cdr3!= 'NULL')
input_data_source_s2<- subset(input_data_source_s2,str_length(cdr3_aa)>=10)
s2_clone_table<-TCR_assign_clone_fun(input_data_source_s2)
#s2_clone_table<- subset(s2_clone_table,clone_size>10)
# ggplot(s2_clone_table, aes(clone, clone_size)) +  # 
#   geom_bar(stat = 'identity') 
s2_clone_table_SET<- unique(s2_clone_table$cdr3_aa)

#vs vst
s2_clone_table<-s2_clone_table[!duplicated(s2_clone_table[,c('cdr3_aa')]),]
csr3_s2<- as.vector(VST_clone_table_uniq$cdr3_aa) 
vst_s2<- subset(s2_clone_table, cdr3_aa %in% csr3_s2)
vst_s2$clone<-NULL
vst_merge<-subset(VST_clone_table_uniq,select=c("cdr3_aa","clone","clone_size"))
vst_s2<-merge(vst_s2,vst_merge, by="cdr3_aa",suffixes = c(".S2",".VST"))
vst_s2<- vst_s2 %>% relocate("clone", .before = "clone_size.S2")

#sample 3
input_data_source_s3 <- read_tsv(args[5])
#input_data_source_s3 <- read_tsv("/mnt/project2/projects/Tcells/Batch3_jan2023/fastq/raw/43F_S3/43F_S3_after_annotation.tsv")
S3_name <- "S3[17.11.22]"
input_data_source_s3<- subset(input_data_source_s3,productive=='TRUE'  ,select=c("cdr3","cdr3_aa"))
input_data_source_s3<- subset(input_data_source_s3,cdr3!= 'NULL')
input_data_source_s3<- subset(input_data_source_s3,str_length(cdr3_aa)>=10)
s3_clone_table<-TCR_assign_clone_fun(input_data_source_s3)
#s3_clone_table<- subset(s3_clone_table,clone_size>10)
# ggplot(s3_clone_table, aes(clone, clone_size)) +  # 
#   geom_bar(stat = 'identity') 
s3_clone_table_SET<- unique(s3_clone_table$cdr3_aa) 

#vs vst
s3_clone_table<-s3_clone_table[!duplicated(s3_clone_table[,c('cdr3_aa')]),]
csr3_s3<- as.vector(VST_clone_table_uniq$cdr3_aa) 
vst_s3<- subset(s3_clone_table, cdr3_aa %in% csr3_s3)
vst_s3$clone<-NULL
vst_merge<-subset(VST_clone_table_uniq,select=c("cdr3_aa","clone","clone_size"))
vst_s3<-merge(vst_s3,vst_merge, by="cdr3_aa",suffixes = c(".S3",".VST"))
vst_s3<- vst_s3 %>% relocate("clone", .before = "clone_size.S3")

#sample 4
input_data_source_s4 <- read_tsv(args[6])
#input_data_source_s4 <- read_tsv("/mnt/project2/projects/Tcells/Batch3_jan2023/fastq/raw/44F_S4/44F_S4_after_annotation.tsv")
S4_name <- "S4[13.12.22]"
input_data_source_s4<- subset(input_data_source_s4,productive=='TRUE' ,select=c("cdr3","cdr3_aa"))
input_data_source_s4<- subset(input_data_source_s4,cdr3!= 'NULL')
input_data_source_s4<- subset(input_data_source_s4,str_length(cdr3_aa)>=10)
s4_clone_table<-TCR_assign_clone_fun(input_data_source_s4)
#s4_clone_table<- subset(s4_clone_table,clone_size>10)
# ggplot(s4_clone_table, aes(clone, clone_size)) +  # 
#   geom_bar(stat = 'identity') 
s4_clone_table_SET<- unique(s4_clone_table$cdr3_aa) 

#vs vst
s4_clone_table<-s4_clone_table[!duplicated(s4_clone_table[,c('cdr3_aa')]),]
csr3_s4<- as.vector(VST_clone_table_uniq$cdr3_aa) 
vst_s4<- subset(s4_clone_table, cdr3_aa %in% csr3_s4)
vst_s4$clone<-NULL
vst_merge<-subset(VST_clone_table_uniq,select=c("cdr3_aa","clone","clone_size"))
vst_s4<-merge(vst_s4,vst_merge, by="cdr3_aa",suffixes = c(".S4",".VST"))
vst_s4<- vst_s4 %>% relocate("clone", .before = "clone_size.S4")

all_apearing_clones<- append(vst_s1$cdr3_aa,vst_s2$cdr3_aa)
all_apearing_clones<- append(all_apearing_clones,vst_s3$cdr3_aa)
all_apearing_clones<- append(all_apearing_clones,vst_s4$cdr3_aa)
all_apearing_clones<- unique(all_apearing_clones)
VST_apearing<-subset(VST_clone_table_uniq, cdr3_aa %in% all_apearing_clones)

#all_overlap_clones
common_clones_list <- c(unique(VST_clone_table_uniq$cdr3_aa),unique(vst_s1$cdr3_aa),unique(vst_s2$cdr3_aa),unique(vst_s3$cdr3_aa),unique(vst_s4$cdr3_aa))
vst_all_overlap <-intersect(intersect(intersect(intersect(VST_clone_table_uniq$cdr3_aa,vst_s1$cdr3_aa),vst_s2$cdr3_aa),vst_s3$cdr3_aa),vst_s4$cdr3_aa)
VST__all_overlap_tb<-subset(VST_clone_table_uniq, cdr3_aa %in% vst_all_overlap)
vst_s1_sub<-subset(vst_s1, cdr3_aa %in% vst_all_overlap, select = c("cdr3_aa","clone","clone_size.S1"))
vst_s2_sub<-subset(vst_s2, cdr3_aa %in% vst_all_overlap, select = c("cdr3_aa","clone","clone_size.S2"))
vst_s3_sub<-subset(vst_s3, cdr3_aa %in% vst_all_overlap, select = c("cdr3_aa","clone","clone_size.S3"))
vst_s4_sub<-subset(vst_s4, cdr3_aa %in% vst_all_overlap, select = c("cdr3_aa","clone","clone_size.S4"))
#VST__all_overlap_tb_MERGE<- merge(VST__all_overlap_tb,vst_s1_sub,vst_s2_sub,vst_s3_sub,vst_s2_sub,) 

library(tidyverse)
#put all data frames into list
df_list <- list(VST__all_overlap_tb, vst_s1_sub, vst_s2_sub, vst_s3_sub, vst_s4_sub)      

#merge all data frames together
df_list_tb<- df_list %>% reduce(full_join, by='cdr3_aa')
df_list_tb$clone.y<-NULL
df_list_tb$clone.x.x<-NULL
df_list_tb$clone.y.y<-NULL
df_list_tb$clone<-NULL
colnames(df_list_tb)[which(names(df_list_tb) == "clone.x")] <- "clone" 
colnames(df_list_tb)[which(names(df_list_tb) == "clone_size")] <- "clone_size.VST" 

#list of excel df
my_data <- list()
#list of excel sheet
name_sheet<-list()

#add sheet to list of exel file 
my_data[[1]] <- VST_apearing
name_sheet[[1]]<- "VST_APEARING_CLONES" 
#name_sheet[[1]]<- "VST_ALL_OVELAP_CLONES" 
my_data[[2]] <- vst_s1
name_sheet[[2]]<- "S1_vs_VST" 
my_data[[3]] <- vst_s2
name_sheet[[3]]<- "S2_vs_VST" 
my_data[[4]] <- vst_s3
name_sheet[[4]]<- "S3_vs_VST" 
my_data[[5]] <- vst_s4
name_sheet[[5]]<- "S4_vs_VST" 
my_data[[6]] <- df_list_tb
name_sheet[[6]]<- "OVERLAP_CLONES"

args = commandArgs(trailingOnly=TRUE)
care_t_name<-args[1]
outname <- paste0(care_t_name,"_overlap_clones(all)_by_cdr3_aa-Report_new.xlsx")
write.xlsx(my_data,outname,sheetName=name_sheet )


#install.packages("venn")
library(venn)

venn = 
  list(
    CAR_T = VST_clone_table_SET,
    Sample_1 = s1_clone_table_SET,
    Sample_2 = s2_clone_table_SET,
    Sample_3 = s3_clone_table_SET,
    Sample_4 = s4_clone_table_SET
   )

png_name<-paste0(care_t_name,"_ven_by_cdr3_aa_(all).png")
png(png_name, width = 800, height = 800)

venn.result =
  venn(venn, ilabels = TRUE,
       zcolor = "style", size = 100, cexil = 1.2, cexsn = 1.5, ilcs=1.7,sncs=1.7, box=FALSE );


dev.off()


# 
# 
# 
# 
# venn.diagram(
#   x <- list(
#     A = set1,
#     B = set2,
#     C = set3,
#     D = set4,
#     E = set5
#   ),
#   category.names = c("CAR_T" , "S1" , "S2" , "S3" , "S4"),
#   filename = paste0(path,"new_xx"),
#   output = TRUE ,
#   imagetype="png" ,
#   height = 480 , 
#   width = 480 , 
#   resolution = 300,
#   compression = "lzw",
#   lwd = 1,
#   col=c("#440154ff", '#21908dff', '#fde725ff' , "red" , "orange"),
#   fill = c(alpha("#440154ff",0.3), alpha('#21908dff',0.3), alpha('#fde725ff',0.3),alpha("red",0.3), alpha('orange',0.3)),
#   cex = 0.5,
#   fontfamily = "sans",
#   cat.cex = 0.3,
#   cat.default.pos = "outer",
#   #cat.pos = c(-27, 27, 135),
#   #cat.dist = c(0.055, 0.055, 0.085),
#   cat.fontfamily = "sans",
#   cat.col = c("#440154ff", '#21908dff', '#fde725ff',"red", "orange"),
#   #rotation = 1
# )
# 
# #Draw the diagram comparing the Olympics and Sierra sets
# v3 <- venn.diagram(  x <- list(
#   VST = set1,
#   S1 = set2,
#   S2 = set3,
#   S3 = set4,
#   S4 = set5
# ),
# fill = c("red", "green", "white", "blue", "yellow"),
# alpha = c(0.5, 0.5, 0.5, 0.5, 0.5),
# filename=NULL)
# pdf("plotOlympicsSierraVennn.pdf")
# grid.newpage()
# grid.draw(v3)
# dev.off()
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# 
# # # Load library
# # install.packages("VennDiagram")
# # install.packages("ColorBrewer")
# # library(VennDiagram)
# # library(RColorBrewer)
# # 
# # # Generate 3 sets of 200 words
# # set1 <- VST_clone_table_SET
# # set2 <- s1_clone_table_SET
# # set3 <- s2_clone_table_SET
# # set4 <- s3_clone_table_SET
# # set5 <- s4_clone_table_SET
# # 
# # # Prepare a palette of 3 colors with R colorbrewer:
# # myCol <- brewer.pal(5, "Pastel2")
# # 
# # x <- list(
# #   A = set1, 
# #   B = set2, 
# #   C = set3,
# #   D = set4,
# #   E = set5
# # )
# # 
# # if (!require(devtools)) install.packages("devtools")
# # 
# # install.packages("ggvenn")
# # library(ggvenn)
# # ggvenn(
# #   x, 
# #   fill_color = c("#0073C2FF", "#EFC000FF", "#868686FF", "#CD534CFF","green"),
# #   stroke_size = 0.6, set_name_size = 4
# # )
