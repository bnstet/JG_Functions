function [CI, thresh_error, BS_mean, params] = bootstrap_analysis(path,bs_reps,parallel)
%bootstrap_analysis Bootstrap parameter estimates for detection thresholds.
%   [CI, thresh_error, BS_mean, params] = bootstrap_analysis(path,bs_reps,parallel)
%   Resample behavior data with replacement and fit psychometric functions.
%   The function outputs confidence intervals (CI) for fit parameters, the
%   error of threshold estimates, the mean threshold derived from the
%   bootstrap and the individual threshold and slope estimates for each
%   run (params). 
%
%   The BS_REPS parameter determines the number of bootstrapped samples.
%
%   The PARALLEL parameter passed either TRUE or 1 will parallelize the
%   curvefitting using the parallel computing toolbox
%
%   JG 2018


if nargin<1 || isempty(path); 
    [d_file,d_path] = uigetfile('','Select behavior datafile');
    path = [d_path d_file];
end
if nargin<2 || isempty(bs_reps); 
    bs_reps = 100000; % Set a reasonably large value of bs samples
    parallel = false; % Don't start cluster unless requested.
end
if nargin<3 || isempty(parallel); parallel = false; end

data = load(path);
num_spots = data.num_spots;
num_trials = data.num_trials;
detection = data.detection;

% Initialize variables for bootstrap
% bs_reps = 10000;
bs_percent_correct = ones(bs_reps,length(num_trials));

% Compute PC for each bootstrap estimate
for j = 1:bs_reps
for i = 1:length(num_trials)
    random_trials = rand(num_trials(i),1);
    performance = random_trials<detection(i);
    bs_percent_correct(j,i) = mean(performance);
end
end

% Clamp the lower bound if you haven't measured it
bs_percent_correct(:,1) = 0.5; % clamp the bottom of the range

% model_range = num_spots(1):1:num_spots(end);

% Initialize parameters
params = zeros(bs_reps,2);

if parallel
    poolobj = gcp; % Initialize pool, run reps in parallel
    parfor i=1:size(bs_percent_correct,1)
        bs_percent_correct_singletrial = bs_percent_correct(i,:);
        [~,params(i,:)] = fitbehavior_multiplemodels(num_spots,...
            bs_percent_correct_singletrial,num_trials);
    end
else
    for i=1:size(bs_percent_correct,1)
        bs_percent_correct_singletrial = bs_percent_correct(i,:);
        [~,params(i,:)] = fitbehavior_multiplemodels(num_spots,...
            bs_percent_correct_singletrial,num_trials);
    end
end

% Bootstrap distribution 
figure
histogram(params(:,1),'BinWidth',1)
axis([0 30 0 5000])

% Estimate of the skew of the parameters. for error checking. 
figure
scatter(params(:,1),params(:,2))
set(gca,'yscale','log')

% Get confidence intervals of distribution  
CI = prctile(params(:,1),[2.5 97.5]);
thresh_error = (CI(2)-CI(1))/2;
BS_mean = mean(params(:,1));

