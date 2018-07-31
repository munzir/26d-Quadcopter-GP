function [mu, variance] = computeMeanVariance(hyp, trainData, diffOutput, testData)
    meanfunc = [];              % No mean
    covfunc = @covSEiso;        % Squared Exponental covariance function
    likfunc = @likGauss;        % Gaussian likelihood

    [mu, variance] = gp(  hyp, @infGaussLik, meanfunc, covfunc, likfunc, ...
        trainData, diffOutput, testData);
%     predictions_test = phiBetaMean + mu;
end