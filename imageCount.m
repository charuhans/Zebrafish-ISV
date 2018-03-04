function total = imageCount(path)

    folderListing = dir(path); % get list of all subfloder one level
    folderListing = folderListing(arrayfun(@(x) x.name(1), folderListing) ~= '.');
    isub = [folderListing(:).isdir]; % returns logical vector
    nameFolds = {folderListing(isub).name}';
    total = 0;
    for i = 1:size(nameFolds,1)
        folder = (char(nameFolds(i,1))); 
        fprintf('folder name: %s \n', folder);          
        pathData = strcat(path, folder, '\');
        pathISVSkeleton = strcat(pathData , '\', 'isvSkeleton','\'); 
        
        imagefilesISV  = dir([pathISVSkeleton '*.tif']);      
        nfilesISV = length(imagefilesISV);  
        
        total = total + nfilesISV;
        
    end
    total
end
    