##################################################
#   
#   run_analysis.R
#
#   Author: bsheepy
#
#   To create a tidy data set from the Human Activity 
#   Recognition Using Smartphones Dataset
#
##################################################

# 1. download the data into a temporary directory, extract the data needed 
#    and read it into r, delete the temporary directory

temp <- tempdir()
if(!dir.exists(temp)){dir.create(temp)}
dataURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(dataURL,paste(temp, "/UCI HAR Dataset.zip", sep = "" ))

subject_test <- read.table(unz(paste(temp, "./UCI HAR Dataset.zip", sep = ""), "UCI HAR Dataset/test/subject_test.txt"))
X_test <- read.table(unz(paste(temp, "./UCI HAR Dataset.zip", sep = ""), "UCI HAR Dataset/test/X_test.txt"))
Y_test <- read.table(unz(paste(temp, "./UCI HAR Dataset.zip", sep = ""), "UCI HAR Dataset/test/y_test.txt"))

subject_train <- read.table(unz(paste(temp, "./UCI HAR Dataset.zip", sep = ""), "UCI HAR Dataset/train/subject_train.txt"))
X_train <- read.table(unz(paste(temp, "./UCI HAR Dataset.zip", sep = ""), "UCI HAR Dataset/train/X_train.txt"))
Y_train <- read.table(unz(paste(temp, "./UCI HAR Dataset.zip", sep = ""), "UCI HAR Dataset/train/y_train.txt"))

columnnames<-read.table(unz(paste(temp, "./UCI HAR Dataset.zip", sep = ""), "UCI HAR Dataset/features.txt"))
activity_labels<-read.table(unz(paste(temp, "./UCI HAR Dataset.zip", sep = ""), "UCI HAR Dataset/activity_labels.txt"))

unlink(temp)

# 2. Appropriately label the data set with descriptive variable names

names(X_test) <- columnnames$V2
names(X_train) <- columnnames$V2
names(subject_test) <- "subject"
names(subject_train) <- "subject"
names(Y_test) <- "activity"
names(Y_train) <- "activity"

# 3. Merge the train and test data together

testdata <- cbind(subject_test,X_test,Y_test)
traindata <- cbind(subject_train,X_train,Y_train)
totalData <-rbind(testdata,traindata)

# 3. Rename activity values to be more useful

totalData$activity <- activity_labels[,2][match(totalData$activity, activity_labels[,1])]

# 4. Extract only the measurements on the mean and standard deviation 
#    for each measurement. 

meanstdData <- totalData[ , grepl("-mean[^F]|-std|subject|activity", names(totalData))]
library(tidyr)
meanstdData <- gather(meanstdData, subject, activity)
names(meanstdData) <- c("subject","activity","measurement","value")

# 5. Create a second, independent tidy data set with the average of each 
#    variable for each activity and each subject.

library(dplyr)
groups <- group_by(meanstdData, subject, activity, measurement)
newData <- summarise_each(groups, funs(mean))

# 6. Write the data set to file

if(!dir.exists("./data")){dir.create("./data")}
write.table(newData, file = "./data/tidyData.txt", row.name=FALSE)




