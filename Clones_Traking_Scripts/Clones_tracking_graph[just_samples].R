library(readxl)
library(dplyr)
library(ggplot2)
library(RColorBrewer)
library(reshape2)  
library(ggnewscale)
#install.packages("scales")
library(scales)

#data_1:consistent_Clones
input1 <- read_xlsx("/mnt/project2/projects/Tcells/Batch3_jan2023/VST_45F_Clones_Tracking_[percent]290123NETA.xlsx")
input1$junction<-NULL
input1$junction_aa<-NULL
input1$`Clone_ID[VST_45F]` <-NULL
input1$VST_45F <-NULL
input1t = t(input1)
rownames(input1t)<-c("2022-09-29", "2022-10-26", "2022-11-17", "2022-12-13")
#rownames(input1)<-  format(as.Date(rownames(input1)), "%Y/%m/%d")
data1 <- melt(input1t, id = "x")
data1$Var2<-as.character(data1$Var2)
#data1$Var2<-as.Date.factor(data1$Var1)

#data_2:Inconsistent_Clones
input2<- read_xlsx("/mnt/project2/projects/Tcells/Batch3_jan2023/45F_S5_Clones_Tracking_[percent][by_locus].xlsx")
input2<- input2[!(input2$junction %in% input1$junction),]
input2$locus<-NULL
input2$junction<-NULL
input2$junction_aa<-NULL
input2$`Clone_ID[45F_S5]` <-NULL
input2$`45F_S5` <-NULL
input2t = t(input2)
rownames(input2t)<-c("2022-09-29", "2022-10-26", "2022-11-17", "2022-12-13")
#rownames(input2)<-  format(as.Date(rownames(input2)), "%Y/%m/%d")
data2 <- melt(input2t, id = "x")
data2$Var2<-as.character(data2$Var2)
#data2$Var2<-as.Date.factor(data2$Var1)
data2$Inconsistent_Clones<-"Inonsistent"

#data_3:New_Clones
input3<- read_xlsx("/mnt/project2/projects/Tcells/Batch3_jan2023/Just_samples_Clones_Tracking_[percent][by_locus].xlsx")
input3<- input3[!(input3$junction %in% input2$junction),]
input3$locus<-NULL
input3$junction<-NULL
input3$junction_aa<-NULL
input3$cdr3 <-NULL
#input3$Car_t<- NA
#input3 <- input3 %>%
#  select(Car_t, everything())
#input2$`45F_S5` <-NULL
input3t= t(input3)
rownames(input3t)<-c("2022-09-29", "2022-10-26", "2022-11-17", "2022-12-13")
#rownames(input2)<-  format(as.Date(rownames(input2)), "%Y/%m/%d")
data3 <- melt(input3t, id = "x")
data3$Var2<-as.character(data3$Var2)
#data2$Var2<-as.Date.factor(data2$Var1)
data3$New_Clones<-"new_clones"

ggplot() +
  geom_line(data2, mapping=aes(x = Var1 ,y = value, color = Inconsistent_Clones, group = Var2)) +
  scale_colour_manual(values = "grey50", labels ="")+
  new_scale_color() +
  labs(colour = "Purple-Orange")+
  geom_line(data1 , mapping=aes(x = Var1 ,y = value, color = Var2, group = Var2)) +
  scale_colour_manual(values = rainbow(27)) +
  labs(
    caption = "Inconsist_Clones - are clones that appear in treatment but not in all samples. \nConsistent Clones - are clones that are shared by all samples",
    colour = "Consistent Clones",
    y = "Freq  % " , x = "Blood Samples ")+
  ggtitle("CAR-T Cell Clones Tracking") +
  theme(legend.position = 'bottom')+theme_bw()+ 
  geom_text(data = data1, aes(x=Var1, y= value,  label = Var2))+
  theme(axis.text.x = element_text(size = 13 ))+
  theme(axis.text.y = element_text(size = 15))+
  theme(text=element_text(size=20))+
  theme(panel.grid.major = element_blank(),
        axis.line = element_line(colour = "grey"), 
        panel.grid.minor = element_blank(),
        plot.title = element_text(hjust = 0.5),
        panel.border = element_blank(),plot.caption = element_text(hjust=0, size = 12)) 
  


  #scale_x_date(date_labels = "%d")


