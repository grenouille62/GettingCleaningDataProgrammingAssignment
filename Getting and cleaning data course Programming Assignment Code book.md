Getting and cleaning data course Programming Assignment Code book
===================

----------


General purpose
-------------

The dataset "Human_Activity_Recognition_Using_Smartphones_Tidy_DataSet.txt" is produced from the original datasets "UCI HAR Dataset". The description of this datasets is available here http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones#
The dataset "Human_Activity_Recognition_Using_Smartphones_Tidy_DataSet.txt" provide the average measurements of features, group by activity and subject

Cleaning up and tidying dataset
-------------

**The problems** 
> - Many variables in the original dataset are duplicates. 
> - Many variables in the original dataset have special characters in their names
> - The data are split in several files : subject, activity, measurements

**The solutions** 
> - Eliminate duplicate variables 
> - Rename variables by replacing special characters with "_"
> - Merge data into one dataframe

**Producing tidy dataset** 
> -  Use sqldf library for very convenient standard SQL : select ... from ... group by ...



#### <i class="icon-folder-open"></i> Code book
The dataset format is a text file with tab separator.
activityLabel : activity label. Possible values :

>- WALKING
>- WALKING_UPSTAIRS
>- WALKING_DOWNSTAIRS
>- SITTING
>- STANDING
>- LAYING

subjectID : id of subjects who participate to the experimentation. Possible values :
>-  Range from 1 to 30

Remaining variables : average of original mean and standard deviation measurements.

