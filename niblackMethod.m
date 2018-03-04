function binaryImage = niblackMethod(image1, scale, window)
scale = scale /max(max(scale));
% K value
%scale = abs(scale - max(max(scale)));



%convert to double
image1 = double(image1);

% normalise to [0,1] range
image1 = image1 / max(image1(:));

%mean filtering
meanIm = averagefilter2(image1, window);

%standard deviation
standardDeviation = standardDev(image1, meanIm, window);

%calculate binary image
binaryImage = image1 >  (meanIm + ( scale .* standardDeviation));


%display image
%display = displayImage(binaryImage, image1);
end

function deviation = standardDev(image1, mean, window)
    meanSquare = averagefilter2(image1.^2, window);
    deviation = (meanSquare - mean.^2).^0.5;

end
function [X,Y] = displayImage (binaryImage, image1)
close;

figure;
X = imshow(image1); title('original image');

figure;
 Y = imshow(binaryImage); title('binary image');

end

function img=averagefilter2(image1, window)
    meanFilter = fspecial('average',window);
    img = imfilter (image1,meanFilter);
end