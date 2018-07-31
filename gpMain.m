clc; 
close all; 
clear; 
pause on;
format short g
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

hypFlag = input('Calculate Hyper Parameters: 0  |  Test Hyper Parameters: [any #] = ');

%% Setting paths for training/testing
dataPath    = '/home/mouhyemen/desktop/research/safeLearning/data/';
trainAdd    = 'training/';
testAdd     = 'testing/';
hyperAdd    = 'hyper/';
alphaAdd    = 'alpha/';
sampleAdd   = 'trainSampled/';

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
    numTrainSamples  = input('# Training Samples = ');
    idx = randsample(length(trainInputs), numTrainSamples);
    trainInputs         = trainInputs(idx,:);
    trainObservations   = trainObservations(idx,:);

    numTestSamples  = input('# Testing Samples  = ');
    idx = randsample(length(testInputs), numTestSamples);
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
    states  = 4:9;      % phi, theta, psi, vx, vy, vz
elseif stateFlag == 9
    states  = 1:9;      % x, y, z, phi, theta, psi, vx, vy, vz
elseif stateFlag == 12
    states  = 1:12;     % x, y, z, phi, theta, psi, vx, vy, vz, p, q, r
end

[trainDiffOutput, trainRbd] = computeDiff(dataPath, trainInputs, trainObservations);
trainData = trainInputs(:, states);

[testDiffOutput, testRbd] = computeDiff(dataPath, testInputs, testObservations);
testData = testInputs(:, states);
fprintf('Training Data Size:    %dx%d | Testing Data Size:  %dx%d\n', size(trainData,1), size(trainData,2), ...
    size(testData,1), size(testData, 2) );

%% Calculate hyper parameters for training/testing data
if hypFlag == 0
    tic
    covValue = [10 10];
    likValue = 10;
    fprintf('Calculating hyperparameters ... \n');
    hyp = calcHyperParamters(trainData, trainDiffOutput, covValue, likValue);
    fprintf('Done!\n\n');
    hyp
    toc
    
    %% Save hyper parameters    
    if sample == 1
        hypName = strcat('hyp', num2str(trainFileNumber),'_',num2str(stateFlag),'_sampled' );
    else
        hypName = strcat('hyp', num2str(trainFileNumber),'_',num2str(stateFlag) );
    end
    
    hypNameCheck = input( strcat( 'Save proposed name:', hypName, '  | Yes: 1    | No: 0    | Else type your own name:') ,'s');
    if hypNameCheck == '1'
        save( strcat(dataPath, hyperAdd, hypName) , 'hyp' );
    elseif hypNameCheck == '0'
    else
        hypName = hypNameCheck;
        save( strcat(dataPath, hyperAdd, hypNameCheck) , 'hyp' );
    end
end

%% Compute mean and variance
if sample == 1
    loadName = strcat('hyp', num2str(trainFileNumber),'_',num2str(stateFlag),'_sampled' );
else
    loadName = strcat('hyp', num2str(trainFileNumber),'_',num2str(stateFlag) );
end

loadNameCheck = input( strcat( 'Load file:', loadName, '  | Yes: 1    | Else type your own name:') ,'s');
if loadNameCheck == '1'
    load( strcat(dataPath, hyperAdd, loadName) );
else
    load( strcat(dataPath, hyperAdd, loadNameCheck) );
end

[muTrain, varTrain] = computeMeanVariance(hyp, trainData, trainDiffOutput, trainData);
[muTest, varTest]   = computeMeanVariance(hyp, trainData, trainDiffOutput, testData);

%% Compute predictions
trainPred   = trainRbd + muTrain;
testPred    = testRbd + muTest;

% Evaluate normalized-MSE on predicted data & obser from test data
nMSE_Pred   = computeNMSE(testPred, testObservations);

nMSE_RBD    = computeNMSE(testRbd, testObservations);

fprintf('Order of improvement in prediction:\n');
disp((nMSE_RBD./nMSE_Pred))

%% Finding prediction vector offline | alpha_k = inv( K + sigma*I )*( y - M(X) )
%  [y - M(x)] - trainDiffOutput
alpha = getAlpha(hyp, trainData, trainDiffOutput);
fprintf('Alpha dimensions:    %4dx%4d \n\n', size(alpha,1), size(alpha,2)) ;

%% Save alpha matrix
if loadNameCheck == '1'
    alphaName = strcat('alpha_File', num2str(trainFileNumber), '_State',num2str(stateFlag), '_', loadName );
else
    alphaName = strcat('alpha_File', num2str(trainFileNumber), '_State',num2str(stateFlag), '_', loadNameCheck);
end

alphaNameCheck = input( strcat( 'Save proposed name:', alphaName, '\nYes: 1    | No: 0    | Else type your own name:') ,'s');
if alphaNameCheck == '1'
    save( strcat(dataPath, alphaAdd, alphaName) , 'alpha' );
elseif alphaNameCheck == '0'
else
    alphaName = alphaNameCheck;
    save( strcat(dataPath, alphaAdd, alphaName) , 'alpha' );
end

%% Evaluating alpha performance
numTestSamples  = length(testData);
numTrainSamples = length(trainData);
tic
for j=1:numTestSamples
    % fprintf('Query point %d/%d\n', j, numTestSamples);

    xq = testData(j, :);
    for n = 1 : numTrainSamples
        k(n) = calcKernel(hyp, trainData(n,:), xq);
    end
    kernelBody(j,:)  = testRbd(j,:) + k*alpha;
%     kAlpha(j,:)     = k*alpha;
%     kValues(:,j)    = k';
end
toc

%% Evaluate normalized-MSE on predicted torque and torque from testing set
nMSE_Alpha = computeNMSE(kernelBody, testObservations);

nMSE_RBD = computeNMSE(testRbd, testObservations);

fprintf('Order of improvement in prediction:\n');
disp((nMSE_RBD./nMSE_Alpha))

%% Save sampled data into data/trainSampled folder
%  if sampled -> save trainInput*, trainObservation*, trainDiff*,
%  trainRbd*, trainData*

trainSampledName = strcat( 'trainSampled', alphaName(6:end) );
trainSampledCheck = input( strcat( 'Save proposed name:', trainSampledName, '\nYes: 1    | No: 0    | Else type your own name:') ,'s');
if trainSampledCheck == '1'
    save( strcat( dataPath, sampleAdd, trainSampledName ) , 'trainInputs', 'trainObservations' ,'trainDiffOutput' ,'trainRbd' ,'trainData');
elseif trainSampledCheck == '0'
else
    trainSampledName = trainSampledCheck;
    save( strcat( dataPath, sampleAdd, trainSampledName ) , 'trainInputs', 'trainObservations' ,'trainDiffOutput' ,'trainRbd' ,'trainData');
end

%% Plotting alpha values along each dimension
plotAlpha = 0;
if plotAlpha==1
    rows = 2;   cols = 3;
    for i = 1:6
        subplot(rows, cols, i);
        plot(linspace(1,length(alpha),length(alpha)), alpha(:,i), 'r');
        grid on;
        xlabel('Time (seconds)','Interpreter','latex');
        ylabel('Alpha','Interpreter','latex');
        leg1 = legend('$\alpha_{kernel}$');
        %     leg1 = legend('$\tau_{kernel}$','$\tau_{gpml}$');
        set(leg1,'Interpreter','latex');
        %     title(['Joint ', num2str(i)],'Interpreter','latex');
    end
end
