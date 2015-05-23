## Read in the files
library(reshape2)
subjectTrain <- read.table("./UCI HAR Dataset/train/subject_train.txt")
subjectTest <- read.table("./UCI HAR Dataset/test/subject_test.txt")
activityTrain <- read.table("./UCI HAR Dataset/train/y_train.txt")
activityTest <- read.table("./UCI HAR Dataset/test/y_test.txt")
measurementTrain <- read.table("./UCI HAR Dataset/train/X_train.txt")
measurementTest <- read.table("./UCI HAR Dataset/test/X_test.txt")
actLabels <- read.table("./UCI HAR Dataset/activity_labels.txt")
featureNames <- read.table("./UCI HAR Dataset/features.txt")

## Assing the proper variable names for the two measurement data frames.
names(measurementTrain) <- featureNames$V2
names(measurementTest) <- featureNames$V2

## Put the training and test data in two seperate data frames
cmpDataTrain <- cbind(subjectTrain, activityTrain, measurementTrain)
cmpDataTest <- cbind(subjectTest, activityTest, measurementTest)
## Combine the two data frames into one big dataframe that has all the
## required information.
cmpData <- rbind(cmpDataTrain, cmpDataTest)
## Name approprietly the first two collunms of the complete data frame.
## These steps take care of the requirements for step 1 and step 4.
names(cmpData)[1] <- "Subject"
names(cmpData)[2] <- "Activity"

## Name the activities in the data fram with appropriate names. This takes care
## of the requirements of step 3.
cmpData$Activity <- factor(cmpData$Activity, labels = levels(actLabels$V2))

## According to features_info.txt the mean and standard deviation of
## each measurement are the variables containing mean() and std() in their
## name. There are also the meanFreq() variables for which it is not clear
## whether they should be included. So, just for completeness I have placed 
## these variables at the later collumns of the data frame. This steps takes
## care of the extraction required in step 2.
meanVars <- grep("mean()", names(cmpData), fixed = TRUE)
stdVars <- grep("std()", names(cmpData), fixed = TRUE)
meanFreqVars <- grep("meanFreq()", names(cmpData), fixed = TRUE)
smallDF <- cbind(cmpData["Subject"], cmpData["Activity"], cmpData[, meanVars], 
                 cmpData[, stdVars], cmpData[, meanFreqVars])

## smallDF is the data set required by step 4. The data has been merged,
## the appropriate measurementa extracted, the activities appropriately
## named and the variables named correctly. Now we melt and recast this data
## frame with respect to each subject and each activity in order to create
## a new one that will contain the average measurments for each
## subject/activity pair. Each variable's name in the resulting data frame is
## prefixed with the string "Avg-" in order to suggest that these are not
## the actual measurements but their average over a particular subject doing
## a particular activity.
meltSmallDF <- melt(smallDF, id = c("Subject", "Activity"))
subjectActivity <- dcast(meltSmallDF, Subject + Activity ~ variable, mean)
names(subjectActivity)[3:ncol(subjectActivity)] <- paste("Avg-", 
     names(subjectActivity)[3:ncol(subjectActivity)], sep = "")

## Remove excess variables and output the last data frame
rm(activityTest, activityTrain, actLabels, cmpDataTest, cmpDataTrain,
   featureNames, measurementTest, measurementTrain, meltSmallDF, 
   subjectTest, subjectTrain, meanVars, stdVars, meanFreqVars)
write.table(subjectActivity, file = "subject_activity.txt", row.name = FALSE)

## Read in the output. This is additional code to help the assignment's markers
## test the correctness of the output.
testSubjectActivity <- read.table("subject_activity.txt", header = TRUE,
                                  check.names = FALSE)
View(testSubjectActivity)