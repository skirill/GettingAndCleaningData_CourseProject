read_merge_datasets <- function()
{
    archive         <-  "getdata_projectfiles_UCI HAR Dataset.zip"
    
    features        <<- read.table(unz(archive, "UCI HAR Dataset/features.txt"), col.names=c("num", "name"))
    activities      <<- read.table(unz(archive, "UCI HAR Dataset/activity_labels.txt"), col.names=c("num", "name"))
    
    X_train         <-  read.table(unz(archive, "UCI HAR Dataset/train/X_train.txt"), nrows=10)
    y_train         <-  read.table(unz(archive, "UCI HAR Dataset/train/y_train.txt"), col.names="activity", nrows=10)
    subject_train   <-  read.table(unz(archive, "UCI HAR Dataset/train/subject_train.txt"), col.names="subject", nrows=10)
    
    X_test          <-  read.table(unz(archive, "UCI HAR Dataset/test/X_test.txt"), nrows=10)
    y_test          <-  read.table(unz(archive, "UCI HAR Dataset/test/y_test.txt"), col.names="activity", nrows=10)
    subject_test    <-  read.table(unz(archive, "UCI HAR Dataset/test/subject_test.txt"), col.names="subject", nrows=10)
    
    X_merged        <-  rbind(X_train, X_test)
    y_merged        <-  rbind(y_train, y_test)
    subject_merged  <-  rbind(subject_train, subject_test)
    
    names(X_merged) <-  features$name
    
    merged          <<- cbind(subject_merged, y_merged, X_merged)
}

extract_mean_std <- function()
{
    # Take subject, activity (col #1 and #2) and all measurements that end with -mean() or -std() 
    # with optional trailer like -X to the resulting data set
    mean_std        <<- merged[,c(1,2,grep(".*(-mean|-std)\\(\\).*", names(merged)))]
}

pretty_name_activities <- function()
{
    # generate a column with activity names using the activities vocabulary table
    activityname <<- sapply(mean_std$activity, function(num) activities[activities$num==num, "name"])
    # add a column with names after a column with activity numbers (leave numbers there too just in case)
    mean_std <<- cbind(activityname, mean_std)[c(2,3,1,4:ncol(mean_std))]
}

pretty_name_variables <- function()
{
    pretty_name_variable <- function(name)
    {
        #gsub("mean", "XXX", name)
        # TODO clever rename
        name
    }
    
    names(mean_std) <- sapply(names(mean_std), pretty_name_variable)
}

# You should create one R script called run_analysis.R that does the following. 
run_analysis<-function()
{
    # Merges the training and the test sets to create one data set.
    read_merge_datasets()

    # Extracts only the measurements on the mean and standard deviation for each measurement. 
    extract_mean_std()
    
    # Uses descriptive activity names to name the activities in the data set
    pretty_name_activities()
    
    # Appropriately labels the data set with descriptive variable names. 
    pretty_name_variables()
    
    # From the data set in step 4, creates a second, independent tidy data set with the average
    # of each variable for each activity and each subject.
}
