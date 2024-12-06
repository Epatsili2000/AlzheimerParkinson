% Directory of audio files
audioDir = "D:\Captures\Πτυχιακη-Kotro\PC-GITA_per_task_44100Hz\PC-GITA_per_task_44100Hz\Words\Sin normalizar\Control\apto";
audioFiles = dir(fullfile(audioDir, '*.wav'));  % Get all .wav files

% Target sampling frequency
target_fs = 16000;

% Initialize an empty cell array for storing features and labels
allFeatures = {};
allLabels = []; % Assuming you have corresponding labels

for i = 1:length(audioFiles)
    try
        % Load audio file
        audioFilePath = fullfile(audioDir, audioFiles(i).name);
        [audioIn, fs] = audioread(audioFilePath);
        
        % Resample to target frequency
        audioIn = resample(audioIn, target_fs, fs);
        
        % Denoise the audio using wavelet denoising
        level = 5; % Level of decomposition for wavelet
        wname = 'db1'; % Daubechies wavelet
        [coeffs, l] = wavedec(audioIn, level, wname); % Decompose
        % Estimate universal threshold
        threshold = median(abs(coeffs)) / 0.6745;
        % Apply soft thresholding to the wavelet coefficients
        denoised_coeffs = wthresh(coeffs, 's', threshold);
        % Reconstruct the denoised audio
        audioIn = waverec(denoised_coeffs, l, wname);
        
        % Extract MFCC features
        numMFCCs = 13; % Number of MFCC coefficients to extract
        coeffs = mfcc(audioIn, target_fs, 'NumCoeffs', numMFCCs, 'LogEnergy', 'Replace');
        numFramesMFCC = size(coeffs, 1);

        % Extract Pitch values
        pitchValues = pitch(audioIn, target_fs, 'Method', 'PEF', 'Range', [50, 400]);
        numFramesPitch = length(pitchValues);

        % Align number of frames for MFCC and pitch using interpolation
        pitchAligned = interp1(linspace(1, numFramesPitch, numFramesPitch), pitchValues, ...
                               linspace(1, numFramesPitch, numFramesMFCC), 'linear')';

        % Concatenate MFCC and pitch features
        featureMatrix = [coeffs, pitchAligned];

        % Store Features for Current Audio File
        allFeatures{end+1} = featureMatrix;  % Add to the end of the cell array
        
        % Assuming that you have labels for each file in a specific order
        % Here you should replace 'i' with an actual label if available.
        allLabels = [allLabels; i];
        
    catch ME
        % Display error message and skip to the next file
        fprintf('Error processing file %s: %s\n', audioFiles(i).name, ME.message);
        continue;
    end
end

% Check if allFeatures is not empty before proceeding
if isempty(allFeatures)
    error('No features were extracted from the audio files. Please check the input files.');
end

% Convert feature cells to a suitable matrix for training if needed
% Assuming different files have different lengths, use padding
maxLength = max(cellfun(@(x) size(x, 1), allFeatures));
numFeatures = size(allFeatures{1}, 2);

% Prepare a matrix for storing padded features
paddedFeatures = zeros(length(allFeatures), maxLength, numFeatures);

for i = 1:length(allFeatures)
    featureData = allFeatures{i};
    paddedFeatures(i, 1:size(featureData, 1), :) = featureData;
end

% Summary: paddedFeatures now contains all audio features, where
% paddedFeatures(i, :, :) represents the i-th audio file's features.

disp('Audio analysis complete and features stored successfully.');
