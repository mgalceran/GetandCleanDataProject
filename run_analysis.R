require("data.table")
require("reshape2")
require("plyr")

# download file
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
fileName <- "./Dataset.zip"
download.file(url, fileName)

# unzip, remove spaces from name, having some issues opening it
system("unzip ./Dataset.zip")
file.rename("UCI\ HAR\ Dataset","UCI")

# read the subject, activity and data files
dtTrainSubject <- fread(file.path("UCI","train","subject_train.txt"))
dtTestSubject <- fread(file.path("UCI","test","subject_test.txt"))
dtTrainActivity <- fread(file.path("UCI", "train", "y_train.txt"))
dtTestActivity  <- fread(file.path("UCI", "test" , "y_test.txt" ))
dtTrain <- fread(file.path("UCI","train", "X_train.txt"))
dtTest  <- fread(file.path("UCI", "test" , "X_test.txt" ))

# merge the test and training sets
dtAllSubject <- rbind(dtTrainSubject, dtTestSubject)
dtAllActivity <- rbind(dtTrainActivity, dtTestActivity)
names(dtAllSubject) <- c("subject")
names(dtAllActivity) <- c("activity")
dtAllSubject <- cbind(dtAllSubject, dtAllActivity)
dt <- rbind(dtTrain, dtTest)
dt <- cbind(dtAllSubject, dt)

# by reading features.txt, extract columns with mean and stddev:
mean_std_columns <- c ("subject","activity","V1","V2","V3","V4","V5","V6","V41","V42","V43","V44","V45","V46","V81","V82","V83","V84","V85","V86","V121","V122","V123","V124","V125","V126","V161","V162","V163","V164","V165","V166","V201","V202","V214","V215","V227","V228","V240","V241","V253","V254","V266","V267","V268","V269","V270","V271","V345","V346","V347","V348","V349","V350","V424","V425","V426","V427","V428","V429","V503","V504","V516","V517","V529","V530","V542","V543")
dt <- dt[, mean_std_columns, with=FALSE]

# use descriptive activity names
dtAct <- fread(file.path("UCI", "activity_labels.txt"))
names(dtAct) <- c("activity","activityName")
dt <- merge(dt, dtAct, by="activity", all.x=TRUE)

# user descriptive column names
dtFeatures <- fread(file.path("UCI", "features.txt"))
names(dtFeatures) <- c("feature", "featureName")
dtFeatures$feature <- paste0("V", dtFeatures$feature)

# melt the table and add feature names
setkey(dt, subject, activity, activityName)
dtMelt <- data.table(melt(dt, key(dt), variable.name="feature"))
dtMelt <- merge(dtMelt, dtFeatures, by="feature", all.x=TRUE)

# distinguish types of features using grep and ifelse
dtMelt$domain <- ifelse(grepl("^t",dtMelt$featureName), "Time","Freq")
dtMelt$sensor <- ifelse(grepl("Gyro",dtMelt$featureName), "Gyroscope", "Accelerometer")
dtMelt$component <- ifelse(grepl("BodyAcc",dtMelt$featureName), "Body", ifelse(grepl("GravityAcc",dtMelt$featureName), "Gravity", NA))
dtMelt$metric <- ifelse(grepl("mean",dtMelt$featureName), "Mean", "Stddev")
dtMelt$axis <- ifelse(grepl("-X",dtMelt$featureName), "X", ifelse(grepl("-Y",dtMelt$featureName), "Y", ifelse(grepl("-Z",dtMelt$featureName), "Z", NA)))
dtMelt$isJerk <- ifelse(grepl("Jerk",dtMelt$featureName), TRUE, FALSE)
dtMelt$isMagnitude <- ifelse(grepl("Mag",dtMelt$featureName), TRUE, FALSE)

# categorize, count and mean by each subject and feature
setkey(dtMelt, subject, activity, domain, sensor, component, metric, isJerk, isMagnitude, axis)
dtFinal <- dtMelt[, list(count = .N, average = mean(value)), by=key(dtMelt)]

# write txt file created with write.table() using row.name=FALSE
write.table(dtFinal,"result.txt",row.name=FALSE)

