library(reshape2)
library(data.table)

# Standardize field separating space and remove leading blanks
sedcmd <- "sed -e 's/  */ /g' -e 's/^ //'"

#X_test <- read.table("UCI_HAR_Dataset/test/X_test.txt")
X_test <- fread(paste(sedcmd, "UCI_HAR_Dataset/test/X_test.txt"), data.table=F)
y_test <- fread("UCI_HAR_Dataset/test/y_test.txt")[[1]]
subject_test <- fread("UCI_HAR_Dataset/test/subject_test.txt")[[1]]

#X_train <- read.table("UCI_HAR_Dataset/train/X_train.txt")
X_train <- fread(paste(sedcmd, "UCI_HAR_Dataset/train/X_train.txt"), data.table=F)
y_train <- fread("UCI_HAR_Dataset/train/y_train.txt")[[1]]
subject_train <- fread("UCI_HAR_Dataset/train/subject_train.txt")[[1]]

activity_labels <- fread("UCI_HAR_Dataset/activity_labels.txt", stringsAsFactors=FALSE)
features <- fread("UCI_HAR_Dataset/features.txt", stringsAsFactors=FALSE)[[2]]

msd_cols <- grep("(mean|std)\\(\\)", features, ignore.case=TRUE)
features <- gsub("()", "", features, fixed=TRUE)
features <- gsub("[-,]", ".", features)

colnames(X_test)  <- features
colnames(X_train) <- features
#X_test <- X_test[, !duplicated(colnames(X_test))]
#msd_cols <- intersect(grep("mean|std", names(X_test), ignore.case=TRUE),
#                  grep("^angle", names(X_test), invert=TRUE))
                  
x <- rbind(X_test, X_train)[, msd_cols]

subject <- c(subject_test, subject_train)
activity <- c(y_test, y_train)
x <- cbind(subject, activity, x)
xt <- data.table(x)
setkey(xt, subject, activity)
res <- xt[, lapply(.SD, mean), by=.(subject, activity)]
# Replace activity codes with labels
res[, activity := factor(activity, labels=activity_labels[[2]])]
# Convert to long form
m <- melt(res, id.vars=c("subject","activity"), variable.name="feature", value.name="mean")
