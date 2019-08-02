function [session] = loadVoyeurH5_result(path)

Trials = h5read(path,'/Trials');
num_trials = Trials.trialNumber(end);
num_fields = 1; %make a smart way of determing what we want beforehand
session = cell(num_trials,num_fields);

for i = 1:num_trials
session{i,1} = Trials.result(i);
end
