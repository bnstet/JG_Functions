% Learning Trajectories for 2P stim training
% JG 12/17
%% Load Multiple Sessions in Directory
% path = ('/Users/crossxface/Dropbox/CodeJon/switching_task/Mouse 10683/mouse10683_sess3_D2017_10_30T16_3_0.h5');

clear all
close all
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

Mouse_3_perf = avg_perf;
Mouse_3_trials = num_trials;


Block5 = [168 170 118 129];
Block6 = [297 238 33 92];
Block7 = [242 111 28 159];

num_trials_2P = [585 660 540];
% (Block7(1)+Block7(4))/sum(Block7)
detection_2P = [.51 .59 .74];  
block_num_2P = [4 5 6];

for i =1:length(detection_2P)
error_vec_2P(i) = 1.96.*sqrt((detection_2P(i).*(1-detection_2P(i)))./num_trials_2P(i));
end

% figure
errorbar(block_num_2P,detection_2P,error_vec_2P,'.r','LineWidth',2)
hold on
scatter(block_num_2P,detection_2P,100,'filled','r')

axis([0 7 0.35 1.1])
xlabel('Number of Targeted Neurons')
ylabel('Percent Correct')
set(gca,'box','off')