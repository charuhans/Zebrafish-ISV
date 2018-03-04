
function [excelCellIndexSheet1, excelCellIndexSheet2] = dosageISVCV(modelISV, minimums, ranges, modelCV, pathISV, pathISVSkeleton, pathCV, patterns, fileName, excelCellIndexSheet1, excelCellIndexSheet2)
    if nargin < 5
        error('Need path as an argument');
    end 
    warning('off', 'all');
    warning;
    close all;
    
    imagefilesISV  = dir([pathISV '*.tif']);      
    nfilesISV = length(imagefilesISV);    
    
    if nfilesISV < 1
         disp('Number of files found is 0');
         disp('Check if file xtension is tif');
         disp('Check if path for data files is correct. Path given:' + pathISV);
         error('Program cannot be executed');
    end
    
    imagefiles  = dir([pathISVSkeleton '*.tif']); 
    nfiles = length(imagefiles);
    
    if nfiles ~= nfilesISV
         message('Number of ISV images is not same as number of skeleton images');
         message('Number of files found is 0');
         message('Check if file xtension is tif');
         message('Check if path for data files is correct. Path given:' + pathISVSkeleton);
         return;
    end    
   
    imagefilesCV  = dir([pathCV '*.tif']);  
    nfilesCV = length(imagefilesCV);
    
    if nfilesCV < 1
         message('Number of CV images is not same as number of ISV images');
         message('Number of files found is 0');
         message('Check if file xtension is tif');
         message('Check if path for data files is correct. Path given:' + pathCV);
         return;
    end

    for j=1:nfilesISV
        namesISV{j} = imagefilesISV(j).name;
    end
    for j=1:nfilesCV
        namesCV{j} = imagefilesCV(j).name;
    end
    namesISV = namesISV';
    namesISV = cellstr(namesISV);
    
    namesCV = namesCV';
    namesCV = cellstr(namesCV);
    
    patterns = cellstr(patterns);
    
   
    [allResultISV] = processingISV(namesISV, pathISV, pathISVSkeleton, minimums, ranges);
    [allResultCV] = processingCV(namesCV, pathCV); 
    
    for k = 1:size(patterns,2)
        
          indexISV = reshuffleFileNames(namesISV, patterns{k});
          indexCV = reshuffleFileNames(namesCV, patterns{k});
          
          if(size(indexISV, 1) > 0)             
                          
             testLabelsISV =  ones(size(indexISV,1),1);
             [predictedLabel] = svmpredict(testLabelsISV, allResultISV(indexISV, :), modelISV, []);
             lethalFactorISV = size(find(predictedLabel == 1),1)/size(predictedLabel,1);
             
             excelCellNameSheet1 = strcat('A', num2str(excelCellIndexSheet1));
             xlswrite(fileName,{patterns{k}},1,excelCellNameSheet1);
             
             excelCellNameSheet1 = strcat('B', num2str(excelCellIndexSheet1));
             xlswrite(fileName,lethalFactorISV,1,excelCellNameSheet1);
             
             excelCellIndexSheet1 = excelCellIndexSheet1 + 1;   
          end
          
         if(size(indexCV, 1) > 0)             
            
             testLabelsCV =  ones(size(indexCV,1),1);
             [predictedLabel] = svmpredict(testLabelsCV, allResultCV(indexCV, :), modelCV, []);
             lethalFactorCV = size(find(predictedLabel == 1),1)/size(predictedLabel,1);
             
             excelCellNameSheet2 = strcat('A', num2str(excelCellIndexSheet2));
             xlswrite(fileName,{patterns{k}},2,excelCellNameSheet2);
             
             excelCellNameSheet2 = strcat('B', num2str(excelCellIndexSheet2));
             xlswrite(fileName,lethalFactorCV,2,excelCellNameSheet2);
             
            excelCellIndexSheet2 = excelCellIndexSheet2 + 1;          
          end
    end
end



function [index] = reshuffleFileNames(names, str)
% Function Name:
%    reshuffleFileNames
%
% Description:
%   This function rearranges index of file in folder based on pattern
% 
% Pre requisite:
%   Expects MIJI in path of matlab
%
% Inputs:
%   names: list of bames
%   str   :  pattern 
    indices = strfind(names, str);
    index = find(~cellfun(@isempty,indices));
end


function [allResult] = processingISV( names, pathISV, pathISVSkeleton, mins, range)
% Function Name:
%    processing
%
% Description:
%   This function reads ISV, and ISV skeleton image and computes the mean of all properties
% 
% Pre requisite:
%   Expects MIJI in path of matlab
%
% Inputs:
%   list: indexs based on chemical names
%   names          :  names of file
%   pathISV        :  Path to ISV data images
%   pathISVSkeleton:  Path to ISV sksleton images

    subNames  = [];
    allResult = [];
    for ii=1:size(names,1)        
        currentfilename = strcat(pathISV, '\\', names{(ii)});
        image = imread(currentfilename);        
        if(~isValidImage(image))
            continue;
        end
        currentfilename = strcat(pathISVSkeleton, '\\', names{(ii)});
        skelImage = imread(currentfilename);
        if(~isValidImage(skelImage))
            continue;
        end
        [result] = propertiesISV(image, skelImage);
        allResult = [allResult; result];
    end
%     minimums = min(allResult, [], 1);
%     ranges = max(allResult, [], 1) - minimums;
     allResult = (allResult - repmat(mins, size(allResult, 1), 1)) ./ repmat(range, size(allResult, 1), 1);
end

function valid = isValidImage(img)

    if(isempty(img) ||  size(find(img == 255),1) == (size(img,1) * size(img,2)))
         valid = false;
    else
        valid = true;
    end
end

function [result] = propertiesISV(dataImage, skeletonImage)
% Function Name:
%    propertiesISV
%
% Description:
%   This function computes the properties of ISV
% 
% Pre requisite:
%   Expects MIJI in path of matlab
%
% Inputs:
%   dataImage    : ISV data
%   skeletonImage:  ISV sksleton data

   areaCol = 0; minDist = 0; count = 0; areaColSkel = 0;
   bw = im2bw(dataImage,0.01);
   stats = regionprops(bw, 'All');

   % find area of each blob
   for region = 1 : length(stats)
       area = stats(region).Area;
       if(area < 750)
        areaCol =  areaCol + area;
        count = count + 1;
       end
   end

   % find distance
    for region = 1 : length(stats)
      first  = stats(region).Centroid; 
      rowDist = [];
      for inregion = 1 : length(stats)
          dist = pdist2(first, stats(inregion).Centroid);              
          rowDist = [ rowDist dist];      
      end
        if(size(rowDist,2) > 1)
        % find the distance b/w centeroid
            [minDists] = sort(rowDist,2) ;
            val = minDists(:, 2);
        else
            val = 0;
           
        end
            minDist = minDist + val;
    end
    
   bw = im2bw(skeletonImage,0.01);
   statsSkel = regionprops(bw, 'All');

   % find area of each blob for skeleton
   for region = 1 : length(statsSkel)
       area = statsSkel(region).Area;
       if(area < 100)
        areaColSkel =  areaColSkel + area;
        count = count + 1;
       end
   end
    
    if(~isempty(stats))
        result = [areaCol/length(stats) areaColSkel/length(statsSkel) areaCol length(stats)];
    else
        result = [0 0 0 0];
    end

end

function [allResult] = processingCV(names, pathCV)
% Function Name:
%    processing
%
% Description:
%   This function reads ISV, and ISV skeleton image and computes the mean of all properties
% 
% Pre requisite:
%   Expects MIJI in path of matlab
%
% Inputs:
%   list: indexs based on chemical names
%   names          :  names of file
%   pathISV        :  Path to ISV data images
%   pathISVSkeleton:  Path to ISV sksleton images

    angle = 360; binSize = 8; L=2;
    subNames  = [];
    allResult = [];
    for ii=1:size(names,1)        
        currentfilename = strcat(pathCV, '\\', names{(ii)});
        image = imread(currentfilename); 
        myfilter = fspecial('gaussian',[10 10], 10);
        image = imfilter(image, myfilter, 'replicate');
       
        if(~isValidImage(image))
            continue;
        end
        result = [];
        [result] = coHogFeat(image,binSize,angle,L);
        allResult = [allResult result];
    end
    allResult = allResult';
end

