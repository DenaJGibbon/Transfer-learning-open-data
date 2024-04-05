library(tuneR)
library(seewave)

# Meerkat data 
Annotations <- list.files('/Users/denaclink/Downloads/dcase_data/Development_Set/Training_Set/MT',
           pattern = '.csv',full.names = T)

Wavfiles <- list.files('/Users/denaclink/Downloads/dcase_data/Development_Set/Training_Set/MT',
                       pattern = '.wav',full.names = T)
  
MK1csv <- read.csv(Annotations[1])
Mk1wav <- readWave(Wavfiles[1])

TrainingDataWavsDir <- 'Meerkat/trainingdata/'
CombinedDF <- data.frame()

for(a in 1:nrow(MK1csv)){
 TempRow <-  MK1csv[a,]
 Class <- colnames(TempRow) [which(str_detect(TempRow,'POS'))]
 if(length(Class)>0 ){
 TempWav <-  cutw(Mk1wav,from=TempRow$Starttime,to=TempRow$Endtime,output = 'Wave')  
 NewOutputDir <- paste(TrainingDataWavsDir,Class,'/',sep='/')
 dir.create(NewOutputDir,showWarnings = F,recursive = T)
 WavName <- paste(NewOutputDir,Class,a,'.wav',sep='_')
 writeWave(TempWav,WavName)  
 TempRow<- cbind.data.frame(TempRow,Class,a)
 CombinedDF <- rbind.data.frame(CombinedDF,TempRow,WavName)
}
}
