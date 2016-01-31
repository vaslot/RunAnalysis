#
# File: run_analysis.R
# Author: Vishal Aslot
# Description:
# This script takes test and train data from the following site and generates an 
# independent tidy dataset as follows:
#
# https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
#
# Step 1: Merges the training and the test sets to create one data set.
# Step 2: Extracts only the measurements on the mean and standard deviation for 
#         each measurement.
# Step 3: Uses descriptive activity names to name the activities in the data set
# Step 4: Appropriately labels the data set with descriptive variable names.
# Step 5: From the data set in step 4, creates a second, independent tidy data 
#         set with the average of each variable for each activity and each subject.
#

library(dplyr)
library(R.utils)
library(reshape2)

# FUNCTION: writeResult(fileName, result)
# DESCRIPTION: Writes out the tidy data set which is in 'result' into 'fileName'
writeResult <- function(fileName, result)
{
        # Before writing the result, delete the old file
        if(file.exists(fileName))
                unlink(fileName)
        write.table(result, file=fileName, row.names=FALSE)
}

# FUNCTION: readXdata(path)
# DESCRIPTION: Read the measured data from the given file indicated by 'path'
# We read in 100 lines at a time in order to save memory and speed up
# file reading on machines with small memory like mine.
readXdata <- function(path, features)
{
        i <- 0
        tmp <- data.frame()
        xData <- data.frame()
        totalLines <- countLines(path, chunkSize = 100)
        repeat
        {
                tmp <- read.fwf(path, widths = rep(16,561), skip = i*100, n=100, col.names = features)
                tmp <- select(tmp, matches("mean|std"))
                xData <- rbind(xData, tmp)
                i<-i+1
                if (nrow(xData) == totalLines[1])
                        break
        }
        xData
}

# FUNCTION: run_analysis()
# DESCRIPTION: This is the main routine. After sourcing this file, do run_analysis() to start
# the analysis.
run_analysis <- function()
{
        # Read in various files
        activityLabels <- read.table("activity_labels.txt") # Descriptive activity labels
        features <- read.table("features.txt") # Descriptive measured and derived variables
        testSubject <- read.table("test/subject_test.txt")
        testLabels <- read.table("test/y_test.txt")
        trainSubject <- read.table("train/subject_train.txt")
        trainLabels <- read.table("train/y_train.txt")

        # Convert the following data.frames into vectors.
        features <- features[,2]
        testLabels <- testLabels[,1]
        testSubject <- testSubject[,1]
        trainLabels <- trainLabels[,1]
        trainSubject <- trainSubject[,1]

        # Read in the data sets. 'features' will give meaning names to each column
        testData <- readXdata("test/X_test.txt", features)
        trainData <- readXdata("train/X_train.txt", features)

        # Append columns for the activity and test subjects
        testData <- mutate(testData, testLabels, testSubject)
        trainData <- mutate(trainData, trainLabels, trainSubject)

        # Convert numeric labels into meaningful names such as 'WALKING' or 'STANDING'
        testData$testLabels <- factor(testData$testLabels, levels = activityLabels[,1], labels = activityLabels[,2]) 
        trainData$trainLabels <- factor(trainData$trainLabels, levels = activityLabels[,1], labels = activityLabels[,2]) 

        # Rename testLabels and trainLabels to Labels
        # Rename testSubject and trainSubject to Subject
        testData <- rename(testData, Labels = testLabels, Subject = testSubject)
        trainData <- rename(trainData, Labels = trainLabels, Subject = trainSubject)

        # Merge (natural join) testData and trainData into a single data set
        td <- merge(testData, trainData, all=TRUE)

        # Melt it so that we get a very long and skinny data set
        melted <- melt(td, id.vars = c("Labels","Subject"))

        # Group the data by activity, test subjects, and features
        grouped <- group_by (melted, Labels, Subject, variable)

        # Generate average by activity and test subjects and print it out
        result <- summarise(grouped, Avg=mean(value))

        # Write out the result to a file
        writeResult("tidy.txt", result)
       
        result # Return result to the caller
}