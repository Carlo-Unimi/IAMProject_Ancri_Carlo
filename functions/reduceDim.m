function [matrix, testMatrix, coeff, mu, numCom] = reduceDim(matrix, testMatrix, variance)

[coeff, score, ~, ~, explained, mu] = pca(matrix);
cumVar = cumsum(explained);
numCom = find(cumVar >= variance, 1, 'first');

matrix = score(:, 1:numCom);

[~, scoreTest, ~, ~, ~, ~] = pca(testMatrix);

testMatrix = scoreTest(:, 1:numCom);

end