function [inputs, observations] = loadData(pathName)
    info = load(pathName);
    numFields = numel(fieldnames(info));

    info = struct2cell(info);
    inputs = [];
    observations = [];
    for i = 1:2:numFields
        inputs = vertcat(inputs, info{i}(:,:));
        observations = vertcat(observations, info{i+1}(:,:));
    end
    

    
end