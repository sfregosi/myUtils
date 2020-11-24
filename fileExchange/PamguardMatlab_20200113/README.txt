This Matlab library is provided “as is” under the terms of the GPL3 license agreement. It is intended to be used by people who want to take their analysis beyond what is possible within PAMGuard, for instance, during the development of a new type of classifier or for export of data for the next stage of your project. It is intended for use by those already proficient in Matlab.  The library includes submissions from users as well as the Pamguard team.

There is no overall help file for the Matlab library, although you will find limited help within the functions themselves.  Type >>help {functionName} for more details on how to use these functions.

When analysing binary files created from Pamguard beta releases (version 2.xx.xx +), the functions you’re most likely to use are found in the BinaryFiles folder.  There are 2 main functions, and are not dependant on the type of data:
>>[dataSet, fileInfo] = loadPamguardBinaryFile(fileName, varargin) which loads all of the data from within a single Binary file
>>data = loadPamguardBinaryFolder(dir, fileMask, verbose) which loads all of the data from multiple files within a folder and sub folders.
The exact format the data take will depend on the detector. Most are reasonably obvious when you look at the structures read into Matlab.

When analysing binary files created from Pamguard core releases (version 1.xx.xx +), the functions you need will all be found in the BinaryFiles/Legacy subfolder.  The functions are specific to the type of data to be analyzed - to load data from the Whistle & Moan Detector, for instance, you would use this command:
>>[tones fileHeader fileFooter moduleHeader moduleFooter] = loadWhistleFile(fileName);
The exact format the data take will depend on the detector. Most are reasonably obvious when you look at the structures read into Matlab.

When reading in SQLite database data, use the functions found in the DatabaseFiles folder.  Note that you need to have the database toolbox installed in Matlab in order to run these scripts.




 

 