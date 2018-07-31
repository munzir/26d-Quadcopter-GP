clc; close all; clear; pause on; format short g;
%% Setting up GPML
fprintf('Adding GPML 4.1 path ... ')
if true
    gpmlPath = '/home/mouhyemen/desktop/software/gpml_4.1/v4.1-2017-10-19/';
    addpath(gpmlPath);
    addpath(strcat(gpmlPath,'cov'));
    addpath(strcat(gpmlPath,'doc'));
    addpath(strcat(gpmlPath,'inf'));
    addpath(strcat(gpmlPath,'lik'));
    addpath(strcat(gpmlPath,'mean'));
    addpath(strcat(gpmlPath,'prior'));
    addpath(strcat(gpmlPath,'util'));
    fprintf('Done!\n');
end

%% Setting paths for training/testing
dataPath = '/home/mouhyemen/desktop/research/safeLearning/data/';
trainAdd = 'training/';
testAdd  = 'testing/';
hyperAdd = 'hyper/';
alphaAdd = 'alpha/';

load(strcat(dataPath,'modes.mat'));

trainFileNumber = input('Load file number for Training  =  ' );
testFileNumber  = input('Load file number for Testing   =  ' );

%% Setup the correct file name based on user input and control/dynamics modes
if unmodel_dynamics == 1
    tail = 'EPS';
    if use_QP_u1 == 1 && use_QP_txy == 0
        tail = strcat(tail, '_', 'u1');
    elseif use_QP_txy == 1 && use_QP_u1 == 0
        tail = strcat(tail, '_', 'txy');
    elseif use_QP_txy == 1 && use_QP_u1 == 1
        tail = strcat(tail, '_', 'u1_txy');
    end
else
    if use_QP_u1 == 1 && use_QP_txy == 0
        tail = 'u1';
    elseif use_QP_txy == 1 && use_QP_u1 == 0
        tail = 'txy';
    elseif use_QP_txy == 1 && use_QP_u1 == 1
        tail = 'u1_txy';
    end
end

%% Description
%       Input - [x,y,z,phi,theta,psi,vx,vy,vz,p,q,r,F,R13,R23,R33,Tx,Ty,Tz]
%       Obser - [ddx, ddy, ddz, dp, dq, dr]
%% Load training/testing inputs and observations
trainPath = strcat(dataPath, trainAdd, 'train_', num2str(trainFileNumber), '_', tail, '.mat');
[trainInputs, trainObservations] = loadData(trainPath);
fprintf('Training Input Size:   %dx%d | Training Observation Size:  %dx%d\n', size(trainInputs,1), size(trainInputs,2), ...
    size(trainObservations,1), size(trainObservations, 2) );

testPath = strcat(dataPath, testAdd, 'test_', num2str(testFileNumber), '_', tail, '.mat');
[testInputs, testObservations] = loadData(testPath);
fprintf('Testing Input Size:    %dx%d | Testing Observation Size:   %dx%d\n', size(testInputs,1), size(testInputs,2), ...
    size(testObservations,1), size(testObservations, 2) );


%% Description
%       Data        - [x,y,z,phi,theta,psi,vx,vy,vz,p,q,r]
%       ddx_diff    - ddx_sample - ddx_rbd      [same for y,z]
%       dp_diff     - dp_sample - dp_rbd        [same for q,r]
%% Create training/testing data for GP
sample = input('Sample data: 1  | Do not sample data: ~ = ');
if sample == 1
    numSamples  = input('# Training Samples = ');
    idx = randsample(length(trainInputs), numSamples);
    trainInputs         = trainInputs(idx,:);
    trainObservations   = trainObservations(idx,:);
    
    numSamples  = input('# Testing Samples  = ');
    idx = randsample(length(testInputs), numSamples);
    testInputs          = testInputs(idx,:);
    testObservations    = testObservations(idx,:);
end
stateFlag = 0;
while stateFlag ~= 4 && stateFlag ~= 6 && stateFlag ~= 9 && stateFlag ~= 12
    stateFlag   = input('Choose number of states for training [4, 6, 9, 12] : ');
end
if stateFlag == 4
    states  = [1:3,9];  % x, y, z, psi
elseif stateFlag == 6
    states  = 1:6;      % x, y, z, phi, theta, psi
elseif stateFlag == 9
    states  = 1:9;      % x, y, z, phi, theta, psi, vx, vy, vz
elseif stateFlag == 12
    states  = 1:12;     % x, y, z, phi, theta, psi, vx, vy, vz, p, q, r
end

[trainDiffOutput, trainRbd] = computeDiff(dataPath, trainInputs, trainObservations);
trainData = trainInputs(:, states);

[testDiffOutput, testRbd] = computeDiff(dataPath, testInputs, testObservations);
testData = testInputs(:, states);
fprintf('Training Data Size:    %dx%d | Testing Data Size:  %dx%d\n\n', size(trainData,1), size(trainData,2), ...
    size(testData,1), size(testData, 2) );

fprintf('-----------------------------------------------------------------------------------------------------\n\n');

%% Compute mean and variance

hypFiles = dir( strcat(dataPath, hyperAdd, 'hyp*.mat') );
idx = 1;
for i = 1:length(hypFiles)
    begin = tic;
    %     fprintf('Loading file name: %s\n', hypFiles(i).name);
    load( strcat( dataPath, hyperAdd, hypFiles(i).name) );
    
    % Compute alpha
    alpha = getAlpha(hyp, trainData, trainDiffOutput);
    
    % Evaluating alpha performance
    numTestSamples  = length(testInputs);
    numTrainSamples = length(trainInputs);
    tic
    fprintf('Computing k(x*) at test points. ');
    for j=1:numTestSamples
        %fprintf('Query point %d/%d\n', j, numTestSamples);
        
        xq = testInputs(j, states);
        for k = 1 : numTrainSamples
            kstar(k) = calcKernel(hyp, trainData(k,:), xq);
        end
        kernelBody(j,:)  = testRbd(j,:) + kstar*alpha;
    end
    toc
    
    %% Evaluate normalized-MSE on predicted torque and torque from testing set
    nMSE_Alpha = computeNMSE(kernelBody, testObservations);
    % fprintf('[nMSE] Alpha Predictions and Observations:\n');
    % disp(nMSE_Alpha);
    
    nMSE_RBD = computeNMSE(testRbd, testObservations);
    % fprintf('[nMSE] RBD and observations:\n');
    % disp(nMSE_RBD);
    
    % fprintf('Order of improvement in prediction:\n');
    ratio = nMSE_RBD./nMSE_Alpha ;
    ratio_hist(idx,:) = [ratio i];
    idx = idx + 1;
    
    fprintf('-----------------------------------------------------------------------\n');
    fprintf('       Total Time:              ');
    toc(begin);
    fprintf('\n');
end

%% Displaying Results
clc;
min_desired = [1 1 1 1 1 1];    % min improvement along each dim
min_cond_met = 4;             	% min number of improvements met

max_idx = find( sum(ratio_hist(:,1:6) > min_desired ,2) >= min_cond_met);
if isempty(max_idx)
    disp('No improvements found.');
    return;
end
max_ratio = ratio_hist(max_idx, 1:end-1);

if size(max_ratio,1) >= 5
    abv_mean = max_ratio>=mean(max_ratio);
    max_ratio_copy = [max_ratio ratio_hist(max_idx,end)];
    
    abv_mean_idx = find( sum(abv_mean,2) >= min_cond_met);
    
    if isempty(abv_mean_idx)
        for i=1:length(max_idx)
            jdx = max_idx(i);
            fprintf('%8.3f  %8.3f  %8.3f  %8.3f  %8.3f  %11.3f  [%3d]   |   %s\n', ...
                ratio_hist(jdx, 1:end), hypFiles(ratio_hist(jdx, end)).name );
        end
    else
        for i=1:length(abv_mean_idx)
            jdx = abv_mean_idx(i);
            fprintf('%8.3f  %8.3f  %8.3f  %8.3f  %8.3f  %11.3f  [%3d]   |   %s\n', ...
                ratio_hist(jdx, 1:end), hypFiles(ratio_hist(jdx, end)).name );
        end
    end
else
    for i=1:length(max_idx)
        jdx = max_idx(i);
        fprintf('%8.3f  %8.3f  %8.3f  %8.3f  %8.3f  %11.3f  [%3d]   |   %s\n', ...
            ratio_hist(jdx, 1:end), hypFiles(ratio_hist(jdx, end)).name );
    end
end