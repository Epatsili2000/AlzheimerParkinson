% Initialize accumulators for calculating average features
totalMFCC = zeros(numMFCCs, 1);
totalPitch = 0;
count = 0;

% Loop through all feature matrices to calculate the mean of MFCC and pitch
for i = 1:length(allFeatures)
    featureMatrix = allFeatures{i};

    % Extract MFCCs and pitch
    mfccs = featureMatrix(:, 1:numMFCCs);
    pitch = featureMatrix(:, numMFCCs + 1);

    % Update accumulators
    totalMFCC = totalMFCC + mean(mfccs, 1)'; % Mean MFCC per file
    totalPitch = totalPitch + mean(pitch);   % Mean Pitch per file
    count = count + 1;
end

% Calculate average features
avgMFCC = totalMFCC / count;
avgPitch = totalPitch / count;

% Plot average MFCC coefficients
figure;
bar(avgMFCC);
xlabel('MFCC Coefficient Index');
ylabel('Average Value');
title('Average MFCC Coefficients Across All Audio Files');
grid on;

% Display average pitch
fprintf('Average Pitch Across All Audio Files: %.2f Hz\n', avgPitch);
