setwd("C:/Users/Adrian/Documents/R/coursera/getdata-035/UCI HAR Dataset/")

# You should create one R script called run_analysis.R that does the following. 
# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names. 
# 5. From the data set in step 4, creates a second, independent tidy data set 
# with the average of each variable for each activity and each subject.

# for comments that explain the code, 
# please see the RMD file CodeBook.RMD which containts all this code.

library(dplyr)
subjecttest <- read.table("subject_test.txt", header = FALSE)
subjecttrain <- read.table("subject_train.txt", header = FALSE)
features <- read.table("features.txt", header = FALSE)
activitylabels <- read.table("activity_labels.txt", header = FALSE)
xtest <- read.table("X_test.txt", header = FALSE)
xtrain <- read.table("X_train.txt", header = FALSE)
ytest <- read.table("y_test.txt", header = FALSE)
ytrain <- read.table("y_train.txt", header = FALSE)


xdata <- rbind(xtrain, xtest)
ydata <- rbind(ytrain, ytest)
alldata <- cbind(ydata, xdata)

features$V3 <- make.names(features$V2, unique = TRUE)
names(alldata) <- c("activitynum", features$V3)
alldata <- cbind(
  select(alldata, activitynum), 
  select(alldata, contains("mean")), 
  select(alldata, contains("std"))
)

subject <- rbind(subjecttrain, subjecttest)
names(subject) <- "subject"
alldata <- cbind(subject, alldata)
names(activitylabels) <- c("num", "activity")
alldata <- merge(
  x = activitylabels, y = alldata, 
  by.x = "num", by.y = "activitynum", 
  all = TRUE)

alldata <- subset(alldata, select = -num)
alldata <- group_by(alldata, activity, subject)
tidy <- summarize_each(alldata, funs(mean))
ungroup(alldata)

write.table(x = tidy, file = "tidydata.txt", row.names = FALSE)
