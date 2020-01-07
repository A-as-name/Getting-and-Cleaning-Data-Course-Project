# Code Book

## Data set infomation
The experiments have been carried out with a group of 30 volunteers within an age bracket of 19-48 years. Each person performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the waist. Using its embedded accelerometer and gyroscope, we captured 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz. The experiments have been video-recorded to label the data manually. The obtained dataset has been randomly partitioned into two sets, where 70% of the volunteers was selected for generating the training data and 30% the test data. 


The sensor signals (accelerometer and gyroscope) were pre-processed by applying noise filters and then sampled in fixed-width sliding windows of 2.56 sec and 50% overlap (128 readings/window). The sensor acceleration signal, which has gravitational and body motion components, was separated using a Butterworth low-pass filter into body acceleration and gravity. The gravitational force is assumed to have only low frequency components, therefore a filter with 0.3 Hz cutoff frequency was used. From each window, a vector of features was obtained by calculating variables from the time and frequency domain.


For each record it is provided:
- Triaxial acceleration from the accelerometer (total acceleration) and the estimated body acceleration.
- Triaxial Angular velocity from the gyroscope. 
- A 561-feature vector with time and frequency domain variables. 
- Its activity label. 
- An identifier of the subject who carried out the experiment.


The following files are available for the train and test data. Their descriptions are equivalent. 

- 'train/subject_train.txt': Each row identifies the subject who performed the activity for each window sample. Its range is from 1 to 30. 
- 'train/Inertial Signals/total_acc_x_train.txt': The acceleration signal from the smartphone accelerometer X axis in standard gravity units 'g'. Every row shows a 128 element vector. The same description applies for the 'total_acc_x_train.txt' and 'total_acc_z_train.txt' files for the Y and Z axis. 
- 'train/Inertial Signals/body_acc_x_train.txt': The body acceleration signal obtained by subtracting the gravity from the total acceleration. 
- 'train/Inertial Signals/body_gyro_x_train.txt': The angular velocity vector measured by the gyroscope for each window sample. The units are radians/second. 



## Data preparation
First of all we need to download the file by using *download.file()*, then we unzip the file to get the data and read correctly in R.

### Getting the file from the internet
```r
if (!file.exists("Dataset.zip")) { 
  download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",
                destfile = "Dataset.zip")
  
  ## Unzip the file zip
  unzip("Dataset.zip")
}
```


### Reading data from txt files
```r
features <- read.table("UCI HAR Dataset/features.txt", header = F, stringsAsFactors = F) %>% pull(2)
    
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt", header = F, stringsAsFactors = F) %>% pull(2)

dataTrainX <- read.table("UCI HAR Dataset/train/X_train.txt", header = F, stringsAsFactors = F)

dataTrainY <- read.table("UCI HAR Dataset/train/y_train.txt", header = F, stringsAsFactors = F)

dataTrainSubject <- read.table("UCI HAR Dataset/train/subject_train.txt", header = F, stringsAsFactors = F)

dataTestX <- read.table("UCI HAR Dataset/test/X_test.txt", header = F, stringsAsFactors = F)

dataTestY <- read.table("UCI HAR Dataset/test/y_test.txt", header = F, stringsAsFactors = F)

dataTestSubject <- read.table("UCI HAR Dataset/test/subject_test.txt", header = F, stringsAsFactors = F)
```


### Combine X, Y and Subject in « train » / « test » data
```r
dataTrain<-data.frame(dataTrainSubject, dataTrainX, dataTrainY)
names(dataTrain)<-c("subject", features, "activity")

dataTest<-data.frame(dataTestSubject, dataTestX, dataTestY)
names(dataTest)<-c("subject", features, "activity")
```



## Data transformations
The goal of this part is to obtain a tidy data set which will provide the measurements on the mean and standard deviation for each variables through the following steps.
### Merges the training and the test sets to create one data set
```r
data <- rbind(dataTrain, dataTest)
```

### Extracts only the measurements on the mean and standard deviation for each measurement.
```r
data_ext <- data[,which(colnames(data) %in% c("subject", "activity", grep("mean\\(\\)|std\\(\\)", colnames(data), value=TRUE)))]
str(data_ext)
```

### Uses descriptive activity names to name the activities in the data set
```r
data_ext$activity <- activityLabels[data_ext$activity]
head(data_ext$activity)
```

### Appropriately labels the data set with descriptive variable names.
```r
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
```

### From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
```r
tidyData <- aggregate(. ~ subject + activity, data_ext, mean)
head(tidyData)
```