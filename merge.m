function merge(saveISV, saveISVBW)  
% Function Name:
%    merge
%
% Description:
%   This function removes head and tail region
% 
%
% Inputs:
%   saveISV     : ISV image path
%   saveISVBW   : Binary ISV image path

    if nargin < 3
        disp('Need path as an argument');
        return;
    end 
    warning('off','all');
    warning;
    close all;
    imagefiles  = dir([saveISV '*.tif']);      
    nfiles = length(imagefiles); 
    
    if nfiles < 1
         message('Number of files found is 0');
         message('Check if file xtension is tif');
         message('Check if path for data files is correct. Path given:' + saveISV);
         return;
    end    
     
    for ii=1:nfiles
       colDist = [];
       colAngle = [];
       colArea = [];
       minDists = [];
       minDistsIx = [];
       currentfilename = strcat(saveISV, '\', imagefiles(ii).name);     
       dataImage = imread(currentfilename);  
       level = graythresh(dataImage);

       bw = im2bw(dataImage,level);
       BW2 = bwareaopen(bw, 20);
       
       stats = regionprops(BW2, 'All');
       % remove the region with high count, its an outlier
       for region = 1 : length(stats)
           if(stats(region).Area> 400)
               BW2(stats(region).PixelList(:,2), stats(region).PixelList(:,1)) = 0;
           end
       end
       stats = regionprops(BW2, 'All');       
       % find the closest regions according to distance between centeroid 
       for region = 1 : length(stats)
          first  = stats(region).Centroid; 
          rowDist = [];
          for inregion = 1 : length(stats)
              dist = pdist2(first, stats(inregion).Centroid);              
              rowDist = [ rowDist dist];         

          end
          colDist = [ colDist; rowDist];

       end

          % among obtained centeroid, find slope
          % if slope is  closer to 1, merge regions

          [minDists,minDistsIx] = sort(colDist,2) ;
          
          if(size(colDist,2) > 3)

              minDists = minDists(:, 2:4);
              minDistsIx = minDistsIx(:, 2:4);

              %returns slope between two closer centroids and ratio of their areas
              [colSlope,colAreaRatio]  = findAngleRatio(minDistsIx, stats);

              %returns regions numbers that needs to be merged
              [image, regionAssociation] = removeOutliers(colSlope, colAreaRatio, minDistsIx, BW2, stats);

              %connect these areas that need to be merged
              image = mergeAreas(regionAssociation, image, stats);
          
          else
              image = BW2;
          end
           image = bwareaopen(image, 20);
           stats = regionprops(image, 'All');
       % remove the region with high count, its an outlier
       for region = 1 : length(stats)
           if(stats(region).Area> 400)
               image(stats(region).PixelList(:,2), stats(region).PixelList(:,1)) = 0;
           end
       end
          newImageWrite = strcat(saveISVBW, '\', imagefiles(ii).name);
          imwrite(image,newImageWrite,'tif','Compression','none');

    end
end

function [image] = mergeAreas(regionAssociation, image, stats)

% Function Name:
%    mergeAreas
%
% Description:
%   merges all the areas that were broken due to image preprocessing
% 
%
% Inputs:
%   regionAssociation : mapping reflection which isv the region belong to
%   image             : input  image 
%   stats             : stats about each region

    for i = 1: size(regionAssociation,1)
        region_1 = regionAssociation(i,1);
        region_2 = regionAssociation(i,2);
        
        extrema_1 = stats(region_1).Extrema;
        extrema_2 = stats(region_2).Extrema;
        
         centroid_1y = stats(region_1).Centroid(2);
         centroid_2y = stats(region_2).Centroid(2);
         
         if(centroid_1y < centroid_2y)
             %region 1 is on the top
             bottom_right = extrema_1(5,:);
             bottom_left = extrema_1(6,:);
             top_left = extrema_2(1,:);
             top_right = extrema_2(2,:);
         else
             %region1 is on the bottom
             bottom_right = extrema_2(5,:);
             bottom_left = extrema_2(6,:);
             top_left = extrema_1(1,:);
             top_right = extrema_1(2,:);
         end
         
        %we have extremas now we need to join them by a line in image(not
        %just plot)

        %get pts for the line
        rightPts = getLinePts(top_right, bottom_right);
        leftPts = getLinePts(top_left, bottom_left);
        
        %put lines on the image
        image(leftPts(:,2), leftPts(:,1) ) = 255;
        image(rightPts(:,2), rightPts(:,1) ) = 255;
    end
end

function [linePts] = getLinePts(pt1, pt2)
% Function Name:
%    getLinePts
%
% Description:
%   generate points based on distance between point
% 
%
% Inputs:
%   pt1 : extreme point 1
%   pt2 : extreme point 2
% 
% Output:
%   linepts: points on line

    nPts = ceil(pdist2(pt1, pt2))*2;
    x1 = pt1(1);
    x2 = pt2(1);
    y2 = pt2(2);
    y1 = pt1(2);
    %listOfPoints = fix([x1:(x2-x1)/(nPts-1):x2;y1:(y2-y1)/(nPts-1):y2]);
    listOfPoints = fix([linspace(x1,x2,nPts);linspace(y1,y2,nPts)]);

    A = listOfPoints';
    [q i j] = unique(A,'rows');
    linePts = A((i),:);
end


function [image, regionAssociation] = removeOutliers(colSlope, colAreaRatio, minDistsIx, image, stats)

% Function Name:
%    removeOutliers
%
% Description:
%   Get regions to be merged or removed
% 
%
% Inputs:
%   colSlope    : associated region slope
%   colAreaRatio: associated region area ratio
%   minDistsIx  : index with min distance
%   image       : merged image
%   stats       : stats for each region
% 
% Output:
%   regionAssociation : mapping reflection which isv the region belong to
%   image             : image without outlier
    
    %not sure if we need all of them , keeping as backup
    regionAssociation = [];
    newColSlope = [];
    newColAreaRatio = [];
    
    for i = 1 : size(colSlope,1)
        slope_1 = colSlope(i,1);
        slope_2 = colSlope(i,2);
        
        ratio_1 = colAreaRatio(i,1);
        ratio_2 = colAreaRatio(i,2);
        
        %if slope is greter than 1.5 and one region is more than 1/4 of
        %another then they should be merged
        
        %closest regions
        if(slope_1 > 1.6 && (ratio_1 <= 4 && (1/ratio_1) <= 4))
            regionAssociation = [regionAssociation; i minDistsIx(i,1)];
        end
        
        %second closest regions
        if(slope_2 > 1.6 && (ratio_2 <=4 && (1/ratio_2) <= 4))
            regionAssociation = [regionAssociation; i minDistsIx(i,2)];
        end
    end
    
    for i = 1 : size(colSlope,1)
        
        ratio_1 = colAreaRatio(i,1);
        ratio_2 = colAreaRatio(i,2);
        
        
        % regions to be removed
        if(ratio_1 > 5  || (1/ratio_1) > 5)
            area1 = stats(i).Area;
            area2 = stats(minDistsIx(i,1)).Area;
            if(area1 < area2)
                image(stats(i).PixelList(:,2),stats(i).PixelList(:,1))  = 0;
            else
                image(stats(minDistsIx(i,1)).PixelList(:,2), stats(minDistsIx(i,1)).PixelList(:,1)) = 0;
            end
        end
        
        if(ratio_2 > 5  || (1/ratio_2) > 5)
            area1 = stats(i).Area;
            area2 = stats(minDistsIx(i,2)).Area;
            if(area1 < area2)
                image(stats(i).PixelList(:,2),stats(i).PixelList(:,1))  = 0;
            else
                image(stats(minDistsIx(i,2)).PixelList(:,2), stats(minDistsIx(i,2)).PixelList(:,1)) = 0;
            end
        end
    end
    
    %remove duplicate associations
    regionAssociation = sort(regionAssociation,2);
    A =  sort(regionAssociation, 2);
    [q i j] = unique(A,'rows');
    regionAssociation = A(sort(i),:);
    
end


function [colAngle, colArea] = findAngleRatio(mat, stats)

% Function Name:
%    findAngleRatio
%
% Description:
%   Find angle btween centeroid of each region
% 
% Input:
%   mat: asssoctaion matrix
%   stats: stats for each region
%
% Output:
%   colAngle : angle of region to merged
%   colArea : area of each region


    colAngle = [];
    colArea = [];

    for region = 1 : size(mat,1)
        first  = stats(region).Centroid; 
        firstA  = stats(region).Area; 
        rowAngle = [];
        rowArea = [];
        for inregion = 1 : size(mat,2)
           second = stats(mat(region, inregion)).Centroid;
           secondA = stats(mat(region, inregion)).Area;
           %CosTheta = dot(first,second)/(norm(first)*norm(second));
           CosTheta = abs((first(2) - second(2))/( first(1) - second(1)));
           areaRatio = firstA/secondA;
            %angle =acos( dot(DirVector1,DirVector2)/norm(DirVector1)/norm(DirVector2) )*180/pi; 
            rowAngle = [ rowAngle CosTheta]; 
            rowArea = [ rowArea areaRatio]; 
        end
        colAngle = [ colAngle; rowAngle];
        colArea = [ colArea; rowArea];
    end
end
        
    
    


