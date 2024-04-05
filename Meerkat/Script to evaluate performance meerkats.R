library(ohun)  # Load the ohun package for audio analysis
library(dplyr)  # Load the dplyr package for data manipulation

# Read the detection results file into a data frame
TempDF_detect <- read.delim('/Users/denaclink/Desktop/RStudioProjects/Transfer-learning-open-data/Meerkat/birdnetoutput/dcase_MK2.BirdNET.selection.table.txt')

# Add a column for the sound file identifier
TempDF_detect$sound.files <- 'dcase_MK2'

# Rename columns for clarity
names(TempDF_detect)[names(TempDF_detect) == "Selection"] <- "selec"
names(TempDF_detect)[names(TempDF_detect) == "Begin.Time..s."] <- "start"
names(TempDF_detect)[names(TempDF_detect) == "End.Time..s."] <- "end"

# Select relevant columns
TempDF_detect <- TempDF_detect[, c("sound.files", "selec", "start", "end")]

# Read the reference detection data
TempDF_ref <- read.csv('/Users/denaclink/Downloads/dcase_data/Development_Set/Training_Set/MT/test/dcase_MK2.csv')

# Add a column for the sound file identifier
TempDF_ref$sound.files <- 'dcase_MK2'

# Create a sequence for the 'selec' column
TempDF_ref$selec <- seq(1, nrow(TempDF_ref), 1)

# Rename columns for clarity
names(TempDF_ref)[names(TempDF_ref) == "Starttime"] <- "start"
names(TempDF_ref)[names(TempDF_ref) == "Endtime"] <- "end"

# Select relevant columns
TempDF_ref <- TempDF_ref[, c("sound.files", "selec", "start", "end")]

# Perform diagnosis on full detections
DiagnoseFull <- diagnose_detection(reference = TempDF_ref, detection = TempDF_detect, min.overlap = 0.001)
DiagnoseFull$f.score

# Read the detection results file again
TempDF_detect <- read.delim('/Users/denaclink/Desktop/RStudioProjects/Transfer-learning-open-data/Meerkat/birdnetoutput/dcase_MK2.BirdNET.selection.table.txt')

# Add a column for the sound file identifier
TempDF_detect$sound.files <- 'dcase_MK2'

# Rename columns for clarity
names(TempDF_detect)[names(TempDF_detect) == "Selection"] <- "selec"
names(TempDF_detect)[names(TempDF_detect) == "Begin.Time..s."] <- "start"
names(TempDF_detect)[names(TempDF_detect) == "End.Time..s."] <- "end"

# Subset detections with confidence > 0.8
TempDF_detect_90 <- subset(TempDF_detect, Confidence > 0.8)

# Select relevant columns
TempDF_detect_90 <- TempDF_detect_90[, c("sound.files", "selec", "start", "end")]

# Diagnose detections with confidence > 0.8
Diagnose90 <- diagnose_detection(reference = TempDF_ref, detection = TempDF_detect_90, min.overlap = 0.001)
Diagnose90$f.score

# Subset detections with confidence > 0.5
TempDF_detect_50 <- subset(TempDF_detect, Confidence > 0.5)

# Select relevant columns
TempDF_detect_50 <- TempDF_detect_50[, c("sound.files", "selec", "start", "end")]

# Diagnose detections with confidence > 0.5 
Diagnose50 <- diagnose_detection(reference = TempDF_ref, detection = TempDF_detect_50, min.overlap = 0.001)
Diagnose50$f.score  

# Create a plot over threshold values
PerformanceDF <- data.frame()

thresholds <- seq(0,1,0.1)
  
for(i in 1:length(thresholds)){
  
  # Read the detection results file again
  TempDF_detect <- read.delim('/Users/denaclink/Desktop/RStudioProjects/Transfer-learning-open-data/Meerkat/birdnetoutput/dcase_MK2.BirdNET.selection.table.txt')
  
  # Add a column for the sound file identifier
  TempDF_detect$sound.files <- 'dcase_MK2'
  
  # Rename columns for clarity
  names(TempDF_detect)[names(TempDF_detect) == "Selection"] <- "selec"
  names(TempDF_detect)[names(TempDF_detect) == "Begin.Time..s."] <- "start"
  names(TempDF_detect)[names(TempDF_detect) == "End.Time..s."] <- "end"
  
  # Subset detections with confidence > 0.8
  TempDF_detect_90 <- subset(TempDF_detect, Confidence > thresholds[i])
  
  # Select relevant columns
  TempDF_detect_90 <- TempDF_detect_90[, c("sound.files", "selec", "start", "end")]
  
  # Diagnose detections with confidence > 0.8
  Diagnose90 <- diagnose_detection(reference = TempDF_ref, detection = TempDF_detect_90, min.overlap = 0.01)
  F1 <- Diagnose90$f.score
  Recall <- Diagnose90$recall
  Precision <- Diagnose90$precision
  Threshold <- thresholds[i]
  
  TempRow <- cbind.data.frame(F1,Recall,Precision,Threshold)
  PerformanceDF <- rbind.data.frame(PerformanceDF,TempRow )
}


# Create plot
ggplot(data = PerformanceDF, aes(x = Threshold)) +
  geom_line(aes(y = F1, color = "F1"), linetype = "solid") +
  geom_line(aes(y = Precision, color = "Precision"), linetype = "solid") +
  geom_line(aes(y = Recall, color = "Recall"), linetype = "solid") +
  labs(title = "Meerkat automated detection",
       x = "Thresholds",
       y = "Values") +
  scale_color_manual(values = c("F1" = "blue", "Precision" = "red", "Recall" = "green"),
                     labels = c("F1", "Precision", "Recall")) +
  theme_minimal()+
  theme(legend.title = element_blank())# +xlim(0.5,1)

