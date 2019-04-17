function [session, conditions] = loadVoyeurH5(path)

Trials = h5read(path,'/Trials');
num_trials = Trials.trialNumber(end);
num_fields = 8; %make a smart way of determing what we want beforehand
session = cell(num_trials,num_fields);
conditions = cell(num_trials,num_fields-1);

for i = 1:num_trials
session{i,1} = Trials.context(i);
session{i,2} = Trials.olfas0x3Aolfa_00x3Aodor(1:32,i)';
session{i,3} = Trials.olfas0x3Aolfa_00x3Amfc_1_flow(i);
session{i,4} = Trials.olfas0x3Aolfa_00x3Avialconc(i);
session{i,5} = Trials.olfas0x3Aolfa_10x3Aodor(1:32,i)';
session{i,6} = Trials.olfas0x3Aolfa_10x3Amfc_1_flow(i);
session{i,7} = Trials.olfas0x3Aolfa_10x3Avialconc(i);
session{i,8} = Trials.result(i);
end

for i = 1:num_trials
conditions{i,1} = Trials.context(i);
conditions{i,2} = Trials.olfas0x3Aolfa_00x3Aodor(1:32,i)';
conditions{i,3} = Trials.olfas0x3Aolfa_00x3Amfc_1_flow(i);
conditions{i,4} = Trials.olfas0x3Aolfa_00x3Avialconc(i);
conditions{i,5} = Trials.olfas0x3Aolfa_10x3Aodor(1:32,i)';
conditions{i,6} = Trials.olfas0x3Aolfa_10x3Amfc_1_flow(i);
conditions{i,7} = Trials.olfas0x3Aolfa_10x3Avialconc(i);
end