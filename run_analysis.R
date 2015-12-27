## Downloads the file and saves it a local file folder
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, destfile = "./data/Dataset.zip")

## Unzips the file
unzip(zipfile = "./data/Dataset.zip", exdir = "./data")

## Loads the required packages
library(dplyr)
library(data.table)

## This code block list all of the files that were downloaded
path_rf <- file.path("./data" , "UCI HAR Dataset")
files <- list.files(path_rf, recursive = TRUE)
files

## This code block reads the "Activity", "Subject" and "Fetures" files
dataActivityTest  <- read.table(file.path(path_rf, "test" , "Y_test.txt" ), header = FALSE)
dataActivityTrain <- read.table(file.path(path_rf, "train", "Y_train.txt"), header = FALSE)
dataSubjectTest  <- read.table(file.path(path_rf, "test" , "subject_test.txt"), header = FALSE)
dataSubjectTrain <- read.table(file.path(path_rf, "train", "subject_train.txt"), header = FALSE)
dataFeaturesTest  <- read.table(file.path(path_rf, "test" , "X_test.txt" ),header = FALSE)
dataFeaturesTrain <- read.table(file.path(path_rf, "train", "X_train.txt"),header = FALSE)

## This code block merges the data sets and gives names to the variables
dataSubject <- rbind(dataSubjectTrain, dataSubjectTest)
dataActivity <- rbind(dataActivityTrain, dataActivityTest)
dataFeatures <- rbind(dataFeaturesTrain, dataFeaturesTest)
names(dataSubject) <- c("subject")
names(dataActivity) <- c("activity")
dataFeaturesNames <- read.table(file.path(path_rf, "features.txt"),head=FALSE)
names(dataFeatures) <- dataFeaturesNames$V2
dataCombine <- cbind(dataSubject, dataActivity)
Data <- cbind(dataFeatures, dataCombine)

## Calculates the mean and standard deviation for the measurements
subdataFeaturesNames <- dataFeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", dataFeaturesNames$V2)]
selectedNames <- c(as.character(subdataFeaturesNames), "subject", "activity" )
Data <- subset(Data, select = selectedNames)

## Gives descriptive names to the type of activity using the gsub function
activityLabels <- read.table(file.path(path_rf, "activity_labels.txt"), header = FALSE)
names(Data) <- gsub("^t", "time", names(Data))
names(Data) <- gsub("^f", "frequency", names(Data))
names(Data) <- gsub("Acc", "Accelerometer", names(Data))
names(Data) <- gsub("Gyro", "Gyroscope", names(Data))
names(Data) <- gsub("Mag", "Magnitude", names(Data))
names(Data) <- gsub("BodyBody", "Body", names(Data))

## Creates tidy data
DataTidy <- aggregate(. ~subject + activity, Data, mean)
DataTidy <- DataTidy[order(DataTidy$subject, DataTidy$activity),]
write.table(DataTidy, file = "tidydata.txt", row.name=FALSE)
