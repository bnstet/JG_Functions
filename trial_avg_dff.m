function [Fvec,dFvec,dFavg,dFstd,Tavg] = trial_avg_dff(F,frameidx,...
                                         PreStimFrames,PostStimFrames,...
                                         Omitpre,Omitpost)
%[Fvec,dFvec,dFavg,dFstd,Tavg] = trial_avg_dff(F,frameidx,PreStimFrames,
%                                          PostStimFrames,Omitpre,Omitpost)
%   trial_avg_dff(F,frameidx,...) gives activity centered on frameidx
%   values in a cellsxtimextrials tensor. 
%
%   trial_avg_dff(F,frameidx,PreStimFrames,PostStimFrames,Omitpre,Omitpost)
%   gives allows selection of temporal window around frameidx with omission
%   criteria. optional.
%
%   JG 2018

if nargin <3
    PreStimFrames = 30;
    PostStimFrames = 60;
    Omitpre = 2;
    Omitpost = 1;
end

Fvec = [];
dFvec = [];

% Time for the average df/f plot
Tavg=-PreStimFrames+1:PostStimFrames; %we add one to the pre because...
                                        % 0 timepoint counts as pre.
Tavg = Tavg/30;

for cell_idx = 1:size(F,1)
    for trial_idx = 1:size(frameidx,2)
            Ft0(trial_idx,cell_idx)=nanmean(F(cell_idx,frameidx(trial_idx)...
                -(PreStimFrames+Omitpre+1):frameidx(trial_idx)-(Omitpre+1)));% Calculate local f0 for each stimulus
            Fvec(cell_idx,:,trial_idx)=[F(cell_idx,frameidx(trial_idx)...
                -(PreStimFrames+Omitpre):frameidx(trial_idx)-(Omitpre+1))...
                F(cell_idx,frameidx(trial_idx)+(Omitpost+1):...
                frameidx(trial_idx)+(PostStimFrames+Omitpost))]; % The signal 1 sec before and up to 2 sec after the shutter onset
            dFvec(cell_idx,:,trial_idx)=(Fvec(cell_idx,:,trial_idx)...
                -Ft0(trial_idx,cell_idx))./Ft0(trial_idx,cell_idx); % Calculate (F-Ft0)/Ft0
    end
end

dFavg = [];
dFstd = [];
dFavg = nanmean(dFvec,3);
dFstd = std(dFvec,0,3);