function [dF,F0] = compute_dff(F,prctl)
%[dF,F0] = compute_dff(F)
%   compute_dff(F) takes an array of fluorescence values in the form 
%   cells x time and computes their F-F0/F0 value for all timepoints. 
%   
%   compute_dff(F,prctl) uses the percentile value for F0 specified by the
%   user. Default F0 is the lower 5th percentile value for each cell. 
%   
%   JG 2018

if nargin < 2
    % We define F0 as the lowest 5% of the fluorescence signal over time.
    prctl = 5;
else
    % User defined percentile value for F0.
    prctl = prctl;
end

dF = zeros(size(F,1),size(F,2));
%% Subtract Minimum F signal
%F=F-minimum; % set the lowest value at zero
for k = 1:size(F,1)
    F(k,:)=F(k,:)-min(F(k,:)); % set the lowest value at zero
end
%% Calculating dF/F signal
F0=prctile(F,prctl,2);
for i = 1:length(F0)
    dF(i,:)=(F(i,:)-F0(i))./F0(i);
end