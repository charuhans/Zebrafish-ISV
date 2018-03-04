clear all;
%I = 'C:\Users\charu\Documents\GitHubRes\Research\ReseachZebrafish\CadualVein\cvData - Copy - Copy\N1-0.1%DMSO x4-1.tif';
path = 'C:\Users\charu\Desktop\Zebrafish\classification_cv\newModel\+';
cd(path);
imagefiles = dir('*.tif');   
nfiles = length(imagefiles);    % Number of files found
for i = 1:nfiles
    currentfilename = imagefiles(i).name;
    
    img = imread(currentfilename);
    %if (2*i - 1 < 10)
    if (2*i < 10)
        %name = strcat('00', num2str(2*i - 1), '.tif');
        name = strcat('00', num2str(2*i), '.tif');
    
    %elseif ((2*i -1) >= 10 && (2*i - 1) < 100)
    elseif (2*i >= 10 && 2*i < 100)
        %name = strcat('0', num2str(2*i - 1), '.tif');
        name = strcat('0', num2str(2*i), '.tif');
    else
        %name = strcat(num2str(2*i - 1), '.tif');
        name = strcat(num2str(2*i), '.tif');
    end
    imwrite(img, name);
end