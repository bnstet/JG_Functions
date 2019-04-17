function dFsig = dF_sigtest(dFvec,stimframe,stim_window,num_stims)
%dFsig = dF_sigtest(dFvec,stimframe,stim_window,num_stims)
%   dF_sigtest(dFvec,stimframe,stim_window) returns the p-value of a two
%   sided KS test between pre and post stimulation sample distributions.
%   dFvec is a 3D tensor cellsxtimextrials. function returns dFsig which is
%   the pvalue for each cell. 
%
%   JG 2018
%   TODO: add options for selecting a particular test (KS, signrank, t,
%   etc). 

if nargin<2
    stimframe = 30;
end

if nargin<3
    stim_window = 3;
end

dFsig = NaN(1,size(dFvec,1));

for i = 1:size(dFvec,1)
%% Vectorize samples post stim
post_stimframe = stimframe+1;
reshap_val = num_stims*(stim_window);
dF_reshape = reshape(dFvec(i,post_stimframe:post_stimframe+...
    (stim_window-1),:),[1,reshap_val]);
F0_reshape = reshape(dFvec(i,stimframe-(stim_window-1):stimframe,:),...
    [1,reshap_val]);

%% Compare to previous timesteps
%     dFsig(i)= signrank(F0_reshape,dF_reshape);
    [~,P] = kstest2(F0_reshape,dF_reshape);
    dFsig(i)= P;
end