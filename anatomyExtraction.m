function anatomyExtraction(pathData, saveWholeBW, saveAnatomyData, saveAnatomyBW, fid, maxArea, minArea) 
% Function Name:
%    AnatomyExtraction
%
% Description:
%   This function does the segmentation of whole embryo
% 
% Pre requisite:
%   Expects MIJI in path of matlab
%
% Inputs:
%   pathData     : Path where images are located
%   saveWholeBW  : Path where to save images
%   saveAnatomyData : Path where images are located
%   saveAnatomyBW   : Path where to save images
    if nargin < 7
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
         fprintf(fid, 'Check if path for data files is correct. Path given: %s \n', pathData);
         fclose(fid);
         diary off;
         errordlg('Program cannot be executed for one of the following reason');
         errordlg('Number of files found is 0');
         errordlg('Check if file xtension is tif');
         errordlg(strcat('Check if path for data files is correct. Path given:' , pathData));
    end
    
    for idx=1:nfiles
       % read original gray image
       dataName = strcat(pathData, '\', imagefiles(idx).name);     
       dataImage = imread(dataName);
       if(~isValidImage(dataImage))
            continue;
       end
       % read whole binary image
       fileName = strcat(saveWholeBW, '\', imagefiles(idx).name);
       bwWhole = imread(fileName);
       if(~isValidImage(bwWhole))
            continue;
       end
       bw = im2bw(bwWhole,0.01);
       stats = regionprops(bw, 'Area', 'PixelIdxList', 'PixelList', 'BoundingBox', 'Orientation');
       
       for regionAll = 1 : length(stats)           
          [bwSubImageRotated, subImageRotated] = EliminateOutlier(regionAll, stats, bw, dataImage, maxArea, minArea);              
          bwSubImageRotated = im2bw(bwSubImageRotated,0.01);                
          bwNewImageNameWrite = strcat(saveAnatomyBW, '\','N', num2str(regionAll), '-', imagefiles(idx).name);
          newImageNameWrite = strcat(saveAnatomyData, '\', 'N', num2str(regionAll), '-', imagefiles(idx).name);

          if(max(max(subImageRotated)) > 10)
              subImageRotated=subImageRotated-min(subImageRotated(:)); % shift data such that the smallest element of A is 0
              subImageRotated=subImageRotated/max(subImageRotated(:)); % normalize the shifted data to 1  
              imwrite(subImageRotated,newImageNameWrite,'tif','Compression','none');                        
              imwrite(bwSubImageRotated,bwNewImageNameWrite,'tif','Compression','none');
          end            
       end
       
    end
    
end

function valid = isValidImage(img)

    if(isempty(img) ||  size(find(img == 255),1) == (size(img,1) * size(img,2)))
         valid = false;
    else
        valid = true;
    end
end


function [ bwSubImageRotated, subImageRotated] = EliminateOutlier(regionAll, stats, bwWhole, dataImage, maxArea, minArea)
% Function Name:
%    EliminateOutlier
%
% Description:
%   This function removes outlier which are touching boundary, overlayed on
%   each other
% 
% Pre requisite:
%   Expects MIJI in path of matlab
%
% Inputs:
%   regionAll: Region number
%   stats    : Information about each region
%   bwWhole  : Binary image
%   dataImage: Original image
%
% Outputs:
%   bwSubImageRotated: Binary sub region
%   subImageRotated  : Sub region
    
    bwSubImageRotated = [];
    subImageRotated = [];
    X = stats(regionAll).PixelList(:,1);
    Y = stats(regionAll).PixelList(:,2);
    % get boundary condition
    anyX0 = any(X == 1);anyY0 = any(Y == 1);anyXw = any(X == size(bwWhole,2));anyYh = any(Y == size(bwWhole,1));
    % elminate boundary data from 3 images
    if (stats(regionAll).Area < minArea || stats(regionAll).Area > maxArea || anyX0 ~= 0 || anyY0 ~= 0|| anyXw ~= 0|| anyYh ~= 0) 
        bwWhole(Y, X)  = 0;
        dataImage(Y, X)  = 0;

    else
         [bwSubImageRotated, subImageRotated] = CropRotate(regionAll, stats, dataImage, bwWhole);           
    end 
end

function [bwSubImageRotated, subImageRotated] = CropRotate(regionAll, stats, dataImage, bwWhole)
% Function Name:
%    CropRotate
%
% Description:
%   This function crops and rotate each sub region to align them in
%   horizontal direction
% 
% Pre requisite:
%   Expects MIJI in path of matlab
%
% Inputs:
%   regionAll: Region number
%   stats    : Information about each region
%   bwWhole  : Binary image
%   dataImage: Original image
%
% Outputs:
%   bwSubImageRotated: Binary sub region
%   subImageRotated  : Sub region

    % get bounding box diminssion of remaining data 
    newDimenssions = [stats(regionAll).BoundingBox(1,1)  , stats(regionAll).BoundingBox(1,2) , stats(regionAll).BoundingBox(1,3)  + 5, stats(regionAll).BoundingBox(1,4) + 5];
    % crop wholeBW image
    bwWholeSubImage = imcrop(bwWhole, newDimenssions);
    % crop the dataImage
    subImage = imcrop(dataImage, newDimenssions);
    bwWholeSubImage = im2bw(bwWholeSubImage,0.01);
    statsWhole = regionprops(bwWholeSubImage, 'Area', 'PixelList');
    [bwSubImageRotated, subImageRotated] = keepLargestBlob(bwWholeSubImage, subImage, statsWhole);
    % rotate the BWImage to align the image
    bwSubImageRotated = imrotate(bwSubImageRotated,-(stats(regionAll).Orientation));
    % crop and rotate data image with same dimenssion and angle
    subImageRotated = imrotate(subImageRotated,-(stats(regionAll).Orientation));
    
end

function [bwSubImageRotated1, subImageRotated1] = keepLargestBlob(bwSubImageRotated, subImageRotated, statsSub)
% Function Name:
%    keepLargestBlob
%
% Description:
%   Keep largest connected region
% 
% Pre requisite:
%   Expects MIJI in path of matlab
%
% Inputs:
%   statsSub    : Information about each region
%   bwSubImageRotated  : Binary image
%   subImageRotated: Original image
%
% Outputs:
%   bwSubImageRotated1: Binary sub region
%   subImageRotated1  : Sub region

    bwSubImageRotated1 = zeros(size(bwSubImageRotated, 1), size(bwSubImageRotated, 2), 1); 
    subImageRotated1 = zeros(size(subImageRotated, 1), size(subImageRotated, 2), 1);
    if(size(statsSub,1) > 1)
      areaCount = statsSub(1).Area;
      neMax = 1;
      for regionCount = 2 : length(statsSub)
        if(areaCount < statsSub(regionCount).Area)
            areaCount = statsSub(regionCount).Area;
            neMax = regionCount;
        end
      end
      for regionSub = 1 : length(statsSub)
            if(regionSub == neMax)            
                X = statsSub(regionSub).PixelList(:,1);
                Y = statsSub(regionSub).PixelList(:,2);
                  for x = 1: size(X,1)
                      bwSubImageRotated1(Y(x),X(x)) = bwSubImageRotated(Y(x),X(x));   
                      subImageRotated1(Y(x),X(x)) = subImageRotated(Y(x),X(x));  
                  end
            end
      end

    else
        X = statsSub(1).PixelList(:,1);
        Y = statsSub(1).PixelList(:,2);
        for x = 1: size(X,1)
          bwSubImageRotated1(Y(x),X(x)) = bwSubImageRotated(Y(x),X(x));   
          subImageRotated1(Y(x),X(x)) = subImageRotated(Y(x),X(x));  
        end
    end
    
end