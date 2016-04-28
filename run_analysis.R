
# Download project data file
if (!file.exists("data")) {
    dir.create("data")
}
fileUrl = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, "./data/uci_har.zip")
dateDownloaded <- date()

# Extract the data files
unzip("./data/uci_har.zip", exdir = "./data")

# Load subject data
subjectTest <- read.table("./data/UCI HAR Dataset/test/subject_test.txt"
                          , sep = " ", encoding = "UTF-8")
subjectTrain <- read.table("./data/UCI HAR Dataset/train/subject_train.txt"
                           , sep = " ", encoding = "UTF-8")

# Merge subject data
subject <- rbind(subjectTest, subjectTrain)
names(subject) <- c("subject")

# Load activity label
activityLabel <- read.table("./data/UCI HAR Dataset/activity_labels.txt"
                            , sep = " ", encoding = "UTF-8")
names(activityLabel) <- c("label_id", "label_name")

# Load list of all features
feature <- read.table("./data/UCI HAR Dataset/features.txt"
                      , sep = " ", encoding = "UTF-8")
names(feature) <- c("feature_id", "feature_name")

# Load test label
yTest <- read.table("./data/UCI HAR Dataset/test/y_test.txt"
                    , sep = " ", encoding = "UTF-8")

# Load training label
yTrain <- read.table("./data/UCI HAR Dataset/train/y_train.txt"
                     , sep = " ", encoding = "UTF-8")

# Combine label data
y <- rbind(yTest, yTrain)
names(y) <- c("label_id")

# Load test set
xTest <- read.fortran("./data/UCI HAR Dataset/test/X_test.txt", c("561F16"), fileEncoding = "UTF-8")

# Load training set
xTrain <- read.fortran("./data/UCI HAR Dataset/train/X_train.txt", c("561F16"), fileEncoding = "UTF-8")

# Combine the training and the test sets to create one data set
x <- rbind(xTest, xTrain)

# Appropriately labels the data set with descriptive variable names
names(x) <- feature$feature_name

# Combine subject, label and set data
yx <- cbind(subject, y, x)

# Merge with activity label to get descriptive activity names
z <- merge(yx, activityLabel, by = "label_id", sort = FALSE)

# Extracts only the mean and standard deviation for each measurement
tidy1 <- z[ , grep("std|mean|label_name|subject", names(z))]

# Tidy up the variable names
names(tidy1) <- sub("\\()", "", names(tidy1))

# Average of each variable for each activity and each subject
tidy2 <- tidy1 %>% group_by(subject, label_name) %>% summarise_each(funs(mean))

# Write output to text file
write.table(tidy2, file = "./data/activity_mean.txt", row.names = FALSE)

