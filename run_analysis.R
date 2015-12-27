setwd("C:/Users/Adrian/Documents/R/coursera/getdata-035/UCI HAR Dataset/")

# You should create one R script called run_analysis.R that does the following. 
# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names. 
# 5. From the data set in step 4, creates a second, independent tidy data set 
# with the average of each variable for each activity and each subject.

# First I read in the data. Variable names are pretty self-explanatory. I just removed the underscores.
library(dplyr)
subjecttest <- read.table("subject_test.txt", header = FALSE)
subjecttrain <- read.table("subject_train.txt", header = FALSE)
features <- read.table("features.txt", header = FALSE)
activitylabels <- read.table("activity_labels.txt", header = FALSE)
xtest <- read.table("X_test.txt", header = FALSE)
xtrain <- read.table("X_train.txt", header = FALSE)
ytest <- read.table("y_test.txt", header = FALSE)
ytrain <- read.table("y_train.txt", header = FALSE)

# I use rbind() to row-bind the xtrain and xtest sets, in that order. The new data is called xdata.
# I do the same (in the same order) for the Y data. Then I use cbind() to bind ydata and xdata.
# The new variable is called alldata. Task 1 is complete.
xdata <- rbind(xtrain, xtest)
ydata <- rbind(ytrain, ytest)
alldata <- cbind(ydata, xdata)

# Extracts only the measurements on the mean and standard deviation for each measurement. 
# To do this, I want to rename the column names away from "V550" etc. to "features.txt".
# I want unique column names, but features has duplicate names, resulting in:
# "Error: found duplicated column name: etc. etc."
# So I use the make.names() function to make them into unique names in a new column in features.
# Thanks to Saeid Abolfazli in the forums for this.
# However because I cbinded ydata and xdata into alldata, I need to put the name for the single columm of ydata in there first.
# Then I can use the select() and contains() functions to get only the variables with names that contain "mean" or "std".
# That doesn't include the activity type from ydata, so I have to add that in too.
# After this, alldata contains only the ydata, the data with means, and the data with standard deviations.
features$V3 <- make.names(features$V2, unique = TRUE)
names(alldata) <- c("activitynum", features$V3)
alldata <- cbind(
  select(alldata, activitynum), 
  select(alldata, contains("mean")), 
  select(alldata, contains("std"))
)

# Uses descriptive activity names to name the activities in the data set
# To do this, I want to merge the activitylabels dataframe with my data.
# However merge re-orders the data, so I can only use it after I've rbinded/cbinded everything together.
subject <- rbind(subjecttrain, subjecttest)
names(subject) <- "subject"
alldata <- cbind(subject, alldata)
names(activitylabels) <- c("num", "activity")
alldata <- merge(
  x = activitylabels, y = alldata, 
  by.x = "num", by.y = "activitynum", 
  all = TRUE)

# Appropriately labels the data set with descriptive variable names. 
# I did this already in Task 2 with make.names().

# From the data set in step 4, creates a second, independent tidy data set
# with the average of each variable for each activity and each subject.
# To do this, I first delete the activitynum from the dataset (because it duplicates the activity name field),
# then group by activity and subject, then use the summarize_each() function. The new tidy data set is called "tidy."

alldata <- subset(alldata, select = -num)
alldata <- group_by(alldata, activity, subject)
tidy <- summarize_each(alldata, funs(mean))
ungroup(alldata)

write.table(x = tidy, file = "tidydata.txt", row.names = FALSE)
