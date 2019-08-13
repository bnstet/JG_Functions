clear;
ref_file = 'JG1150_190725_field1_avg_00002_00001.tif';
pattern_file = 'JG1150_190725_field1_18cells_1.mat';
load(pattern_file);
[xc,yc, mimg] = Plot_Pattern(pattern_file,ref_file);