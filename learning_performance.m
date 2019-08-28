function [session_perf num_trials avg_perf] = learning_performance

% Learning Trajectories for 2P stim training
% JG 12/17
%% Load Multiple Sessions in Directory
% path = ('/Users/crossxface/Dropbox/CodeJon/switching_task/Mouse 10683/mouse10683_sess3_D2017_10_30T16_3_0.h5');

directory = uigetdir('/Users/crossxface/Dropbox/2017_11_2PTechnicalPaper/Figure_4/Learning_Curves', 'choose directory');
foldernames = dir(fullfile(directory,'Session*'));
for i = 1:length(foldernames)
    filenames = dir(fullfile(directory,foldernames(i).name,'*.h5'));
    session = [];
    for j = 1:length(filenames)
    path = fullfile(directory,foldernames(i).name,filenames(j).name);
    [hit FA miss CR performance] = go_nogo_performance(path);
    session(j,1) = hit;
    session(j,2) = FA;
    session(j,3) = miss;
    session(j,4) = CR;
    session(j,5) = performance;
    end
    session_perf(i,:) = sum(session,1)
    num_trials(i) = sum(session_perf(i,1:4))
    avg_perf(i) = session_perf(i,end)/size(session,1)
end
end