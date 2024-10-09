% Define the folder containing the images
inputFolder = 'C:\Users\ripho\social_affective_prediction_task\create_task\create_stimuli\SHINE_toolbox\SHINE_INPUT';
outputFolder = 'C:\Users\ripho\social_affective_prediction_task\create_task\create_stimuli\SHINE_toolbox\SHINE_OUTPUT';
numIterations = 100;
% Check if the input folder exists
if ~isfolder(inputFolder)
    error('Input folder does not exist: %s', inputFolder);
end

% Initialize cell array to store processed images
imageF = cell(1, length(imageFiles));

% Loop through each image in the folder
for k = 1:length(imageFiles)
    % Get the file name and path
    baseFileName = imageFiles(k).name;
    fullFileName = fullfile(inputFolder, baseFileName);

    % Read the RGB image
    rgbImage = imread(fullFileName);
    
    % Convert RGB to greyscale
    greyImage = rgb2gray(rgbImage);
    
    % Apply luminance matching using SHINE
    lumMatchedImage = lumMatch({greyImage});
    specMatchedImage = sfMatch(lumMatchedImage);
    histMatchedImage = histMatch(specMatchedImage);

    for iter = 1:numIterations
        lumMatchedImage = lumMatch(lumMatchedImage);
        specMatchedImage = sfMatch(lumMatchedImage);
        histMatchedImage = histMatch(specMatchedImage);
    end

    imageF{k} = histMatchedImage{1};  % Extract actual image from cell
    
    outputFileName = fullfile(outputFolder, baseFileName);  % Keep the original file name
    imwrite(imageF{k}, outputFileName);  % Save the final image with gray background
end

disp('Processing complete! Images saved in SHINE_OUTPUT folder.');

% Check luminance matching across images
checkLuminanceMatching(imageF);

% Function to calculate luminance matching quality metrics
function checkLuminanceMatching(imageF)

    % Number of images
    numImages = length(imageF);

    % Initialize variables to store luminance statistics
    meanLuminance = zeros(numImages, 1);
    rmseLuminance = zeros(numImages, 1);

    % Calculate mean luminance and RMSE for each image
    for i = 1:numImages
        img = imageF{i};  % Extract the actual image matrix
        
        % Compute mean luminance for the current image
        meanLuminance(i) = mean(img(:));

        % Calculate RMSE (relative to the first image or a reference image)
        if i == 1
            referenceImage = img;  % Use the first image as the reference
        end
        rmseLuminance(i) = sqrt(mean((double(img(:)) - double(referenceImage(:))).^2));
    end

    % Calculate the overall standard deviation of luminance across images
    luminanceStdDev = std(meanLuminance);

    % Display results
    disp('Luminance Matching Quality Metrics:');
    for i = 1:numImages
        fprintf('Image %d - Mean Luminance: %.2f | RMSE to Reference: %.2f\n', ...
            i, meanLuminance(i), rmseLuminance(i));
    end

    % Overall statistics
    fprintf('\nOverall Luminance Std Dev: %.2f\n', luminanceStdDev);
end
