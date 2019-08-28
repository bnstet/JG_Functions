function traces_from_files(mov_dir, mov_pattern, mask_dir, expt_info_file, red_channel, save_name)


if nargin < 6
    get_save_name = true;
else
    get_save_name = false;
end

num_images = [];

mov_list = dir(fullfile(mov_dir, mov_pattern));

for mov_ind=1:numel(mov_list)
    f = mov_list(mov_ind);
    info = imfinfo(fullfile(f.folder,f.name));
    num_images(mov_ind) = numel(info);
    if mov_ind==1
        width=info.Width;
        height=info.Height;
    end
end
T = sum(num_images);
final_frames = cumsum(num_images);
init_frames = [0 final_frames(1:end-1)] + 1;

[masks, spotidx] = loadMasks(mask_dir);
nMasks = size(masks,3);
F = zeros(nMasks,T);

tic

tmpF = cell(numel(mov_list),1);
parfor mov_ind=1:numel(mov_list)
    disp(sprintf('Processing movie %d / %d', mov_ind, numel(mov_list)));
    mov = tiff_load(mov_list(mov_ind).name,mov_list(mov_ind).folder,red_channel);
    tmpF{mov_ind} = extractMaskTraces(mov ,masks, spotidx);
end
toc

tic
for mov_ind=1:numel(mov_list)
    init_frame = init_frames(mov_ind);
    final_frame = final_frames(mov_ind);
    F(:,init_frame:final_frame) = tmpF{mov_ind};
end
toc
clear tmpF;

F = F'; % F should be T x nMasks



%% expt file info
[fpathH5, fnameH5, exth5]= fileparts(expt_info_file);
fnameH5 = [fnameH5 exth5];
fpathH5 = [fpathH5 '/'];

% Getting the signals from the HDF5 file, "M" keeps the data in
% Trials structure and "m" concatenates all trials to one colom.
[ M, m ] = HDF5reader( fpathH5,fnameH5, 0,'frame_triggers','sniff','lick1','lick2');
[ M.packet_sent_time, M.sniff_samples, m.packet_sent_time,...
    m.sniff_samples] = HDF5Eventsreader( fpathH5,fnameH5);

[ m.sniff ] = Check_sniff_data( m );
m.time=1:size(m.sniff,1);% This is the local time of the experiment according to sniff recordings
m.ftrig_shift=m.frame_triggers(end-T+1:end)-single(m.packet_sent_time(1))-single(m.sniff_samples(1));

% Timing the shutter onset
m.shonset_shift=m.shutter_onset-(m.packet_sent_time(1))-(m.sniff_samples(1));% shifting the shutter onset time to sniff time
m.shutter_timing=zeros(1,size(m.sniff,1));
m.shutter_timing(nonzeros(double(m.shonset_shift).*double(m.shonset_shift>0)))=1;

%find closest frame to trigger onset
onsets=find(m.shutter_timing==1);
diffs=min(abs(m.ftrig_shift-find(m.shutter_timing==1)));
for idx1 = 1:size(nonzeros(m.shonset_shift>0),1)
    frameidx(idx1)=find(abs(m.ftrig_shift-onsets(idx1))==diffs(idx1),1); % This is the closest frame to the shutter onset
end
frameidx=frameidx(1:end-1); % remove the last onset


%% save info


if get_save_name
    [~, base_save_name, ~] = fileparts(mov_list(1).name);
    save_name = [base_save_name  '_extract.mat'];
    save_dir = mov_list(1).folder;
    save_name = fullfile(save_dir, save_name);
end


save(save_name, 'mov_list', 'num_images', 'mask_dir', 'spotidx','init_frames', 'final_frames', 'F', ...
     'frameidx', 'M', 'm');

end
