function clusterAlg(featsMatrix, ground_truth, category, xLabel, yLabel)

idx3 = kmeans(featsMatrix,3);

figure;
subplot(1,2,1)
gscatter(featsMatrix(:,1), featsMatrix(:,2), ground_truth)
xlabel(xLabel)
ylabel(yLabel)
title('Ground Truth')
legend('Electronic - 1', 'Jazz - 2', 'Metal - 3')

subplot(1,2,2)
gscatter(featsMatrix(:,1), featsMatrix(:,2), idx3)
xlabel(xLabel)
ylabel(yLabel)
title([category, ' - clustering 3'])
legend('cluster 1', 'cluster 2', 'cluster 3')

end