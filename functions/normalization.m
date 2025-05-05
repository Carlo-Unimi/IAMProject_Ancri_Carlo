function [trainMatrix, testMatrix, mn, st] = normalization(trainMatrix, testMatrix)

trainMatrix = trainMatrix';
mn = mean(trainMatrix);
st = std(trainMatrix);
trainMatrix = (trainMatrix - repmat(mn, length(trainMatrix), 1)) ./repmat(st, length(trainMatrix), 1);

testMatrix = testMatrix';
testMatrix = (testMatrix - repmat(mn, length(testMatrix), 1)) ./repmat(st, length(testMatrix), 1);

end