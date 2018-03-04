function tailISVExtraction(saveIsolateData, initialSegBW, saveISVData, saveSkeleton, fid)
% Function Name:
%    TailExtraction
%
% Description:
%   This function does the tail segmentation and computes skeleton 
% 
% Pre requisite:
%   Expects MIJI in path of matlab
%
% Inputs:
%   saveIsolateData: Path to individual isolated images
%   initialSegBW   : Path where to save binary images for tail + head
%   saveISVData    :  Path to isv images
%   saveSkeleton   : Path to head + tail skeleton

   if nargin < 5
       fprintf(fid, 'Need path as an argument \n');
       fclose(fid);
       diary off;
       errordlg('Need path as an argument');
    end 
    warning('off','all');
    warning;
    close all;
    imagefiles  = dir([saveIsolateData '*.tif']);      
    nfiles = length(imagefiles); 
    
    if nfiles < 1
         fprintf(fid, 'Program cannot be executed for one of the following reason \n');
         fprintf(fid, 'Number of files found is 0 \n');
         fprintf(fid, 'Check if file xtension is tif \n');
         fprintf(fid, 'Check if path for data files is correct. Path given: %s \n' , saveIsolateData);
         fclose(fid);
         diary off;
         errordlg('Program cannot be executed for following reasons');
         errordlg('Number of files found is 0');
         errordlg('Check if file extension is tif');
         errordlg(strcat('Check if path for data files is correct. Path given: ' , saveIsolateData));       
    end
    
    for idx = 1:nfiles        
        dataName = strcat(saveIsolateData, imagefiles(idx).name);
        MIJ.run('Open...', strcat('path=[', dataName, ']'));
        MIJ.run('Enhance Contrast...', 'saturated=[10] normalize');
        MIJ.run('Gaussian Blur...', 'sigma=[6]');
        MIJ.run('Auto Threshold', 'method=Intermodes background=Light calculate black');
        %-MIJ.run('Threshold...','setAutoThreshold=[Intermodes]');
        MIJ.run('Convert to Mask');
        %-MIJ.run('Invert');
	    MIJ.run('Analyze Particles...', 'size=250-Infinity circularity=0.00-1.00 show=Masks');
        MIJ.run('Fill Holes');
        fileName = strcat(initialSegBW, imagefiles(idx).name);
        image = MIJ.getCurrentImage();
        image = uint8(255*mat2gray(image));
        imwrite(image,fileName,'tif','Compression','none');
        
        MIJ.run('Gaussian Blur...', 'sigma=[2]');
		MIJ.run('Skeletonize (2D/3D)', '');
        MIJ.run('Invert');
        fileNameSkel = strcat(saveSkeleton, imagefiles(idx).name);
        image = MIJ.getCurrentImage();
        image = uint8(255*mat2gray(image));
        imwrite(image,fileNameSkel,'tif','Compression','none');   
        
        MIJ.run('Close');       
        MIJ.run('Close');        
        
        MIJ.run('Open...', strcat('path=[', dataName, ']'));
        % 10 before
        MIJ.run('Enhance Contrast...', 'saturated=[4] normalize');
        image = MIJ.getCurrentImage();
        image = uint8(255*mat2gray(image));
        imwrite(image,dataName,'tif','Compression','none');
        MIJ.run('Close');
        
        currentimage1 = imread(fileName);
        currentimage1 = logical(currentimage1);
        currentimage2 = imread(dataName);
        currentimage2(currentimage1) = 0;
        fileNameISV = strcat(saveISVData, imagefiles(idx).name);
        imwrite(currentimage2,fileNameISV,'tif','Compression','none');  
        
        
    end