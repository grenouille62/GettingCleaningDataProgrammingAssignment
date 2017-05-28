# GettingCleaningDataProgrammingAssignment

Step 0 : install and load the needed libraries
>- dplyr
>- stringr
>- sqldf : this library is particularely convenient for standard SQL

>-Step 1 : Load activity labels into a dataframe and label the columns
>-Step 2 : Load Feature labels
>-Step 3 : Clean up feature labels : replace the special characters as with appropriate one
all () are replaced with empty string
all ) are replaced with empty string
all , are replaced with _
all ( are replaced with _
all - are replaced with _



>-Step 4 : Load Test set measurements data and Trainnig set measurements data
>-Step 5 : Load subjects

>-Step 6 : Load activity observation
>-Step 7 : Complete variables subjectID and activityLabel into dataset

>-Step 8 : Merges the training and the test sets to create one data set

>-Step 9 :  Extracts only the measurements on the mean and standard deviation for each measurement. 

>-Step 10 : creates an independent tidy data set with the average of each variable for each activity and each subject

>-Step 11 : Write the tidy data to a txt file with tab separator
