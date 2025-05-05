function [bestRecognRate, bestInd] = findBestMdl(chromaRecognRate, mfccsRecognRate, allRecognRate)

timeV = max(chromaRecognRate);
fprintf('Max recognition rate with only [chroma] features: %.3f\n', timeV);

freqV = max(mfccsRecognRate);
fprintf('Max recognition rate with only [mfccs] features: %.3f\n', freqV);

allV = max(allRecognRate);
fprintf('Max recognition rate with all the features: %.3f\n\n', allV);

maxV = [timeV, freqV, allV];

[~, bestInd] = max(maxV);

switch bestInd
    case 1
        bestRecognRate = chromaRecognRate;
    case 2
        bestRecognRate = mfccsRecognRate;
    case 3
        bestRecognRate = allRecognRate;
end

end