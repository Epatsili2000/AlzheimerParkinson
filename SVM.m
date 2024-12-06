% Directory containing the extracted feature .mat files
featureDir = "path_folder";

% Get a list of all .mat files in the directory
featureFiles = dir(fullfile(featureDir, '*.mat'));

% Initialize feature vectors and labels
featureVectors = [];
labels = [];

% Loop through each .mat file to load features
for i = 1:length(featureFiles)
    % Load the feature vector
    featureFilePath = fullfile(featureFiles(i).folder, featureFiles(i).name);
    data = load(featureFilePath);

    % Append the feature vector
    featureVectors = [featureVectors; data.featureVector]; % Stack features vertically

    % Assign a label for all frames in the file
    if contains(featureFiles(i).name, 'pd') % Example: if file name contains 'pd'
        fileLabel = 1; % Label 1
    else
        fileLabel = 0; % Label 0
    end
    labels = [labels; repmat(fileLabel, size(data.featureVector, 1), 1)]; % Replicate the label for all frames
end

% Ensure the number of labels matches the number of feature vectors
if size(featureVectors, 1) ~= numel(labels)
    error('The number of feature vectors (%d) and labels (%d) must match.', ...
          size(featureVectors, 1), numel(labels));
end

% Convert labels to categorical
labels = categorical(labels);

% Partition data for training and testing
cv = cvpartition(size(featureVectors, 1), 'HoldOut', 0.2);
trainIdx = training(cv);
testIdx = test(cv);

% Prepare training and test sets
XTrain = featureVectors(trainIdx, :);
YTrain = labels(trainIdx);
XTest = featureVectors(testIdx, :);
YTest = labels(testIdx);

% Train an SVM model
SVMModel = fitcsvm(XTrain, YTrain, 'KernelFunction', 'linear', 'Standardize', true);

% Predict using the test set
YPred = predict(SVMModel, XTest);

% Calculate accuracy
accuracy = sum(YPred == YTest) / numel(YTest);
fprintf('Test Accuracy: %.2f%%\n', accuracy * 100);
