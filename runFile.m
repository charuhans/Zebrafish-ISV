function runFile(fileName, pathData, pathMIJI, maxArea, minArea, radius)   

    options = struct('ScaleRange', [0 radius], 'ScaleRatio', 0.5, 'verbose',false,'BlackWhite',false);
    diary(strcat(pathData,'errorLog.txt'));
    pathData = strcat(pathData,'\'); 
    pathMIJI = strcat(pathMIJI,'\'); 
    addpath(genpath(pathMIJI));
    
    %minArea = 30000;
    %maxArea = 145000;
    %javaclasspath
    Miji(false);
    %ij.ImageJ([], 2);
    currentFolder = pathData;
    global fid;
    fid = fopen(strcat(pathData,'log.txt'),'at');
    fprintf(fid, 'Max Area %d ...\n', maxArea);
    fprintf(fid, 'Min Area %d ...\n', minArea);
    fprintf(fid, 'Radius %d ...\n', radius);
    fprintf(fid, 'Path Data %s ...\n', pathData);
    fprintf(fid, 'Path Miji %s ...\n', pathMIJI);
    
    makeDir(strcat(pathData,'pathAnatomyData'));
    makeDir(strcat(pathData,'pathAnatomyBW'));
    makeDir(strcat(pathData,'isolateData'));
    makeDir(strcat(pathData,'isolateBW'));
    makeDir(strcat(pathData,'skeleton'));    
    makeDir(strcat(pathData,'wholeSegBW'));
    makeDir(strcat(pathData,'initialSegBW'));
    makeDir(strcat(pathData,'isvData'));
    

    if exist(strcat(pathData,fileName, '_ISV.xls'))
        delete(strcat(pathData,fileName, '_ISV.xls'));
    end
       
	makeDir(strcat(pathData,'isvBW'));
	makeDir(strcat(pathData,'isvClean'));
	makeDir(strcat(pathData,'isvSkeleton'));
	makeDir(strcat(pathData,'isv'));
	makeDir(strcat(pathData,'isvX'));
	makeDir(strcat(pathData,'isvAll'));
 
    saveWholeBW = strcat(currentFolder,'\', 'wholeSegBW','\');
    saveAnatomyData = strcat(currentFolder,'\', 'pathAnatomyData','\');
    saveAnatomyBW = strcat(currentFolder,'\', 'pathAnatomyBW','\');
    saveIsolateData = strcat(currentFolder , '\', 'isolateData','\');
    saveIsolateBW = strcat(currentFolder , '\', 'isolateBW','\');
    saveSkeleton = strcat(currentFolder , '\', 'skeleton','\'); 
    saveISVData = strcat(currentFolder , '\', 'isvData','\');
    
           
	saveISVBW = strcat(currentFolder , '\', 'isvBW','\');
	saveISVSkeleton = strcat(currentFolder , '\', 'isvSkeleton','\'); 
	saveISV = strcat(currentFolder , '\', 'isv','\');
	saveISVX = strcat(currentFolder , '\', 'isvX','\');
	saveISVAll = strcat(currentFolder , '\', 'isvAll','\');
	saveISVClean = strcat(currentFolder , '\', 'isvClean','\');
    
    
    saveInitialSegBW = strcat(currentFolder , '\', 'initialSegBW','\'); 
    fprintf(fid, 'fnished creating folder... \n');
    
    fprintf(fid, 'Extracting CVP region ...\n');
    intialRoiExtraction(pathData, saveWholeBW, fid);
 
    fprintf(fid, 'Segmenting individual zebrafish ...\n');
    anatomyExtraction(pathData, saveWholeBW, saveAnatomyData, saveAnatomyBW, fid, maxArea, minArea); 
    
    fprintf(fid, 'Extracting individual zebrafish ...\n');
    roi(saveAnatomyData, saveAnatomyBW, saveIsolateData, saveIsolateBW, fid);
    
    fprintf(fid, 'Extracting tail + head region from zebrafish ...\n');
    tailISVExtraction(saveIsolateData, saveInitialSegBW, saveISVData, saveSkeleton, fid);
    
    
	fprintf(fid, 'Extracting ISV region ...\n');
	cleanImage(saveSkeleton, saveISVData, saveISVClean, fid);
	
	fprintf(fid, 'Extracting ISV ...\n');
	mergeUpdated(saveISVClean, saveISV, saveISVX, saveISVAll, saveISVBW, fid, options);
	
	fprintf(fid, 'Extracting ISV skeleton ...\n');
	skeletonISV(saveISVBW, saveISVSkeleton, fid);	  
	
	fprintf(fid, 'ISV Finished ...\n');
   
    
    fprintf(fid, 'Completed ...\n');
    fclose(fid);
    delete(get(0,'Children'));
    msgbox('Completed ...');
    
    diary off;
    
end
function makeDir(name)
     if exist(name, 'dir')
        rmdir(name, 's');
        mkdir(name);
     else
        mkdir(name);
     end
end