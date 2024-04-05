library(stringr)  # Load the stringr package for string manipulation
library(tidyr)    # Load the tidyr package for data tidying
library(ggpubr)   # Load the ggpubr package for ggplot2-based plotting
library(ggplot2)

# Get the list of files containing BirdNET clip detections
ClipDetections <-
  list.files(
    'CatsMeow/CatMeowExperiments/birdnetoutput/',
    recursive = TRUE,
    full.names = TRUE
  )

# Get the list of files' names
ClipDetectionsShort <-
  list.files(
    'CatsMeow/CatMeowExperiments/birdnetoutput/',
    recursive = TRUE,
    full.names = FALSE
  )

# Create an empty data frame to store BirdNET performance
BirdNETPerformanceDFCatsMeow <- data.frame()

# Loop through each clip detection file
for (a in 1:length(ClipDetections)) {
  # Read the detection data from the file
  TempDF <- read.delim(ClipDetections[a])
  
  # Get the maximum confidence and the corresponding row
  Confidence <- max(TempDF$Confidence)
  TempDF <- TempDF[which.max(TempDF$Confidence), ]
  
  # Extract actual label from the directory path
  ActualLabel <- dirname(ClipDetectionsShort[a])
  
  # Extract experiment and actual label from the directory path
  Experiment <-
    str_split_fixed(ActualLabel, pattern = '/', n = 2)[, 1]
  ActualLabel <-
    str_split_fixed(ActualLabel, pattern = '/', n = 2)[, 2]
  
  # Get the predicted label from the detection data
  PredictedLabel <- TempDF$Species.Code
  
  # Create a temporary row for the performance data
  TempRow <-
    cbind.data.frame(Confidence, ActualLabel, Experiment, PredictedLabel)
  TempRow$FileName <- ClipDetectionsShort[a]
  
  # Append the temporary row to the performance data frame
  BirdNETPerformanceDFCatsMeow <-
    rbind.data.frame(BirdNETPerformanceDFCatsMeow, TempRow)
}

# Filter out rows with PredictedLabel as 'FALSE'
BirdNETPerformanceDFCatsMeow <-
  subset(BirdNETPerformanceDFCatsMeow, PredictedLabel != 'FALSE')

# Calculate confusion matrix using caret package
caret::confusionMatrix(
  data = as.factor(BirdNETPerformanceDFCatsMeow$PredictedLabel),
  reference = as.factor(BirdNETPerformanceDFCatsMeow$ActualLabel),
  mode = 'everything'
)

# Get unique experiments
experiments <- unique(BirdNETPerformanceDFCatsMeow$Experiment)

# Create an empty data frame to store results
BestF1data.frameCatMeowBirdNET <- data.frame()

# Loop through each threshold value and experiment
  for (b in 1:length(experiments)) {
    TopModelDetectionDF_single <-
      subset(BirdNETPerformanceDFCatsMeow, Experiment == experiments[b])
    
    # Calculate confusion matrix using caret package
    caretConf <- caret::confusionMatrix(
      as.factor(TopModelDetectionDF_single$PredictedLabel),
      as.factor(TopModelDetectionDF_single$ActualLabel),
      mode = 'everything'
    )
    
    # Extract F1 score, Precision, and Recall from the confusion matrix
    F1 <- caretConf$byClass[, 7]
    Precision <- caretConf$byClass[, 5]
    Recall <- caretConf$byClass[, 6]
    BalancedAccuracy <- caretConf$byClass[, 11]
    
    # Create a temporary row for F1 score, Precision, and Recall
    TempF1Row <- cbind.data.frame(F1, Precision, Recall)
    TempF1Row$Class <- rownames(TempF1Row)
    TempF1Row$Experiment <- experiments[b]
    
    # Append the temporary row to the results data frame
    BestF1data.frameCatMeowBirdNET <-
      rbind.data.frame(BestF1data.frameCatMeowBirdNET, TempF1Row)
  }


# Plot F1 scores using ggboxplot
ggpubr::ggboxplot(data = BestF1data.frameCatMeowBirdNET,
                  x = 'Class',
                  y = 'F1')

# Reshape the data frame to long format
BestF1data.frameCatMeowBirdNET_long <- tidyr::gather(BestF1data.frameCatMeowBirdNET,
                                                     metric,
                                                     measure,
                                                     F1:Recall,
                                                     factor_key = TRUE)

# Plot F1 scores, Precision, and Recall using ggboxplot
ggpubr::ggboxplot(
  data = BestF1data.frameCatMeowBirdNET_long,
  x = 'Class',
  y = 'measure',
  fill = 'metric',
  alpha = 0.75
) +
  xlab('') +
  ylab('Value') +
  theme(legend.title = element_blank()) +
  scale_fill_manual(values = matlab::jet.colors(3))  # Adjust color scheme
