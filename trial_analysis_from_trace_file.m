trace_file = '/gpfs/data/shohamlab/shared_data/jon_2p_data/JG1150/190712/aligned/JG1150_190712_field1_beh_00003_00001_aligned_extract.mat';
load(trace_file);

preCalcPeriod = 10;
postCalcPeriod = 10;
Omitpost = 3;
Omitpre = 1;

trial_average_vectorized;