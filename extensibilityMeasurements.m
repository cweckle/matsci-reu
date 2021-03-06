function length = extensibilityMeasurements(f,vidFrame)

length = processImage(f,vidFrame);

% heightBefore = processImage('sample2before.png');
% heightAfter = processImage('sample2after.png');
% fprintf('STRAIN:\n');
% strainInPixels = heightAfter - heightBefore;
% fprintf('\t%5d - %5d = %5d\n',heightAfter,heightBefore,strainInPixels);
end

function height = processImage(f,rgbImage)
%[rgbImage, ~] = imread(fullFileName);
[BW,maskedRGBImage] = createMask(rgbImage);

% Get rid of small objects.  Note: bwareaopen returns a logical.
smallestAcceptableArea = 100;
BW = uint8(bwareaopen(BW, smallestAcceptableArea));

% Smooth the border using a morphological closing operation, imclose().
structuringElement = strel('disk', 20);
BW = imclose(BW, structuringElement);

% Fill in any holes in the regions, since they are most likely red also.
BW = uint8(imfill(BW, 'holes'));

% We need to convert the type of redObjectsMask to the same data type as redBand.
BW = cast(BW, class(maskedRGBImage));

[labeledImage, numberOfBlobs] = bwlabel(BW, 8);
blobMeasurements = regionprops(labeledImage, BW, 'BoundingBox');

fontSize = 13;
if numberOfBlobs == 1
    subplot(2,2,1);
    imshow(rgbImage);
    title('Original Before Image','FontSize',fontSize);
    subplot(2,2,2);
    imshow(maskedRGBImage);
    title('Processed Before Image', 'FontSize', fontSize);
elseif numberOfBlobs >= 2
    subplot(2,2,3);
    imshow(rgbImage);
    title('Original After Image','FontSize',fontSize);
    subplot(2,2,4);
    imshow(maskedRGBImage);
    title('Processed After Image','FontSize',fontSize);
end

if numberOfBlobs == 1
    box1 = blobMeasurements.BoundingBox;
    rectangle('Position',box1,'EdgeColor','y','LineWidth',1);
    height = box1(4);
    fprintf(1, 'BEFORE:\n');
    fprintf(1, '\tHeight Before: %5d pixels\n', height);
elseif numberOfBlobs == 2
    if blobMeasurements(1).BoundingBox(2) > blobMeasurements(2).BoundingBox(2)
        box1 = blobMeasurements(2);
        box2 = blobMeasurements(1);
    else
        box1 = blobMeasurements(1);
        box2 = blobMeasurements(2);
    end
    fprintf(1,'AFTER:\n');
    rectangle('Position',box1.BoundingBox,'EdgeColor','y','LineWidth',1);
    rectangle('Position',box2.BoundingBox,'EdgeColor','y','LineWidth',1);
    fprintf(1, '\tUpper y-value: %5d \n',box1.BoundingBox(2));
    fprintf(1, '\tLower y-value: %5d \n',box2.BoundingBox(2)+box2.BoundingBox(4));
    height = box2.BoundingBox(2)+box2.BoundingBox(4)-box1.BoundingBox(2);
    fprintf(1, '\tHeight After: %5d pixels \n', height);
    linkaxes;
elseif numberOfBlobs == 0
    uiwait(msgbox('No blobs found.'));
else
    drawnow;
    uiwait(msgbox('Too many blobs found. Please play around with minimum object size.'));
end

end

function [BW,maskedRGBImage] = createMask(RGB)
%createMask  Threshold RGB image using auto-generated code from colorThresholder app.
%  [BW,MASKEDRGBIMAGE] = createMask(RGB) thresholds image RGB using
%  auto-generated code from the colorThresholder app. The colorspace and
%  range for each channel of the colorspace were set within the app. The
%  segmentation mask is returned in BW, and a composite of the mask and
%  original RGB images is returned in maskedRGBImage.

% Auto-generated by colorThresholder app on 07-Jul-2020
%------------------------------------------------------


% Convert RGB image to chosen color space
I = rgb2lab(RGB);

% Define thresholds for channel 1 based on histogram settings
channel1Min = 0.525;
channel1Max = 100.000;

% Define thresholds for channel 2 based on histogram settings
channel2Min = 25.743;
channel2Max = 54.463;

% Define thresholds for channel 3 based on histogram settings
channel3Min = -16.032;
channel3Max = 48.941;

% Create mask based on chosen histogram thresholds
sliderBW = (I(:,:,1) >= channel1Min ) & (I(:,:,1) <= channel1Max) & ...
    (I(:,:,2) >= channel2Min ) & (I(:,:,2) <= channel2Max) & ...
    (I(:,:,3) >= channel3Min ) & (I(:,:,3) <= channel3Max);
BW = sliderBW;

% Initialize output masked image based on input image.
maskedRGBImage = RGB;

% Set background pixels where BW is false to zero.
maskedRGBImage(repmat(~BW,[1 1 3])) = 0;

end
