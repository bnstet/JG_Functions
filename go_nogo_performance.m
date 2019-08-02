function [hit FA miss CR performance] = go_nogo_performance(path)
% Hit = 2
% FA = 3
% Miss = 6
% CR = 5 

[session] = loadVoyeurH5_result(path);
result = [session{:,1}]';

hit = sum(result==2);
FA = sum(result==3);
miss = sum(result==6);
CR = sum(result==5);

performance = (hit+CR)/length(result);
end