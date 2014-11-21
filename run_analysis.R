read_merge_datasets <- function()
{
    # set to -1 to read all data
    nr <- -1
    #nr <- 10
    
    archive         <-  "getdata_projectfiles_UCI HAR Dataset.zip"
    
    features        <<- read.table(unz(archive, "UCI HAR Dataset/features.txt"), col.names=c("num", "name"))
    activities      <<- read.table(unz(archive, "UCI HAR Dataset/activity_labels.txt"), col.names=c("num", "name"))
    
    X_train         <-  read.table(unz(archive, "UCI HAR Dataset/train/X_train.txt"), nrows=nr)
    y_train         <-  read.table(unz(archive, "UCI HAR Dataset/train/y_train.txt"), col.names="activity", nrows=nr)
    subject_train   <-  read.table(unz(archive, "UCI HAR Dataset/train/subject_train.txt"), col.names="subject", nrows=nr)
    
    X_test          <-  read.table(unz(archive, "UCI HAR Dataset/test/X_test.txt"), nrows=nr)
    y_test          <-  read.table(unz(archive, "UCI HAR Dataset/test/y_test.txt"), col.names="activity", nrows=nr)
    subject_test    <-  read.table(unz(archive, "UCI HAR Dataset/test/subject_test.txt"), col.names="subject", nrows=nr)
    
    X_merged        <-  rbind(X_train, X_test)
    y_merged        <-  rbind(y_train, y_test)
    subject_merged  <-  rbind(subject_train, subject_test)
    
    names(X_merged) <-  features$name
    
    merged          <<- cbind(subject_merged, y_merged, X_merged)

    renames         <<- read.table("rename_features.txt", col.names=c("old", "new"))
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
        n2<-gsub("BodyBody", "Body", name)

        matches<-regexec("^([ft])([A-Z][a-z]+)([A-Z][a-z]+)([A-Z][a-z]+)?([A-Z][a-z]+)?-(mean|std)\\(\\)(-X|-Y|-Z)?$", n2)
        parts<<-unlist(regmatches(n2,matches))[2:8]
        res <- NA
        for (i in 1:length(parts))
        {
            part <- parts[i]
            if (part != "" && part != "()")
            {
                rename = renames[renames$old==part, "new"]
                if (length(rename) == 0)
                {
                    if (i==length(parts))
                    {
                        rename <- substr(part, 2, 2)
                    }
                    else
                    {
                        rename <- tolower(part)
                    }
                }
                if (is.na(res))
                {
                    res = rename
                }
                else
                {
                    res <- paste(res, rename, sep="-")    
                }
            }
        }
        res
    }
    
    # Rename all but the first 3 columns. Create better names here.
    pretty_names <- sapply(names(mean_std)[4:ncol(mean_std)], pretty_name_variable)
    # Apply them
    names(mean_std) <<- c(names(mean_std)[1:3], pretty_names)
}

create_tidy_dataset<-function()
{
    # start with an empty dataframe with same columns as mean_std
    res <- mean_std[0,]
    
    subjs<-sort(unique(mean_std$subject))
    acts<-sort(unique(mean_std$activity))
    
    for (subj in subjs)
    {
        for (act in acts)
        {
            # create next row by taking one row of mean_std (no matter which one) and replacing data there with whet we want
            row <- mean_std[1,]
            row$subject[1]<-subj
            row$activity[1]<-act
            row$activityname[1]<-activities[activities$num==act,"name"]
            
            row[1,4:ncol(mean_std)] <- colMeans(mean_std[mean_std$subject==subj & mean_std$activity==act,4:ncol(mean_std)])
            
            # append data to net result
            res <- rbind(res, row)
        }
    }
    
    # publish net result to global namespace
    mean_std_avg <<- res
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
    create_tidy_dataset()
    
    # Please upload the tidy data set created in step 5 of the instructions. Please upload your
    # data set as a txt file created with write.table() using row.name=FALSE (do not cut and paste
    # a dataset directly into the text box, as this may cause errors saving your submission).
    write.table(mean_std_avg, file = "tidy_dataset.txt", sep="\t", row.names=F)
}
