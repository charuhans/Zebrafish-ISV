Software Requirement
1) Install Fiji from https://fiji.sc/#download
   Windows 64 bit
   
2) Use MATLAB R2017b or later, which uses JAVA 1.8+ as Fiji does.
   Use the following command to check the JAVA version of MATLAB matlab version -java
   

Setup Matlab for fiji
1) Run following commands on Matalab Console
   addpath 'D:\Fiji.app\scripts\' % depends your Fiji installation
   
2) Add the update site of ImageJ-MATLAB (i.e. http://sites.imagej.net/MATLAB/) in Fiji 
   Open Fiji, then select Help>Update…>Manage Update Sites>ImageJ-MATLAB>Close>Apply Changes 
   More details are here:http://imagej.net/Following_an_update_site
   
3) Run following commands on Matalab Console 
   javaaddpath 'C:\Program Files\MATLAB\R2017b\java\jar\mij-1.3.6-fiji2-SNAPSHOT.jar' % depends your Fiji installation
   javaaddpath 'C:\Program Files\MATLAB\R2017b\java\jar\ij-1.51u.jar' % depends your Fiji installation
   
4) Run following commands on Matalab Console 
   Miji
   
Run the code
1) On matlab console, change the directory to code location
2) On matlab console, the run following command 
   
   runFile(fileName, pathData, pathMIJI, maxArea, minArea, radius)
   filename: name of the output file e.g. 'output'
   pathData: folder with the data e.g. 'D:\code\data'
   pathMIJI: folder for the miji script path e.g. 'D:\Fiji.app\scripts'
   maxArea: 145000
   minArea: 3000
   radius: 3
   
   