# The goal of this script is :
# 1) merging the 3 file subject_<context>.txt, X_<context>.txt and y_<context>.txt, where <context> either
# test or trainning collection data context, to one dataframe. The activity observations should be merge with its label, not its id
# 2) cleaning up the original variables and merge the test set and the train test into an unique dataframe
# 3) Extract only mean and standard deviation from this new dataframe as asked in the instructions
# 4) Finally, produce a dataset with the average of each measeurement variables group by subject id and activity.


# install and load the needed libraries
# install.packages("dplyr")
# install.packages("stringr")
# install.packages("sqldf")

library(dplyr)
library(stringr)
library(sqldf)

# -------------------------------------
# Init operations
# -------------------------------------
# Clean context environment
rm(list = ls())

#Set path to data
path = file.path(getwd(), "UCI HAR Dataset")

# -------------------------------------
# Build a dataframe for activity observations 
# -------------------------------------
# Load activity labels into a dataframe and label the columns
activityLabels <- read.delim(file = file.path(path,"activity_labels.txt"), header = FALSE, sep = "")
names(activityLabels) <- c("id", "activityLabel")

#Load Feature labels
featureLabels <- read.delim(file = file.path(path,"features.txt"), header = FALSE, sep = "")
featureLabels <- featureLabels$V2
#Clean up feature labels : replace the special characters as with appropriate one
## all () are replaced with empty string
featureLabels <- str_replace_all(featureLabels, "\\(\\)", "")
## all ) are replaced with empty string
featureLabels <- str_replace_all(featureLabels, "\\)", "")
## all , are replaced with _
featureLabels <- str_replace_all(featureLabels, "\\,", "_")
## all ( are replaced with _
featureLabels <- str_replace_all(featureLabels, "\\(", "_")
## all - are replaced with _
featureLabels <- str_replace_all(featureLabels, "\\-", "_")

# -------------------------------------
# The following is the severals helper function used to merge the 3 files subject, X and y  
# -------------------------------------

# Helper function loadDataset
# It helps to build a dataframe using the context "test" or "train"
## context = test or train
## fileName = string as "X_" or "y_" or "subject_"
## columVector = vector for naming dataset variables; can be null if the naming is not necessary
loadDataset <- function(context, fileName, columVector=NULL) {
  #Load Test set 
  ## Load measurements data
  ds <- read.delim(file = file.path(path,context, paste(fileName,context,".txt", sep = "")), header = FALSE, sep = "" )
  ##Label the variables of the dataset with the parameter columnVector if not null
  if (!is.null(columVector)) {
    names(ds) <- columVector
  }
  ds
}

#Helper function loadObservationActivity 
#It helps to build a dataframe of activity observations, using the context "test" or "train"
#It merges the observation activity file with actitity labels file into a dataframe and add an ID column 
## context = "test" or "train"
loadObservationActivity <- function(context) {
  ds <- loadDataset(context, "y_")
  ds <- data.frame(sapply(ds$V1, function(x) activityLabels[x,"activityLabel"]))
  names(ds) <- c("activityLabel")
  #Add an ID column to activity observations
  #this ID is used in further merging with test measurement dataset
  ds$ID <- seq.int(nrow(ds))
  ds
}

#Helper function columnCompletion
#It helps to produce a measurement dataset with additionnal column : ID, context, subjectID, activityLabel
#It can be used for test and trainning measurement dataset
columnCompletion <- function(context, mds, subject, observationAvtivity) {
  ## Merge measurements data and subjects
  mds$subjectID <- subject$ID
  ## Memorize the context of measurements Test or Trainning
  mds$context <- context
  #Eliminate the duplicate variables from the orginal datasets
  mds <- tbl_df(mds[!duplicated(names(mds))])
  #Add an ID column to measurement datasets
  #this ID is used in further merging with observations activity dataset above
  mds$ID <- seq.int(nrow(mds))
  #Label the activities for each measurements datasets by merging 
  mds$activityLabel <- observationAvtivity$activityLabel
  mds
}

# -------------------------------------
# Merge the 3 files subject, X and y of test and training dataset into 2 separated dataframes
# -------------------------------------

#Load Test set measurements data
xTestSet <- loadDataset("test", "X_", featureLabels) 
#Load Trainnig set measurements data
xTrainingSet <- loadDataset("train", "X_", featureLabels)

## Load subjects
subjectsTest <- loadDataset("test", "subject_", c("ID"))
subjectsTrain <- loadDataset("train", "subject_", c("ID"))

#Load activity observation
observationsTest <- loadObservationActivity("test")
observationsTrain <- loadObservationActivity("train")

xTestSet <- columnCompletion("TEST", xTestSet, subjectsTest, observationsTest)
xTrainingSet <- columnCompletion("TRAIN", xTrainingSet, subjectsTrain, observationsTrain)

# -------------------------------------
# 1. Merges the training and the test sets to create one data set
# -------------------------------------
measurementsDataset <- union_all(xTestSet, xTrainingSet)

# -------------------------------------
# 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
# -------------------------------------
#Build list of column name containg the words mean or std 
meanColumns <- featureLabels[grep("mean", featureLabels, ignore.case = TRUE)]
stdColumns <- featureLabels[grep("std", featureLabels, ignore.case = TRUE)]
## order result dataset columns : firts, ID and parameter columns; next, feature variable columns
columnsExtract <- c("ID", "subjectID", "context", "activityLabel", meanColumns, stdColumns)
## Extracts data by subseting
measurementsDataset <- subset(measurementsDataset, select = columnsExtract)

# -------------------------------------
# 5. Creates an independent tidy data set with the average of each variable for each activity and each subject
# -------------------------------------
#Use the package sqldf : 
#build the sql with average of each measurement, separate by ",", and rename
avgColumn <- paste("avg(",c(meanColumns, stdColumns),") average_", c(meanColumns, stdColumns), ",", sep = "")
#delete the , of the last item
avgColumn[length(avgColumn)] <- str_replace_all(avgColumn[length(avgColumn)],"\\,", " ")
#build the SQL with group by activiti and subject
sql <- paste("select activityLabel, subjectID, ", paste(avgColumn, collapse = ""), " from measurementsDataset group by activityLabel, subjectID")
#execute SQL and put the result into a dataframe
tidyMeasurementsDataset <- sqldf(x=sql)

#Write the tidy data to a txt file with tab separator
write.table(tidyMeasurementsDataset, file = file.path(path, "Human_Activity_Recognition_Using_Smartphones_Tidy_DataSet.txt"), fileEncoding = "UTF-8", sep = "\t", col.names = TRUE)


