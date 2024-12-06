% Choose an audio file to visualize (for example, the first one)
fileIndex = 10;
if fileIndex > length(allFeatures)
    error('File index exceeds the number of available audio files.');
end

% Extract the feature matrix of the selected file
selectedFeatures = allFeatures{fileIndex};

% Separate MFCC and pitch values
numMFCCs = 13;
mfccFeatures = selectedFeatures(:, 1:numMFCCs);
pitchFeatures = selectedFeatures(:, numMFCCs+1);

% Plot MFCC Features
figure;
imagesc(mfccFeatures');
colorbar;
xlabel('Frame Index');
ylabel('MFCC Coefficient Index');
title(['MFCC Features for File Index ', num2str(fileIndex)]);
set(gca, 'YDir', 'normal');

% Plot Pitch Features
figure;
plot(pitchFeatures);
xlabel('Frame Index');
ylabel('Pitch (Hz)');
title(['Pitch Contour for File Index ', num2str(fileIndex)]);
grid on;
