function skeletonISV( pathData, pathSkeletonISV, fid)
% Function Name:
%    skeletonISV
%
% Description:
%   This function does the skeletonization of ISV, and does pruning
% 
% Pre requisite:
%   Expects MIJI in path of matlab
%
% Inputs:
%   pathData    : Path where binsary ISV images are located
%   pathSkeletonISV : Path where to save ISV skeleton images
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
         fprintf(fid, 'Program cannot be executed for one of the following reason \n');
         fprintf(fid, 'Number of files found is 0 \n');
         fprintf(fid, 'Check if file xtension is tif \n');
         fprintf(fid, 'Check if path for data files is correct. Path given: %s \n' , pathData);
         fclose(fid);
         diary off;
         errordlg('Program cannot be executed for following reasons');
         errordlg('Number of files found is 0');
         errordlg('Check if file xtension is tif');
         errordlg(strcat('Check if path for data files is correct. Path given: ' , pathData)); 
    end
    
    for idx = 1:nfiles
       dataName = strcat(pathData, '\\', imagefiles(idx).name);   
       MIJ.run('Open...', strcat('path=[', dataName, ']'));
       MIJ.run('Invert');
       MIJ.run('Skeletonize (2D/3D)');
       MIJ.run('Analyze Particles...', 'size=5-Infinity circularity=0.00-1.00 show=Masks');
	   %MIJ.run('Analyze Skel', 'prune=none calculate');
       MIJ.run("Analyze Skeleton (2D/3D)", "prune=none calculate");
       bw = MIJ.getCurrentImage();
       fileName = strcat(pathSkeletonISV, '\', imagefiles(idx).name);
       %bw = uint8(bw / 256);
       %bw = im2uint8(bw*255);
       image8Bit = uint8(255 * mat2gray(bw));
       imwrite(image8Bit,fileName,'tif','Compression','none');  
       MIJ.run('Close');
       MIJ.run('Close');
       MIJ.run('Close');
       MIJ.run('Close');
       MIJ.run('Close');
    end

end
