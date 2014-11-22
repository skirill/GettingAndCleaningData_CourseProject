# Getting and Cleaning Data Course Project Code Book

This document assumes you have read the original *Human Activity Recognition Using Smartphones Dataset*
code book consisting of the .txt files at the top level in the zip archice constituting the data set.
It amends that code book with the description of transformations applied according to the task definition.

## Reading ans merging the data sets

- Training and test datasets are read as whitespace-separated tables usingthe files X_...txt, y_...txt, subject_...txt
from the *train* and *test* subdirectories of the original data set. Data from the last 2 files is prepended as 2
extra columns *subject* and *activity* to the main measurement data. Then both datasets are merged into the variable
*merged* in global namespace. This variable contains all features from the original data set. 
- Feature names are taken from the file *features.txt*, applied to the merged data set and set to the global
variable *features*.
- Activity names are read from the file *activity_labels.txt* and set to the *activities* global variable.
- Feature renaming vocabilary is reaad to the variable *renames*.

## Extracting only mean and standard deviations

A subset by column using a regular expression searching for "-mean()" or "-std()" in a column name is used. It was
checked that all matching columns are relevant. Resulting dataset with less columns is published as *mean_std* global
variable.

## Giving pretty names to activities

A column *activitynames* is added to the data set using the mapping from *activities* variable. A column is prodiced
as a separate vector using sapply() and then inserded to the middle of a data frame using cbind() and column index
permutation. 

## Giving pretty names to variables

It was decided to apply the following renaming to parts of the feature name:

t		time
f		freq
Acc		acceleration
Gyro		velocity
Mag		magnitude

Other parts are lowercased and joined with hyphen, () removed. this gives human readable names like

time-body-acceleration-jerk-std-Z
time-body-velocity-mean-X

Renaming is done using the *remanes* variable; parts of the original name are captured with a regular exression and then
rejoined with a loop in a function *pretty_name_variable()*. The function als renames strange "BodyBody" string to "Body".
It is used by the top-level function that does sapply to generate vector of new names for all variable cloumns and then 
sets these names so that they are globally visible.

## Creating ans seving a tidy data set

Tidy data set is created by repeated subsetting of the original data set, taking colMeans() for the subset and appending it
as an extra row to the result. Subsetting factors are chosen directly from the original data using the unique() function and
sorted with sort(). Data is saved with write.table() as required.

It was originally anticipated that this solution will be slow and will require some nicer R-style code such as factoring,
sapply(), pre-allocating a data frame etc. but the performance turned out to be sufficient for the particular task so it
was left as is.
