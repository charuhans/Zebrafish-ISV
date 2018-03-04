function roiExtraction( pathData, saveWholeBW, fid)
% Function Name:
%    IntialRoiExtraction
%
% Description:
%   This function does the segmentation of whole embryo
% 
% Pre requisite:
%   Expects MIJI in path of matlab
%
% Inputs:
%   pathData    : Path where images are located
%   saveWholeBW : Path where to save images
%
% Outputs:
%   success: If images were saved.

    if nargin < 3
        fprintf(fid, 'Need path as an argument \n');
        fclose(fid);
        diary off;
        errordlg('Need path as an argument');
    end
    warning('off','all');
    warning;
    close all;
    imagefiles  = dir([pathData '*.tif']);      
    nfiles = length(imagefiles); 
    if nfiles < 1
         fprintf(fid,'Program cannot be executed for one of the following reason \n');
         fprintf(fid, 'Number of files found is 0 \n');
         fprintf(fid, 'Check if file xtension is tif \n');
         fprintf(fid,'Check if path for data files is correct. Path given: %s \n' , pathData);
         fclose(fid);
         diary off;
         errordlg('Program cannot be executed for following reasons');
         errordlg('Number of files found is 0');
         errordlg('Check if file extension is tif');
         errordlg(strcat('Check if path for data files is correct. Path given: ' , pathData));
         
    end
    
    for idx = 1:nfiles
        dataName = strcat(pathData, '\\', imagefiles(idx).name);
        data = imread(dataName);
        img8 = uint8(255*mat2gray(data));
        %img8 = uint8(data / 256);
        imwrite(img8,dataName,'tif','Compression','none');     
    end
    
    for idx = 1:nfiles
       dataName = strcat(pathData, '\\', imagefiles(idx).name);   
       MIJ.run('Open...', strcat('path=[', dataName, ']'));
       MIJ.run('Enhance Contrast...', 'saturated=[3] normalize');
       % originally 8
       MIJ.run('Gaussian Blur...', 'sigma=[6]');
       %MIJ.run('Enhance Contrast...', 'saturated = [10] normalize');
       MIJ.run('Auto Threshold', 'method=Huang background=Light calculate black');
       MIJ.run('Convert to Mask');
       MIJ.run('Fill Holes');
       %MIJ.run('Invert');
       bw = MIJ.getCurrentImage();
       fileName = strcat(saveWholeBW, '\', imagefiles(idx).name);
       bw = uint8(bw / 256);
       bw = im2uint8(bw*255);
       imwrite(bw,fileName,'tif','Compression','none');  
       MIJ.run('Close');
    end

end

