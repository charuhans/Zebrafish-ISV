function writeToExcelISVAnalysis(fileName, pathISV, pathISVSkel, patterns, fid, pathData)
% Function Name:
%    writeToExcelISVAnalysis
%
% Description:
%   This function computes the properties of ISV and save it in excel sheet
% 
% Pre requisite:
%   Expects MIJI in path of matlab
%
% Inputs:
%   fileName     : Name of chemical for name for excel sheet
%   initialSegBW :  Path to binary ISV
%   saveISVData  :  Path to ISV skelton

   if nargin < 6
       fprintf(fid, 'Need path as an argument \n');
       fclose(fid);
       diary off;
       errordlg('Need path as an argument');
    end 
    warning('off', 'all');
    warning;
    close all;
    
    imagefiles  = dir([pathISV '*.tif']);      
    nfiles = length(imagefiles);    
    
    if nfiles < 1  
         fprintf(fid, 'Program cannot be executed for one of the following reason \n');
         fprintf(fid, 'Number of files found is 0 \n');
         fprintf(fid, 'Check if file xtension is tif \n');
         fprintf(fid, 'Check if path for data files is correct. Path given: %s \n' , pathISV);
         fclose(fid);
         diary off;
         errordlg('Program cannot be executed for following reasons');
         errordlg('Number of files found is 0');
         errordlg('Check if file xtension is tif');
         errordlg(strcat('Check if path for data files is correct. Path given: ' , pathISV)); 
    end
    
    imagefiles  = dir([pathISVSkel '*.tif']);       
    
    if nfiles ~= length(imagefiles)
         message('Number of ISV images is not same as number of skeleton images');
         message('Number of files found is 0');
         message('Check if file xtension is tif');
         message('Check if path for data files is correct. Path given:' + pathISVSkel);
         return;
    end    
    header = {'ImageName', 'AverageDistanceISV', 'AverageAreaISV', 'AverageLengthISV', 'TotalAreaISV', 'CountISV'};
    letters = {'B','C','D','E','F'};
    headerWithUnits = {'AverageDistanceISV(pixels)', 'AverageAreaISV(pixels)', 'AverageLengthISV(pixels)' ,'TotalAreaISV(pixels)', 'Count'};
    numberOfCharts = 5;
    fileNameISV = strcat(pathData, fileName, '_ISV');
   
    % open an excel sheet
    xlswrite(fileNameISV,header,1,'A1');
    xlswrite(fileNameISV,header,2,'A1');    
    
    for j=1:nfiles
        names{j} = imagefiles(j).name;
    end
    names = names';
    names = cellstr(names);
    patterns = cellstr(patterns);
    
    excelCellIndexSheet1 = 2;
    excelCellIndexSheet2 = 2;    
    strippedFilenameNames = strippedFileNames(names, fileName);
    for k = 1:size(patterns,1)
         patterns{k} = regexprep(patterns{k}, '\s+', '');
         index = reshuffleFileNames(names, strippedFilenameNames, patterns{k});

         if(size(index, 1) > 0)
            [allResult, subNames, average] = processing(index, names, pathISV, pathISVSkel);

            excelCellNameSheet2 = strcat('A', num2str(excelCellIndexSheet2));
            xlswrite(fileNameISV,subNames',2,excelCellNameSheet2);       
            excelCellParaSheet2 = strcat('B', num2str(excelCellIndexSheet2));
            xlswrite(fileNameISV,allResult,2,excelCellParaSheet2);

            excelCellNameSheet1 = strcat('A', num2str(excelCellIndexSheet1));
            xlswrite(fileNameISV,{patterns{k}},1,excelCellNameSheet1);
            excelCellParaSheet1 = strcat('B', num2str(excelCellIndexSheet1));
            xlswrite(fileNameISV,average,1,excelCellParaSheet1);

            excelCellIndexSheet2 = excelCellIndexSheet2 + size(index, 1) + 1;
            excelCellIndexSheet1 = excelCellIndexSheet1 + 1;
         end
    end
    %excelFileName = [pwd '\' fileNameISV];
    excelPlotData(fileNameISV, excelCellIndexSheet1, header, letters, headerWithUnits, numberOfCharts);
end

function [index] = reshuffleFileNames(names, strippedFilenameNames, str)
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
%   names: list of names
%   str   :  pattern 
% Outputs:
%   index: indecies for particular dosaege in names
  if(strcmp(str, '0.1%DMSO'))
        indices = strfind(names, str);
        index = find(~cellfun(@isempty,indices));
  else
    index = find(strcmp(strippedFilenameNames, str));
  end
end


function [strippedFilenameNames] = strippedFileNames(names, fileName)
% Function Name:
%    strippedFileNames
%
% Description:
%   This function retains dosage information from an image name
% 
% Pre requisite:
%   Expects MIJI in path of matlab
%
% Inputs:
%   names: list of names
%   fileName   :  chemical name 
% Outputs:
%   strippedFilenameNames: updated name list with just dosage 

    strippedSpaceNames = regexprep(names, '\s+', '');  
    strippedSpacfileName = regexprep(fileName, '\s+', '');
    strippedFilenameNames = regexprep(strippedSpaceNames, strippedSpacfileName, '');
    strippedFilenameNames = cellstr(strippedFilenameNames);
    strippedFilenameNames = regexp(strippedFilenameNames,'x', 'split');
    strippedFilenameNames = cellfun(@(v) v(1), strippedFilenameNames(:,1));
    strippedFilenameNames = cellstr(strippedFilenameNames);
    strippedFilenameNames = regexp(strippedFilenameNames,'-', 'split');
    strippedFilenameNames = cellfun(@(v) v(2), strippedFilenameNames(:,1));
    strippedFilenameNames = cellstr(strippedFilenameNames);          
end


function [allResult, subNames, average] = processing(list, names, pathISV, pathISVSkeleton)
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
    for ii=1:size(list,1)        
        currentfilename = strcat(pathISV, '\\', names{list(ii)});
        image = imread(currentfilename);        
        if(~isValidImage(image))
            continue;
        end
        currentfilename = strcat(pathISVSkeleton, '\\', names{list(ii)});
        skelImage = imread(currentfilename);
        if(~isValidImage(skelImage))
            continue;
        end
        [result] = propertiesISV(image, skelImage);
        subNames{ii} = names{list(ii)};
        allResult = [allResult; result];
    end
    average = mean(allResult,1);
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
        result = [minDist/length(stats) areaCol/length(stats) areaColSkel/length(statsSkel) areaCol length(stats)];
    else
        result = [0 0 0 0 0];
    end

end


