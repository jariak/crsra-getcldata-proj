# Coursera: Getting and Cleaning Data, Course Project
#
# run_analysis.R
#
# Produces a tidy dataset of the mean and standard deviation related variables
# of the original data, averaged and grouped by subject and activity.

library(reshape2)
library(data.table)

# Fetch and unzip dataset if not exists in the working directory
if (!file.exists("UCI HAR Dataset")) {
    fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    tmp.file <- tempfile()
    download.file(fileURL, destfile=tmp.file, method="curl")
    unzip(tmp.file)
    unlink(tmp.file)
}

# sed command to standardize field separating space and to remove leading blanks
# from the large test and training data files (X_test.txt and X_train.txt) 
# before reading in with fread(). sed is a common utility installed by default 
# on all Linux/Mac OS's, and available for free on every platform that has a 
# version of R. fread() is about tenfold faster than standard read.table(), so 
# it's worth some effort to make it work as smooth as possible. This piece of 
# preprocessing should be unnecessary, but it prevented fread() from crashing on
# my Linux system when reading those two large data files.
#
# However, in the final version of this script I commented out the parts that
# used sed, and replaced them with standard read.table() calls to remove any
# reliance on software outside R packages, to make it easy to verify the script
# on any platform.
sedcmd <- "sed -e 's/  */ /g' -e 's/^ //'"

# Read in test set data
#X_test <- fread(paste(sedcmd, "'UCI HAR Dataset/test/X_test.txt'"))      # sed
X_test <- as.data.table(read.table("UCI HAR Dataset/test/X_test.txt"))    # standard (slow)
y_test <- fread("UCI HAR Dataset/test/y_test.txt")[[1]]
subject_test <- fread("UCI HAR Dataset/test/subject_test.txt")[[1]]

# Read in training set data
#X_train <- fread(paste(sedcmd, "'UCI HAR Dataset/train/X_train.txt'"))   # sed
X_train <- as.data.table(read.table("UCI HAR Dataset/train/X_train.txt")) # standard (slow)
y_train <- fread("UCI HAR Dataset/train/y_train.txt")[[1]]
subject_train <- fread("UCI HAR Dataset/train/subject_train.txt")[[1]]

# Read in the activity labels and features
activity_labels <- fread("UCI HAR Dataset/activity_labels.txt", stringsAsFactors=FALSE)
features <- fread("UCI HAR Dataset/features.txt", stringsAsFactors=FALSE)[[2]]

# Find all features that include 'mean()' or 'std()' in their names
meansd_cols <- grep("(mean|std)\\(\\)", features, ignore.case=TRUE)

# Clean up the feature names by removing all parenthesis and 
# substituting slashes and commas with dots
features <- gsub("()", "", features, fixed=TRUE)
features <- gsub("[-,]", ".", features)

# Set clean feature column names to training and testing data
setnames(X_test, features)
setnames(X_train, features)

# Combine testing and training data, but get only the mean/sd columns
x_meansd <- rbind(X_test, X_train)[, meansd_cols, with=FALSE]

# Combine testing and training subject and activity columns and add them to the X data as key
subject <- c(subject_test, subject_train)
activity <- c(y_test, y_train)
x_meansd <- cbind(subject, activity, x_meansd)
setkey(x_meansd, subject, activity)

# Count the means of each feature per subject and activity
res <- x_meansd[, lapply(.SD, mean), by=.(subject, activity)]

# Replace activity codes with labels
res[, activity := factor(activity, labels=activity_labels[[2]])]

# Convert result to long form for final output
melted <- melt(res, id.vars=c("subject","activity"), variable.name="feature", value.name="average")

# Write tidy data in output file
# (Read back in with: read.table("subj_act_feat_average.txt", header=TRUE)
write.table(melted, "subj_act_feat_average.txt", row.names=FALSE, quote=FALSE)
