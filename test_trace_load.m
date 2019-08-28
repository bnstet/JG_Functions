mov_dir = '/gpfs/data/shohamlab/shared_data/jon_2p_data/JG1150/190712/aligned';
mov_pattern = 'JG1150_190712_field1_beh_00003_*_aligned.tif';
mask_dir = '/gpfs/data/shohamlab/shared_data/jon_2p_data/JG1150/190712/masks';
expt_info_file = '/gpfs/data/shohamlab/shared_data/jon_2p_data/JG1150/190712/1150_5_03_D2019_7_12T18_9_23_beh.h5';
red_channel = 0;

tic
traces_from_files(mov_dir, mov_pattern, mask_dir, expt_info_file,red_channel);
toc