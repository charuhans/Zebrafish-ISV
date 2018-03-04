function features( saveISVBW, saveSkeletonISV) 
% Function Name:
%    computeFeatures
%
% Description:
%   This function computes the features of ISV
% 
%
% Inputs:
%   saveISVBW    : Path where binsary ISV images are located
%   saveSkeletonISV : Path where ISV skeleton images are located
%
% Outputs:
%   success: If images were saved.

    if nargin < 2
        disp('Need path as an argument');
        return;
    end
    warning('off','all');
    warning;
    close all;
    imagefiles  = dir([saveISVBW '*.tif']);      
    nfiles = length(imagefiles); 
    
    if nfiles < 1
         disp('Number of files found is 0');
         disp('Check if file xtension is tif');
         disp('Check if path for data files is correct. Path given:' + saveISVBW);
         return;
    end
    
   
data = [];

for idx=1:nfiles
   areaCol = 0; minDist = 0;
   count = 0;
   areaColSkel = 0;
   currentfilename = strcat(saveISVBW, '\\', imagefiles(idx).name);
   dataImage = imread(currentfilename);
    
   currentfilename = strcat(saveSkeletonISV, '\\', imagefiles(idx).name);
   skeletonImage = imread(currentfilename);

   bw = im2bw(dataImage,0.01);
   stats = regionprops(bw, 'All');

   regionCount = 0;
   % find area of each blob
   for region = 1 : length(stats)
       area = stats(region).Area;
       if(area < 750)
        areaCol =  areaCol + area;
        regionCount = regionCount + 1;
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

   skelCount = 0;
   % find area of each blob for skeleton
   for region = 1 : length(statsSkel)
       area = statsSkel(region).Area;
       if(area < 100)
        areaColSkel =  areaColSkel + area;
        skelCount = skelCount + 1;
       end

   end
   %result = [minDist/length(stats) areaCol/length(stats) areaColSkel/length(statsSkel) areaCol length(stats)]; 
    if(regionCount > 0 && skelCount > 0)
        result = [minDist/length(stats) areaCol/regionCount areaColSkel/skelCount areaCol regionCount];
    elseif(regionCount > 0 && skelCount == 0)
        result = [minDist/length(stats) areaCol/regionCount 0.1 areaCol regionCount];
    else
        result = [0.01 0.01 0.01 0.01 0.01];
    end
   data = [ data; result];
  
end
save('data.mat', 'data');
end
        
         
       