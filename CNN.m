% Convert spectrogram to 2D image for CNN input
imageData = imresize(spectrogramLog, [128, 128]); % Resize for CNN input

% Prepare data for training
inputData = reshape(imageData, [128, 128, 1]); % Add channel dimension
labels = categorical([0]); % Binary label (e.g., 0 for healthy, 1 for diseased)

% Define simple CNN architecture
layers = [
    imageInputLayer([128, 128, 1], 'Name', 'input')
    convolution2dLayer(3, 16, 'Padding', 'same', 'Name', 'conv1')
    batchNormalizationLayer('Name', 'batchnorm1')
    reluLayer('Name', 'relu1')
    maxPooling2dLayer(2, 'Stride', 2, 'Name', 'maxpool1')
    convolution2dLayer(3, 32, 'Padding', 'same', 'Name', 'conv2')
    batchNormalizationLayer('Name', 'batchnorm2')
    reluLayer('Name', 'relu2')
    fullyConnectedLayer(2, 'Name', 'fc')
    softmaxLayer('Name', 'softmax')
    classificationLayer('Name', 'output')];

% Specify training options
options = trainingOptions('adam', ...
    'InitialLearnRate', 0.001, ...
    'MaxEpochs', 10, ...
    'MiniBatchSize', 32, ...
    'Plots', 'training-progress');

% Train the CNN
net = trainNetwork(inputData, labels, layers, options);
