trace_dir = 'C:\Users\bnste\Downloads\JG1150\JG1150_trace_files';
trace_file_list = dir(fullfile(trace_dir,'*.mat'));
trace_file = trace_file_list(1);
load(fullfile(trace_file.folder, trace_file.name));

preCalcPeriod = 10;
postCalcPeriod = 10;
Omitpost = 3;
Omitpre = 1;

trial_average_vectorized;