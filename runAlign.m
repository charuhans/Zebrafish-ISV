function runAlign(fileName, pathData, maxArea, minArea)

    diary(strcat(pathData,'errorLogIsolateImage.txt'));
    pathData = strcat(pathData,'\'); 
    pathMIJI = strcat(pathMIJI,'\'); 
    if ~isdeployed
        addpath(genpath(pathMIJI));
    end
    %minArea = 30000;
    %maxArea = 145000;
    javaclasspath
    java.lang.System.setProperty('ij.dir', pathMIJI);
    java.lang.System.setProperty('plugins.dir', pathMIJI);
    Miji(false);
    %ij.ImageJ([], 2);
    currentFolder = pathData;
    global fid;
    fid = fopen(strcat(pathData,'logIsolateImage.txt'),'at');
    h = waitbar(0,'Please wait...');
    steps = 12;
    fprintf(fid, 'Max Area %d ...\n', maxArea);
    fprintf(fid, 'Min Area %d ...\n', minArea);
    fprintf(fid, 'Path Data %s ...\n', pathData);
    fprintf(fid, 'Path Miji %s ...\n', pathMIJI);
    
    makeDir(strcat(pathData,'pathAnatomyData'));
    makeDir(strcat(pathData,'pathAnatomyBW'));
    makeDir(strcat(pathData,'isolateData'));
    
    saveWholeBW = strcat(currentFolder,'\', 'wholeSegBW','\');
    saveAnatomyData = strcat(currentFolder,'\', 'pathAnatomyData','\');
    saveAnatomyBW = strcat(currentFolder,'\', 'pathAnatomyBW','\');
    saveIsolateData = strcat(currentFolder , '\', 'isolateData','\');
    
    saveInitialSegBW = strcat(currentFolder , '\', 'initialSegBW','\'); 
    waitbar(1 / steps);
    fprintf(fid, 'fnished creating folder... \n');
    
    fprintf(fid, 'Extracting CVP region ...\n');
    intialRoiExtraction(pathData, saveWholeBW, fid);
    waitbar(3 / steps);
    
    fprintf(fid, 'Segmenting individual zebrafish ...\n');
    anatomyExtraction(pathData, saveWholeBW, saveAnatomyData, saveAnatomyBW, fid, maxArea, minArea); 
    waitbar(4 / steps);
    
    fprintf(fid, 'Extracting individual zebrafish ...\n');
    roi(saveAnatomyData, saveAnatomyBW, saveIsolateData, saveIsolateBW, fid);
    waitbar(5 / steps);
% image resize
% image enhancement
% image thresholding
% blobs
% 

end