# README.md
#
#### The script that generates a tidy data set of averages of features by 
#### activity and test subject is described below.

File: run_analysis.R
Author: Vishal Aslot
Description: This script takes test and train data from the following site and generates an independent tidy dataset as follows:

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

Step 1: Merges the training and the test sets to create one data set.
Step 2: Extracts only the measurements on the mean and standard deviation for each measurement.
Step 3: Uses descriptive activity names to name the activities in the data set
Step 4: Appropriately labels the data set with descriptive variable names.
Step 5: From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

To load the script and run it do the following steps in R:

**> source("run_analysis.R"); run_analysis()**

The output is dumped into a text file called **tidy.txt**.
