## Introduction
In this file, we describe the R script that processes the provided data in
order to produce the required data set.

## The Script
First the script loads the "reshape2" package. If this package is not installed,
please make sure to download it before running the script.

```r
library(reshape2)
```
Then it reads in the data about the subjects, the activities
performed the measurements taken and the activities and measurement
variable names.

```r
subjectTrain <- read.table("./UCI HAR Dataset/train/subject_train.txt")
subjectTest <- read.table("./UCI HAR Dataset/test/subject_test.txt")
activityTrain <- read.table("./UCI HAR Dataset/train/y_train.txt")
activityTest <- read.table("./UCI HAR Dataset/test/y_test.txt")
measurementTrain <- read.table("./UCI HAR Dataset/train/X_train.txt")
measurementTest <- read.table("./UCI HAR Dataset/test/X_test.txt")
actLabels <- read.table("./UCI HAR Dataset/activity_labels.txt")
featureNames <- read.table("./UCI HAR Dataset/features.txt")
```
It then assigns the appropriate names to the measurement variables contained
in the file "features.txt"

```r
names(measurementTrain) <- featureNames$V2
names(measurementTest) <- featureNames$V2
```
Afterwards, it puts the subject, activity and measurment data in data frames
and condenses the training and testing data into one big data frame named
"cmpData". In this complete data frame, the first and second columns are named
"Subject" and "Activity"

```r
cmpDataTrain <- cbind(subjectTrain, activityTrain, measurementTrain)
cmpDataTest <- cbind(subjectTest, activityTest, measurementTest)
cmpData <- rbind(cmpDataTrain, cmpDataTest)
names(cmpData)[1] <- "Subject"
names(cmpData)[2] <- "Activity"
```
The next line, makes sure the activity names are the ones in the file
"activity_labels.txt"

```r
cmpData$Activity <- factor(cmpData$Activity, labels = levels(actLabels$V2))
```
Then, the script extracts from the big data set only the measurements relating
to "mean()"" and "std()"" values. It also extracts the measurements with the "meanFreq()" signifier and places them at the last part of the resulting data frame. This data frame is named "smallDF".

```r
meanVars <- grep("mean()", names(cmpData), fixed = TRUE)
stdVars <- grep("std()", names(cmpData), fixed = TRUE)
meanFreqVars <- grep("meanFreq()", names(cmpData), fixed = TRUE)
smallDF <- cbind(cmpData["Subject"], cmpData["Activity"], cmpData[, meanVars], 
                 cmpData[, stdVars], cmpData[, meanFreqVars])
```
Finally, the script  melts and recasts "smallDF" with respect to each subject 
and each activity in order to create a new one, called "subjectActivity", 
that will contain the average measurments for each subject/activity pair. Each
variable's name in the resulting data frame is prefixed with the string "Avg-" 
in order to suggest that these are not the actual measurements but their average
over a particular subject doing a particular activity.

```r
meltSmallDf <- melt(smallDF, id = c("Subject", "Activity"))
subjectActivity <- dcast(meltSmallDf, Subject + Activity ~ variable, mean)
names(subjectActivity)[3:ncol(subjectActivity)] <- paste("Avg-", 
     names(subjectActivity)[3:ncol(subjectActivity)], sep = "")
```
The two next commands of the script remove the excess variables from the
memory and output the "subjectActivity" data frame in a file named
"subject_activity.txt".

```r
rm(activityTest, activityTrain, actLabels, cmpDataTest, cmpDataTrain,
   featureNames, measurementTest, measurementTrain, meltSmallDF, 
   subjectTest, subjectTrain, meanVars, stdVars, meanFreqVars)
write.table(subjectActivity, file = "subject_activity.txt")
```
The final two commands, are there to help the assignment's markers to
verify the correctness of the output. The first, reads in the file
"subject_activity.txt" and the second one displays the data frame in R Studio's 
Data Viewer.

```r
testSubjectActivity <- read.table("subject_activity.txt", header = TRUE,
                                  check.names = FALSE)
View(testSubjectActivity)
```

## Tidy-data Principles:
The output data can be characterized as tidy since:

1. Each variable is in one column.
2. Each different observation is in a different row.
3. There is one table for each "kind" of variable. The goal of tidying up the
data is to put the measurement data toghether averaged for each subject
performing a particular activity. So at this stage there is no reasong to
break up the variables in multiple tables.
4. For multiple tables, there should be a common column allowing them to be
linked. This principle does not apply here since we only use one table.

Additionally:

* The first row contains the variable names.
* The variable names are descriptive, since they are based in the original
names for each variable prefixed by "Avg-" to denote the averaging that has
been performed.
* All the data of the output table are stored in one file.
The output is a data frame containing the average measurement for each subject
doing a particular activity. The names of the variables as well as their
meaning is given in the seperate codebook.
