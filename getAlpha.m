function alpha = getAlpha(hyp, trainData, diffData)
    sigma_n = hyp.lik;
    num_samples = size(trainData,1);
    tic
    fprintf('Computing covariance matrix K.  ');
    
    tic
    for i = 1:num_samples
        %fprintf('Query point %d/%d\n', i, num_samples);
        % Diagonal element
        K(i,i) = calcKernel(hyp, trainData(i,:), trainData(i,:) );
        
        for j= i+1 : num_samples
            temp = calcKernel(hyp, trainData(i,:), trainData(j,:));
            K(i,j) = temp;
            K(j,i) = temp;
        end
    end
    toc

    tic;
    fprintf('Inverting K of size: %4dx%4d. ', size(K,1), size(K,2));
    Kinv = pinv(K + sigma_n^2*eye(size(K)) );
    toc;
    
    alpha = Kinv*diffData; 
end

