
# Cat's meow dataset

library(stringr)

TempWavs <- list.files('/Users/denaclink/Downloads/archive/dataset/dataset')
TempWavs

Category <- str_split_fixed(TempWavs,pattern = '_',n=2)[,1]

TempWavsLong <- list.files('/Users/denaclink/Downloads/archive/dataset/dataset',
full.names = T)

OutputDir <- '/Users/denaclink/Desktop/VSCodeRepos/BirdNET Transfer/CatMeowExperiments/'

# We will create 5 folders with a 70/30 split
N.randomization <- 5

Unique.Category <- unique(Category)

for(b in 1:(N.randomization)){
  
  for(a in 1:length(Unique.Category)){   
    
    TempSubsetPulse <- which(Category==Unique.Category[a])

    TempWavsSub <- TempWavs[which(Category==Unique.Category[a])]
    TempWavsLongSub <- TempWavsLong[which(Category==Unique.Category[a])]
    N.samples.train <- round(length(TempSubsetPulse)*0.7,0)
    Samples.vec <- sample( 1:length(TempWavsLongSub), size =N.samples.train , replace = FALSE)

    TrainWavs <- TempWavsLongSub[Samples.vec]
    TrainWavName <- TempWavsSub[Samples.vec]

    TestWavs <- TempWavsLongSub[-Samples.vec]
    TestWavName <- TempWavsSub[-Samples.vec]
    
    TrainOutPut <- paste(OutputDir, 'experiment', b,'/', 'train',b,'/', Unique.Category[a],sep='')
    TestOutPut <- paste(OutputDir, 'experiment', b,'/','test',b,'/', Unique.Category[a],sep='')

    dir.create(TrainOutPut,recursive = T)
    dir.create(TestOutPut,recursive = T)

    file.copy(from=TrainWavs,
    to=paste(TrainOutPut,'/',TrainWavName,sep=''))

    file.copy(from=TestWavs,
    to=paste(TestOutPut,'/',TestWavName,sep=''))

  }
}