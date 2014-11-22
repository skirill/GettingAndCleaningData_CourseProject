# Getting and Cleaning Data Course Project

This directory contains the following files

- *run_analysis.R* is an R script implementing the course project. The script assumes that a file
"getdata_projectfiles_UCI HAR Dataset.zip" is present in the working directory. It is not necessary
to extract files from that archive. The script also uses a small vocabulary called "rename_features.txt"
to give better names to the feature columns. Each numbered clause in a task description is mapped to a
top-level R function. Follow the descriptive comments in the script for more information.

- *rename_features.txt* is a vocabulary for feature renaming that contains old and new text strings
for each rename. The script uses regular expression to break feature names down to their components
and then uses the vocabulary to build a more readable name.

- *tidy_dataset.txt* is a resulting dataset serialized as required in a task description. Provided for reference only.
