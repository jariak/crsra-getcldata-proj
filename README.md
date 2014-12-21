# Tidy Averaged Subset of Human Activity Recognition Using Smartphones Data

### Overview

This repository contains an R script `run_analysis.R` that produces a tidy, averaged subset of the public data from recordings of 30 subjects performing activities of daily living (ADL) while carrying a waist-mounted smartphone with embedded inertial sensors. See `README.txt` in the original dataset for more details about the original project and the different files included in the dataset.

We are interested only about the mean and standard deviation related variables of the dataset, and want to group and average them by each subject and activity.

### Original dataset

[Link to original project](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones)

[Link to original dataset](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip)

If the dataset is not found in the current working directory, the `run_analysis.R` script downloads and unzips it automatically from the above dataset source URL.

### Script

**Required R packages:**
- reshape2
- data.table

**Input files from the original dataset:**
- UCI HAR Dataset/activity_labels.txt
- UCI HAR Dataset/features.txt
- UCI HAR Dataset/test/X_test.txt
- UCI HAR Dataset/test/y_test.txt
- UCI HAR Dataset/test/subject_test.txt
- UCI HAR Dataset/train/X_train.txt
- UCI HAR Dataset/train/y_train.txt
- UCI HAR Dataset/train/subject_train.txt

The `run_analysis.R` script first merges the training and test sets into one big dataset (test set rows first and then the training set rows at the bottom, though order is not important considering the final output). The subject and activity files are combined in the same manner. In our case we are interested only in the measurements of mean and standard deviation for each measurement. The specific variables are recognized by their feature names by searching substrings "mean()" and "std()", respectively. This reduces the original set of 561 variables for each measurement down to 66.

The remaining feature names are also slightly edited by removing parentheses and replacing slashes and commas by periods make them valid variable names in R, and more readable to the human eye as well. No further refinement is done to keep the link to the original feature names as obvious as possible and to make referring to the original variables trivial. For the same reason, the activity labels are provided as is in the `activity_labels.txt` file of the original dataset.

The output dataset provides the averages of the 66 extracted features, grouped by each subject and activity. As there are 30 subjects and 6 activities for each subject, the final dataset contains a total of 180X66 values. These 11880 values are delivered in long format, where each row contains only a single measurement (column name `average`), identified by `subject`, `activity` and `feature`. See [CodeBook.md](CodeBook.md) for further details.

Long format is convenient for further analysis, and can easily be cast back to wide format (where each feature has its own column), if so desired.

The reported average values are in exactly same units as the input data (i.e. from normalised values between -1 and 1).

### Output

The output of `run_analysis.R` is written into a file named `subj_act_feat_average.txt` and can be read back into R with command:
```r
read.table("subj_act_feat_average.txt", header=TRUE)
```
Here is a short sample of the first six rows of the output (as it appears printed in the R console):
```
   subject           activity         feature   average
1:       1            WALKING tBodyAcc.mean.X 0.2773308
2:       1   WALKING_UPSTAIRS tBodyAcc.mean.X 0.2554617
3:       1 WALKING_DOWNSTAIRS tBodyAcc.mean.X 0.2891883
4:       1            SITTING tBodyAcc.mean.X 0.2612376
5:       1           STANDING tBodyAcc.mean.X 0.2789176
6:       1             LAYING tBodyAcc.mean.X 0.2215982
```
