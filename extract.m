% Define the folder containing your audio files
inputFolder = "path_foldera";  % Replace with your audio folder path
outputFolder = "path_folder";  % Replace with the folder to save feature vectors

% Ensure the output folder exists
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

% Get a list of all audio files (assuming WAV format)
audioFiles = dir(fullfile(inputFolder, '*.wav'));

% Loop through each audio file
for k = 1:length(audioFiles)
    % Load the audio file
    audioFilePath = fullfile(audioFiles(k).folder, audioFiles(k).name);
    [y, fs] = audioread(audioFilePath); % y is the audio signal, fs is the sampling frequency

    % Step 1: Extract MFCC Features
    numCoeffs = 13; % Number of MFCC coefficients to extract
    windowLength = round(0.025 * fs); % 25 ms window length
    overlapLength = round(0.015 * fs); % 15 ms overlap length

    % Create the Hamming window
    window = hamming(windowLength, 'periodic');

    % Extract MFCC coefficients using MATLAB's mfcc function
    mfccFeatures = mfcc(y, fs, 'Window', window, 'OverlapLength', overlapLength, 'NumCoeffs', numCoeffs);

    % Step 2: Extract Delta and Delta-Delta Features
    % Define the delta filter
    deltaFilter = [1 0 -1] / 2;

    % Calculate Delta features (First derivative of MFCC)
    deltaFeatures = filter(deltaFilter, 1, mfccFeatures);

    % Calculate Delta-Delta features (Second derivative of MFCC)
    deltaDeltaFeatures = filter(deltaFilter, 1, deltaFeatures);

    % Step 3: Combine MFCC, Delta, and Delta-Delta features
    % Each row in the combined feature set corresponds to a frame
    combinedFeatures = [mfccFeatures deltaFeatures deltaDeltaFeatures];

    % Step 4: Save Combined Features as a .mat File
    % Create a name for the output .mat file based on the input audio file name
    [~, name, ~] = fileparts(audioFiles(k).name);
    outputFilePath = fullfile(outputFolder, [name '_features.mat']);

    % Save the combined feature vector in the output .mat file
    featureVector = combinedFeatures; % Use the name 'featureVector' to keep it consistent
    save(outputFilePath, 'featureVector');

    % Print progress
    disp(['Saved feature vector for file: ' audioFiles(k).name ' to ' outputFilePath]);
end

disp('Feature extraction completed for all files.');
