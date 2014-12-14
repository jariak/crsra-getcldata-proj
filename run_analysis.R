library(reshape2)
library(data.table)

# To standardize field separating space and remove leading blanks from the X-files
# before reading in with fread(). Sed is installed by default in all Linux/Mac OSs.
# Could use standard read.table() instead, but fread() is about tenfold faster,
# so it is worth some effort to make it work as smooth as possible. This piece of
# preprocessing made fread() more stable on my Linux system. The data.table package
# is still quite fresh, and this will hopefully become unnecessary in the future.
sedcmd <- "sed -e 's/  */ /g' -e 's/^ //'"

# Read in test set data
X_test <- fread(paste(sedcmd, "UCI_HAR_Dataset/test/X_test.txt"))
y_test <- fread("UCI_HAR_Dataset/test/y_test.txt")[[1]]
subject_test <- fread("UCI_HAR_Dataset/test/subject_test.txt")[[1]]

# Read in training set data
X_train <- fread(paste(sedcmd, "UCI_HAR_Dataset/train/X_train.txt"))
y_train <- fread("UCI_HAR_Dataset/train/y_train.txt")[[1]]
subject_train <- fread("UCI_HAR_Dataset/train/subject_train.txt")[[1]]

# Read in the activity labels and features
activity_labels <- fread("UCI_HAR_Dataset/activity_labels.txt", stringsAsFactors=FALSE)
features <- fread("UCI_HAR_Dataset/features.txt", stringsAsFactors=FALSE)[[2]]

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
subject.id <- c(subject_test, subject_train)
activity <- c(y_test, y_train)
x_meansd <- cbind(subject.id, activity, x_meansd)
setkey(x_meansd, subject.id, activity)

# Count the means of each feature per subject and activity
res <- x_meansd[, lapply(.SD, mean), by=.(subject.id, activity)]

# Replace activity codes with labels
res[, activity := factor(activity, labels=activity_labels[[2]])]

# Convert to long form
m <- melt(res, id.vars=c("subject.id","activity"), variable.name="feature", value.name="mean")

# Write tidy data
#write.table(m, "m.txt", row.names=FALSE, quote=FALSE)
