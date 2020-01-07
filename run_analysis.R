# Load Packages
library(dplyr)




# Data preparation

## Download the file zip
if (!file.exists("Dataset.zip")) { 
  download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",
                destfile = "Dataset.zip")
  
  ## Unzip the file zip
  unzip("Dataset.zip")
}

## Read from the files txt
features <- read.table("UCI HAR Dataset/features.txt", header = F, stringsAsFactors = F) %>% pull(2)
    
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt", header = F, stringsAsFactors = F) %>% pull(2)

dataTrainX <- read.table("UCI HAR Dataset/train/X_train.txt", header = F, stringsAsFactors = F)

dataTrainY <- read.table("UCI HAR Dataset/train/y_train.txt", header = F, stringsAsFactors = F)

dataTrainSubject <- read.table("UCI HAR Dataset/train/subject_train.txt", header = F, stringsAsFactors = F)

dataTestX <- read.table("UCI HAR Dataset/test/X_test.txt", header = F, stringsAsFactors = F)

dataTestY <- read.table("UCI HAR Dataset/test/y_test.txt", header = F, stringsAsFactors = F)

dataTestSubject <- read.table("UCI HAR Dataset/test/subject_test.txt", header = F, stringsAsFactors = F)


## Combine X, Y and Subject in « train » / « test » data :
dataTrain<-data.frame(dataTrainSubject, dataTrainX, dataTrainY)
names(dataTrain)<-c("subject", features, "activity")

dataTest<-data.frame(dataTestSubject, dataTestX, dataTestY)
names(dataTest)<-c("subject", features, "activity")

#rm(dataTrainSubject, dataTrainX, dataTrainY,dataTestSubject, dataTestX, dataTestY)


# Data transformations

## Merges the training and the test sets to create one data set.
data <- rbind(dataTrain, dataTest)

## Extracts only the measurements on the mean and standard deviation for each measurement.
data_ext <- data[,which(colnames(data) %in% c("subject", "activity", grep("mean\\(\\)|std\\(\\)", colnames(data), value=TRUE)))]
str(data_ext)

## Uses descriptive activity names to name the activities in the data set
data_ext$activity <- activityLabels[data_ext$activity]
head(data_ext$activity)

## Appropriately labels the data set with descriptive variable names.
names(data_ext)

names(data_ext) <- gsub("^t", "Time", names(data_ext))
names(data_ext) <- gsub("^f", "Frequency", names(data_ext))
names(data_ext) <- gsub("Acc", "Accelerometer", names(data_ext))
names(data_ext) <- gsub("Gyro", "Gyroscope", names(data_ext))
names(data_ext) <- gsub("BodyBody", "Body", names(data_ext))
names(data_ext) <- gsub("Mag", "Magnitude", names(data_ext))
names(data_ext) <- gsub("-mean\\(\\)", "-Mean", names(data_ext))
names(data_ext) <- gsub("-std\\(\\)", "-STD", names(data_ext))
names(data_ext)

## From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
tidyData <- aggregate(. ~ subject + activity, data_ext, mean)
head(tidyData)


# Output 
write.table(tidyData, "tidy_data_set.txt", row.name = FALSE)
