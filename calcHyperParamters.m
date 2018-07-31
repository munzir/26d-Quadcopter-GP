function hyp = calcHyperParamters(data, output, covValues, likValue)
meanfunc = [];              % No mean
covfunc = @covSEiso;        % Squared Exponental covariance function
likfunc = @likGauss;        % Gaussian likelihood

%[7.6941 12.5268] , 'lik', -2.5548);
hypInput  = struct('mean',[], 'cov', covValues , 'lik', likValue);
hyp = minimize(hypInput, @gp, -150, @infGaussLik, meanfunc, covfunc, likfunc, ...
    data, output);
disp('Hyperparamters calculated by optimizing marginal likelihood.');

end