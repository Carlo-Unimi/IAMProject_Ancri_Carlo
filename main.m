%% START
clear; clc;
addpath(genpath(pwd));

saveImages = false;

warning('off');
flag = 0;
flag = startMenu(flag);

wL = 2.0; sL = 0.5;

disp('----- IAM PROJECT -----');
disp('Genre selected:');
fprintf(' . electronic\n . jazz\n . metal\n\n');
tic;

%% FEATURES EXTRACTION [chroma && mfccs]
totalSteps = 12;
currentStep = 0;
h = waitbar(0, 'Extracting chroma: electronic train');

fprintf('Extracting [chroma] features... ');
waitbar(currentStep/totalSteps, h, 'Extracting chroma: electronic train');
electronicTrC = extract_from_path_chroma(fullfile(pwd, 'data', 'electronic', 'train', filesep), 'mp3', wL, sL);
currentStep = currentStep + 1;

waitbar(currentStep/totalSteps, h, 'Extracting chroma: jazz train');
jazzTrC = extract_from_path_chroma(fullfile(pwd, 'data', 'jazz', 'train', filesep), 'mp3', wL, sL);
currentStep = currentStep + 1;

waitbar(currentStep/totalSteps, h, 'Extracting chroma: metal train');
metalTrC = extract_from_path_chroma(fullfile(pwd, 'data', 'metal', 'train', filesep), 'mp3', wL, sL);
currentStep = currentStep + 1;

waitbar(currentStep/totalSteps, h, 'Extracting chroma: electronic test');
electronicTeC = extract_from_path_chroma(fullfile(pwd, 'data', 'electronic', 'test', filesep), 'mp3', wL, sL);
currentStep = currentStep + 1;

waitbar(currentStep/totalSteps, h, 'Extracting chroma: jazz test');
jazzTeC = extract_from_path_chroma(fullfile(pwd, 'data', 'jazz', 'test', filesep), 'mp3', wL, sL);
currentStep = currentStep + 1;

waitbar(currentStep/totalSteps, h, 'Extracting chroma: metal test');
metalTeC = extract_from_path_chroma(fullfile(pwd, 'data', 'metal', 'test', filesep), 'mp3', wL, sL);
currentStep = currentStep + 1;

disp('done.');

fprintf('Extracting [mfccs] features... ');
waitbar(currentStep/totalSteps, h, 'Extracting mfccs: electronic train');
electronicTrM = extract_from_path(fullfile(pwd, 'data', 'electronic', 'train', filesep), 'mp3', wL, sL);
currentStep = currentStep + 1;

waitbar(currentStep/totalSteps, h, 'Extracting mfccs: jazz train');
jazzTrM = extract_from_path(fullfile(pwd, 'data', 'jazz', 'train', filesep), 'mp3', wL, sL);
currentStep = currentStep + 1;

waitbar(currentStep/totalSteps, h, 'Extracting mfccs: metal train');
metalTrM = extract_from_path(fullfile(pwd, 'data', 'metal', 'train', filesep), 'mp3', wL, sL);
currentStep = currentStep + 1;

waitbar(currentStep/totalSteps, h, 'Extracting mfccs: electronic test');
electronicTeM = extract_from_path(fullfile(pwd, 'data', 'electronic', 'test', filesep), 'mp3', wL, sL);
currentStep = currentStep + 1;

waitbar(currentStep/totalSteps, h, 'Extracting mfccs: jazz test');
jazzTeM = extract_from_path(fullfile(pwd, 'data', 'jazz', 'test', filesep), 'mp3', wL, sL);
currentStep = currentStep + 1;

waitbar(currentStep/totalSteps, h, 'Extracting mfccs: metal test');
metalTeM = extract_from_path(fullfile(pwd, 'data', 'metal', 'test', filesep), 'mp3', wL, sL);

disp('done.');
close(h);


fprintf('Normalization...\n\n');

% creating labels (train/test-mfcc and train/test-chroma matricies are equally long)
labelElecTr = ones(length(electronicTrM), 1);
labelJazzTr = repmat(2, length(jazzTrM), 1);
labelMetaTr = repmat(3, length(metalTrM), 1);
allLabels = [labelElecTr; labelJazzTr; labelMetaTr];

labelElecTe = ones(length(electronicTeM), 1);
labelJazzTe = repmat(2, length(jazzTeM), 1);
labelMetaTe = repmat(3, length(metalTeM), 1);
ground_truth = [labelElecTe; labelJazzTe; labelMetaTe];

ids = [labelElecTr; labelJazzTr; labelMetaTr; labelElecTe; labelJazzTe; labelMetaTe];


% creating matricies
chromaTrain = [electronicTrC jazzTrC metalTrC];
chromaTest = [electronicTeC jazzTeC metalTeC];

mfccsTrain = [electronicTrM jazzTrM metalTrM];
mfccsTest = [electronicTeM jazzTeM metalTeM];

allTrain = [chromaTrain; mfccsTrain];
allTest = [chromaTest; mfccsTest];

allChroma = [chromaTrain chromaTest];
allMfccs = [mfccsTrain mfccsTest];
allFeats = [allChroma; allMfccs];

% normalization
[chromaTrain, chromaTest, mnCr, stCr] = normalization(chromaTrain, chromaTest);
[mfccsTrain, mfccsTest, mn, st] = normalization(mfccsTrain, mfccsTest);
[allTrain, allTest, mnAll, stAll] = normalization(allTrain, allTest);

allChroma = normalize(allChroma);
allMfccs = normalize(allMfccs);
allFeats = normalize(allFeats);


%% K-MEANS TO CLUSTER
clusterAlg(allChroma', ids, '[chroma]-feats', '1st CHROMA', '2nd CHROMA');
clusterAlg(allMfccs', ids, '[mfccs]-feats', '1st MFCC', '2nd MFCC');
clusterAllFeats = allFeats([1, 14], :);
clusterAlg(clusterAllFeats', ids, '[all]-feats', '1st MFCC', '1st CHROMA');


%% K-NN CLASSIFIER
disp('INITIALIZE K-NN ALGORITHM...');
k = [1 3 5 10 20 35 50 100 150];

[chromaRecognRate, chromaMdl, knn_predictedChroma] = knnTrainer(chromaTrain, chromaTest, allLabels, ground_truth, k);
[mfccsRecognRate, mfccsMdl, knn_predictedMfccs] = knnTrainer(mfccsTrain, mfccsTest, allLabels, ground_truth, k);
[allRecognRate, allMdl, knn_predictedAll] = knnTrainer(allTrain, allTest, allLabels, ground_truth, k);

%find the best model
[bestRecognRate, bestInd] = findBestMdl(chromaRecognRate, mfccsRecognRate, allRecognRate);
names = ["[chroma]-feats"; "[mfccs]-feats"; "all-feats"];
disp('Finding the best model...');
[val, ind] = max(bestRecognRate);
fprintf('The best recognition rate is: %.3f, achieved with %d neighbours, using the %s trained model.\n\n', val, k(ind), names(bestInd));


%% DECISION TREE CLASSIFIER
disp('INITIALIZE THE DT ALGORITHM...'); % tested with 10 - 15 - 20 - 40 subdivisions
chromaTree = fitctree(chromaTrain, allLabels, 'MaxNumSplits', 15);
predictedChroma = predict(chromaTree, chromaTest);
mfccsTree = fitctree(mfccsTrain, allLabels, 'MaxNumSplits', 15);
predictedMfccs = predict(mfccsTree, mfccsTest);
allTree = fitctree(allTrain, allLabels, 'MaxNumSplits', 15);
predictedAll = predict(allTree, allTest);

if (flag == 1)
    view(chromaTree, 'mode', 'graph');
    title('[chroma] Decision Tree');
    view(mfccsTree, 'mode', 'graph');
    title('[mfccs] Decision Tree');
    view(allTree, 'mode', 'graph');
    title('[all-feats] Decision Tree');
end

fprintf('Done.\n\n');


%% NOISY CONDITIONS
noisyTestDir = fullfile(pwd, 'data', 'noisyTestDir');
mkdir(noisyTestDir);
addpath(noisyTestDir);

disp('Appliyng noise to the test set...');
procAndMrgAudio('electronic');
procAndMrgAudio('jazz');
procAndMrgAudio('metal');

fprintf('Extracting noisy features...\n\n');
noisyElectrCr = extract_from_path_chroma(fullfile(noisyTestDir, 'electronic', filesep), 'mp3', wL, sL);
noisyJazzCr = extract_from_path_chroma(fullfile(noisyTestDir, 'jazz', filesep), 'mp3', wL, sL);
noisyMetalCr = extract_from_path_chroma(fullfile(noisyTestDir, 'metal', filesep), 'mp3', wL, sL);

noisyElectr = extract_from_path(fullfile(noisyTestDir, 'electronic', filesep), 'mp3', wL, sL);
noisyJazz = extract_from_path(fullfile(noisyTestDir, 'jazz', filesep), 'mp3', wL, sL);
noisyMetal = extract_from_path(fullfile(noisyTestDir, 'metal', filesep), 'mp3', wL, sL);

% creating ground truth
noisyTeLabelElec = ones(length(noisyElectr), 1);
noisyTeLabelJazz = repmat(2, length(noisyJazz), 1);
noisyTeLabelMeta = repmat(3, length(noisyMetal), 1);
noisy_ground_truth = [noisyTeLabelElec; noisyTeLabelJazz; noisyTeLabelMeta];

% normalization
noisyCr = [noisyElectrCr noisyJazzCr noisyMetalCr];
noisyMf = [noisyElectr noisyJazz noisyMetal];
noisyAll = [noisyCr; noisyMf];

noisyCr = noisyCr';
noisyCr = (noisyCr - repmat(mnCr, length(noisyCr), 1)) ./repmat(stCr, length(noisyCr), 1);

noisyMf = noisyMf';
noisyMf = (noisyMf - repmat(mn, length(noisyMf), 1)) ./repmat(st, length(noisyMf), 1);

noisyAll = noisyAll';
noisyAll = (noisyAll - repmat(mnAll, length(noisyAll), 1)) ./repmat(stAll, length(noisyAll), 1);

% kNN on noisy set
disp('Testing the k-NN models...');
[noisyRecognRateCr, ~, kNN_noisyPredictedChroma] = knnTrainer(chromaTrain, noisyCr, allLabels, noisy_ground_truth, k);
[noisyRecognRateMfccs, ~, kNN_noisyPredictedMfccs] = knnTrainer(mfccsTrain, noisyMf, allLabels, noisy_ground_truth, k);
[noisyRecognRateAll, ~, kNN_noisyPredictedAll] = knnTrainer(allTrain, noisyAll, allLabels, noisy_ground_truth, k);

[bestRecognRate, bestInd] = findBestMdl(noisyRecognRateCr, noisyRecognRateMfccs, noisyRecognRateAll);
names = ["[chroma]-feats"; "[mfccs]-feats"; "all-feats"];
disp('Finding the best model...');
[val, ind] = max(bestRecognRate);
fprintf('The best recognition on the noisy test-set rate is: %.3f, achieved with %d neighbours, using the %s trained model.\n\n', val, k(ind), names(bestInd));

% testing DTs
disp('Testing the DTs...');
predictedChromaNoisy = predict(chromaTree, noisyCr);
predictedMfccsNoisy = predict(mfccsTree, noisyMf);
predictedAllNoisy = predict(allTree, noisyAll);

confM_chroma_noisy = confusionmat(noisy_ground_truth, predictedChromaNoisy);
confM_mfccs_noisy = confusionmat(noisy_ground_truth, predictedMfccsNoisy);
confM_all_noisy = confusionmat(noisy_ground_truth, predictedAllNoisy);

fprintf('Done.\n\n');

rmdir(noisyTestDir, 's');


%% CONFUSION MATRICIES  &&  CONCLUSION

% confusion matrix for DTs
DTGraphs = figure;
DTGraphs.Position = [100, 100, 1600, 400];
subplot(1, 3, 1);
confM_chroma = confusionmat(ground_truth, predictedChroma);
confusionchart(confM_chroma, {'Electronic' 'Jazz' 'Metal'}, 'Title', 'DT+[chroma]-feats music genre classification', 'RowSummary', 'row-normalized')
subplot(1, 3, 2);
confM_mfccs = confusionmat(ground_truth, predictedMfccs);
confusionchart(confM_mfccs, {'Electronic' 'Jazz' 'Metal'}, 'Title', 'DT+[mfccs]-feats music genre classification', 'RowSummary', 'row-normalized')
subplot(1, 3, 3);
confM_all = confusionmat(ground_truth, predictedAll);
confusionchart(confM_all, {'Electronic' 'Jazz' 'Metal'}, 'Title', 'DT+[all]-feats music genre classification', 'RowSummary', 'row-normalized')

% confusion matricies for k-NN
kNN_graphs_confM = figure;
kNN_graphs_confM.Position = [100, 100, 1600, 400];
subplot(1, 3, 1);
confM_knn_chroma = confusionmat(ground_truth, knn_predictedChroma);
confusionchart(confM_knn_chroma, {'Electronic' 'Jazz' 'Metal'}, 'Title', 'kNN+[chroma]-feats music genre classification', 'RowSummary', 'row-normalized')
subplot(1, 3, 2);
confM_knn_mfccs = confusionmat(ground_truth, knn_predictedMfccs);
confusionchart(confM_knn_mfccs, {'Electronic' 'Jazz' 'Metal'}, 'Title', 'kNN+[mfccs]-feats music genre classification', 'RowSummary', 'row-normalized')
subplot(1, 3, 3);
confM_knn_all = confusionmat(ground_truth, knn_predictedAll);
confusionchart(confM_knn_all, {'Electronic' 'Jazz' 'Metal'}, 'Title', 'kNN+[all]-feats music genre classification', 'RowSummary', 'row-normalized')

% confusion matrix of the noisy-set kNN
noisy_kNN_graphs = figure;
noisy_kNN_graphs.Position = [100, 100, 1600, 400];
subplot(1, 3, 1);
confM_knn_chroma_noisy = confusionmat(noisy_ground_truth, kNN_noisyPredictedChroma);
confusionchart(confM_knn_chroma_noisy, {'Electronic' 'Jazz' 'Metal'}, 'Title', 'NOISY kNN+[chroma]-feats music genre classification', 'RowSummary', 'row-normalized')
subplot(1, 3, 2);
confM_knn_mfccs_noisy = confusionmat(noisy_ground_truth, kNN_noisyPredictedMfccs);
confusionchart(confM_knn_mfccs_noisy, {'Electronic' 'Jazz' 'Metal'}, 'Title', 'NOISY kNN+[mfccs]-feats music genre classification', 'RowSummary', 'row-normalized')
subplot(1, 3, 3);
confM_knn_all_noisy = confusionmat(noisy_ground_truth, kNN_noisyPredictedAll);
confusionchart(confM_knn_all_noisy, {'Electronic' 'Jazz' 'Metal'}, 'Title', 'NOISY kNN+[all]-feats music genre classification', 'RowSummary', 'row-normalized')

% confusion matrix for noisy set DTs
noisyDTGraphs = figure;
noisyDTGraphs.Position = [100, 100, 1600, 400];
subplot(1, 3, 1); 
confusionchart(confM_chroma_noisy, {'Electronic' 'Jazz' 'Metal'}, 'Title', 'NOISY DT+[chroma]-feats music genre classification', 'RowSummary', 'row-normalized')
subplot(1, 3, 2);
confusionchart(confM_mfccs_noisy, {'Electronic' 'Jazz' 'Metal'}, 'Title', 'NOISY DT+[mfccs]-feats music genre classification', 'RowSummary', 'row-normalized')
subplot(1, 3, 3);
confusionchart(confM_all_noisy, {'Electronic' 'Jazz' 'Metal'}, 'Title', 'NOISY DT+[all]-feats music genre classification', 'RowSummary', 'row-normalized')

% knn Graphs
knnGraphs = figure;
knnGraphs.Position = [100, 100, 1500, 500];
subplot(1, 3, 1); plot(k, chromaRecognRate, 'b-', k, noisyRecognRateCr, 'r--*')
xlabel('k');
title('[chroma] recognition rate (%)');
grid on

subplot(1, 3, 2); plot(k, mfccsRecognRate, 'b-', k, noisyRecognRateMfccs, 'r--*')
xlabel('k');
title('[mfccs] recognition rate (%)');
grid on

subplot(1, 3, 3); plot(k, allRecognRate, 'b-', k, noisyRecognRateAll, 'r--*')
xlabel('k');
title('All feat recognition rate (%)');
grid on

%% END PROGRAM
imagePath = fullfile(pwd, 'graphs');

if saveImages == true
    if ~exist(imagePath, 'dir')
        mkdir(imagePath);
        addpath(imagePath);
    end
    saveas(DTGraphs, fullfile(imagePath, 'DtGraphs.png'));
    saveas(knnGraphs, fullfile(imagePath, 'knnGraphs.png'));
    saveas(noisy_kNN_graphs, fullfile(imagePath, 'noisyKNNGraphs.png'));
    saveas(noisyDTGraphs, fullfile(imagePath, 'noisyDTGraphs.png'));
    saveas(kNN_graphs_confM, fullfile(imagePath, 'knn_confM.png'));
end

clear st* mn* best* currentStep totalSteps h ind names flag val noisyRec* predicted* saveImages imagePath;

fprintf('Execution time: %.1f\n', toc);
