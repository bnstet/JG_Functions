function [F_detrend,F_nostim,weighting] = detrend_traces(F,frameidx_alltrials,num_pre,num_post)
%[F_detrend,F_nostim,weighting] = detrend_traces(F,frameidx_alltrials,num_pre,num_post)
%   detrend_traces(F,frameidx_alltrials) removes the background activity
%   of a movie from each cell, weighted by the background's contribution to
%   that cell's activity. 
%
%   detrend_traces(...,num_pre,num_post) specifies the range to remove
%   frames around the stimulation times. If not specified, 1 frame pre and
%   post is default. 
%
%   Function returns the de-trended traces, non-detrended traces with the
%   stimulus removed, and the relative weighting of the background for each
%   trace. 
%
%   TODO: separately remove the sniff component and the stimulation
%   component. improve handling for movies with no stim. 
%
%   JG 2018

%% Ignore timing if there are no stimulation frames.
if nargin<2
    stimulation = false;
else
    stimulation = true;
end
%% Define pre and post stim frames to remove. 
if nargin<4
    num_pre = 1;
    num_post = 1;
end

%% check for proper orientation of F matrix
F_dims = size(F);
if F_dims(1)>F_dims(2)
    F = F';
end

%% If you have artifact frames, define their timing. 
if stimulation
    allstimframes = [];
    if exist('frameidx_alltrials')
        % all visable stim frames including ones at beginning and end of movie.
        for i = 1:length(frameidx_alltrials)
        allstimframes = [allstimframes frameidx_alltrials(i)-num_pre:...
                                        frameidx_alltrials(i)+num_post];
        end
        allstimframes = unique(allstimframes);
        allstimframes = allstimframes(allstimframes<size(F,2));
%         allstimframes = unique([frameidx_alltrials ...
%             frameidx_alltrials-num_pre frameidx_alltrials+num_post]);
        allstimframes = allstimframes(allstimframes>0);
    else
        % guess stim frames (won't always work)
        stimidx = find(mean(F,1)>400);
        allstimframes = unique([stimidx stimidx(end)-1]);
    end
else
    allstimframes = [];
end

%% put NaNs where the stims are. 
F_nostim = F;
F_nostim(:,allstimframes)=NaN;

%% mean subtract
F_centered = [];
F_mean = nanmean(F_nostim,2);
F_centered = F_nostim-F_mean;
F_noNaNs = [];
F_noNaNs = F_centered;
F_noNaNs(:,allstimframes)=[];

%% normalize
F_centered_norm = [];
for i = 1:size(F_centered,1)
F_mag(i) = norm(F_noNaNs(i,:));
F_centered_norm(i,:) = F_centered(i,:)./F_mag(i);
end

%% take the DP to get contribution
% note, can't take DP with NaNs, so make a weight mat using the de-NaN'd
% version.
F_centered_noNaNs = [];
F_centered_noNaNs = F_centered_norm;
F_centered_noNaNs(:,allstimframes) = [];

weighting = F_centered_noNaNs*F_centered_noNaNs(end,:)';
weighting_signed = weighting;
weighting = weighting.*(weighting>0);

%% take outer product to get background scaled by DP for each cell
weight_mat = weighting*F_centered_norm(end,:);
F_detrend_centered = F_centered_norm-weight_mat;

%% Undo the original scaling to bring F back into the same scale as F
% Maybe this doesn't matter? it avoids dividing by tiny values during df/f
% computation. 

F_detrend = [];
for i = 1:size(F_detrend_centered,1)
    F_detrend(i,:) = (F_detrend_centered(i,:)*F_mag(i))+F_mean(i);
end
