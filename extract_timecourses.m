function extract_timecourses(save_path,mask_path,h5_path,tiff_path)
% extract_timecourses(save_path,mask_path,h5_path,tiff_path)
%   Extract average timeseries from ROIs specified by pixel masks.
%
%   All arguments are optional parameters. User will be prompted if 
%   unspecified.
%
%   JG 2018
if nargin<1
    savefilepath = pwd;
    savefilename = 'Temp.mat';
    save_path = false;
end

if nargin <2
    mask_path = false;
    h5_path = false;
    tiff_path = false;
elseif nargin <3
    h5_path = false;
    tiff_path = false;
elseif nargin <4
    tiff_path = false;
end

%% Optional Analysis parameters
gonogo = false;
pattern = true;
masks = false;
%% Setting the analysis parameters
[StimLength,Omitpre,Omitpost,prefigs,postfigs,redchannel] = SetAnalysisParameters();
%Omitpre=2;
%% loading masks
if masks
    % Load masks by file name and turn into a logical tensor and index cell array.
    if mask_path
        [mask_array,Spotidx] = loadMasks(mask_path);
    else
        [mask_array,Spotidx] = loadMasks;
    end
    spot_num=length(Spotidx);
end
%% loading the pattern file
if pattern
[fnamePat, fpathPat]=uigetfile('','Please choose the pattern file','/experiment/TwoPhoton/2P_Detection');
%[fnamePat, fpathPat]=uigetfile('','Please choose the pattern file','E:\StimTrials\161201\85 KHz');

load([fpathPat fnamePat]);% loading the pattern file
% Seperating the pattern to the different cells and show figs on subplots
[ Xcoordinates , Ycoordinates ] = Cam_spot_builder( pattern, sizesave,...
                                                    xsave ,ysave  );
spot_num=size(Xcoordinates,2);
[c1,d1]=cellfun(@size ,Xcoordinates);[c2,d2]=cellfun(@size ,Ycoordinates);
if sum(c1.*d1.*c2.*d2)/size(c1,2)==1  % if it is 1 pixels spot draws a circle around it for analysis
    [ Xcoordinates ,Ycoordinates ] = CircleDrawer( Xcoordinates, Ycoordinates );
end
Spotidx{spot_num}=[];
SpotMat=cell(spot_num,1); SpotMat(:)={zeros(size(pattern))};
for idx=1:spot_num
    Spotidx{idx}=sub2ind(size(pattern),Xcoordinates{idx},Ycoordinates{idx});
    SpotMat{idx}(Spotidx{idx})=1;
end
end
%% loading the H5 file
if  h5_path
    [fpathH5, filename, ext] = fileparts(h5_path);
    fnameH5= strcat(filename,ext);
else
    [fnameH5, fpathH5]=uigetfile('*.h5',...
        'Please choose the hdf5 file of the experiment',...
        '/experiment/TwoPhoton'); %'E:\StimTrials\ for windows
end

% Getting the signals from the HDF5 file, "M" keeps the data in
% Trials structure and "m" concatenates all trials to one column.

Pharospower=0; % if this is one then it will read the pharos power field in h5 file
[ M, m, H5] = HDF5reader(fpathH5,fnameH5,Pharospower,...
    'frame_triggers','sniff','lick1','lick2');
[ M.packet_sent_time, M.sniff_samples, m.packet_sent_time,...
    m.sniff_samples] = HDF5Eventsreader( fpathH5,fnameH5);
% [aligned_sniff, all_sniff] = SniffReader( fpathH5,fnameH5 );
%% Checking how many images we have in all the relevant files
if tiff_path
    fname = tiff_path;
else
    [name,path]=uigetfile('*.tif',...
        'Please choose the first Tiff Stack files of this session',...
        '/experiment/TwoPhoton/2P_Detection');% 'E:\StimTrials\
    fname=[path,name];
end

[path, filename, ext] = fileparts(fname);
name= strcat(filename,ext);
longname = strfind(name,'aligned');

filenum=1;
while exist(fname,'file')==2
    block_names{filenum} = fname;
    info = imfinfo(fname);
    num_images(filenum) = numel(info);
    
    if isempty(longname) %handle variable name length
        tempnum=num2str(100000+str2num(fname(end-8:end-4))+1);
        fname(end-8:end-4)=tempnum(2:end);
    else
        tempnum=num2str(100000+str2num(fname(end-16:end-12))+1);
        fname(end-16:end-12)=tempnum(2:end);
    end
    filenum=filenum+1;
end
totnumimages=sum(num_images)/(redchannel+1);
totnumfiles=filenum-1;
width=info(1).Width; height=info(1).Height;
%% Checking to see that we are not missing data and shift the timing of sniff and figures

[ m.sniff,m.frame_triggers ] = Check_sniff_data( m );

%Catalogue of errors
% 1. frame triggers before first packet sent time - sniff samples
% -might be because we lose the first packets, so everything is zeroed to a
% slightly later value.
% 2. frame trigger times out of order or missing
% 3.


%test if there are any out of order frame packets (timestamps suddenly
%lower number) and push everything back to accomodate
%
erroridx = find(diff(m.frame_triggers)<33,1);
if ~isempty(erroridx)
    disp('something wrong with trigger packets')
    framediff = abs(m.frame_triggers(erroridx+1)-m.frame_triggers(erroridx));
    if m.frame_triggers(erroridx+2)-m.frame_triggers(erroridx+1)> 33
        framesubtract = framediff + 33;
    else
        framesubtract = framediff + 34;
    end
    m.frame_triggers(1:erroridx) = m.frame_triggers(1:erroridx)-framesubtract;
    %    erroridx = find(diff(m.frame_triggers)<33,1);
end
%

m.time=1:size(m.sniff,1);% This is the local time of the experiment according to sniff recordings
% m.time=1:size(aligned_sniff,1);% This is the local time of the experiment according to sniff recordings

% m.ftrig_shift=m.frame_triggers(end-totnumimages+1:end)-single(m.packet_sent_time(1))-single(m.sniff_samples(1));
m.ftrig_shift=m.frame_triggers(end-totnumimages+1:end)-single(m.packet_sent_time(1))-single(m.sniff_samples(1));

% number of trials
trialnumber = H5.trialNumber;

% Timing the shutter onset
m.shonset_shift=m.shutter_onset-(m.packet_sent_time(1))-(m.sniff_samples(1));% shifting the shutter onset time to sniff time
m.shutter_timing=zeros(1,size(m.sniff,1));
m.shutter_timing(nonzeros(double(m.shonset_shift).*double(m.shonset_shift>0)))=1;

%update number of useful trials
trialnumber = nonzeros(double(trialnumber).* double(m.shonset_shift>0));


%find closest frame to trigger onset
onsets=find(m.shutter_timing==1);
for i = 1:length(onsets)
    diffs(i)=min(abs(m.ftrig_shift-onsets(i)));
end
for idx1 = 1:size(nonzeros(m.shonset_shift>0),1)
    frameidx(idx1)=find(abs(m.ftrig_shift-onsets(idx1))==diffs(idx1),1); % This is the closest frame to the shutter onset
end

% save all frameidx for later
frameidx_alltrials = frameidx;

if gonogo
stimtrials = find(H5.trialtype==0);
nostimtrials = find(H5.trialtype==1);
else
stimtrials = trialnumber;
% nostimtrials = stimtrials;
end

% Clean up the index of stimulation frames to exclude the first and last if
% there isn't enough time before or after

if totnumimages-frameidx(end)< 76; % we want 2 seconds after for plotting
    frameidx=frameidx(1:end-1); % remove the last onset
    trialnumber = trialnumber(1:end-1);
end

if frameidx(1)< 30 % we want 1 second before stim for plotting and math
    frameidx = frameidx(2:end); %get rid of the first stim.
    trialnumber = trialnumber(2:end);
end

% %Temporary adjustment to remove missaligned frames
% frameidx = frameidx(1:end); %get rid of the first stim.
% trialnumber = trialnumber(1:end);
% %%%%%%%

if gonogo
    stimtrials = find(H5.trialtype==0);
    stimtrialvec = intersect(trialnumber,stimtrials);
else
    stimtrials = trialnumber;
    stimtrialvec = trialnumber;
end


for j = 1:length(stimtrialvec)
    stimtrialidx(j) = find(trialnumber-stimtrialvec(j) == 0);
end

if gonogo
    nostimtrials = find(H5.trialtype==1);
    nostimtrialvec = intersect(trialnumber,nostimtrials);
    
    for j = 1:length(nostimtrialvec)
        nostimtrialidx(j) = find(trialnumber-nostimtrialvec(j) == 0);
    end
end

%% open file after file of this session and calculate the relevant parameters

F = zeros(totnumimages,spot_num);
initialFrame=0; % This parameter will hold the frame number between the files
fname=[path,name];
filenum=1;minimum = 0;

% Stack_allframes = zeros(width,height,totnumimages);

% while exist(fname,'file')==2
tic
for j = 1:numel(block_names)
    Stack = read_file(block_names{j},1);
    
    if redchannel
        Stack = Stack(:,:,1:2:end);
        Red_ims = Stack(:,:,2:2:end);
    end
    
    Red_ims = [];
    tempnumframes = size(Stack,3)-1;
    startingframe = initialFrame+1;
    %     Stack_allframes(:,:,startingframe:startingframe+tempnumframes)= Stack;
    num_images_temp = size(Stack,3);
    % Onsets of stimulation in this stack of the whole movie
    
    frameidxtemp=frameidx((frameidx>initialFrame)...
        &(frameidx<initialFrame+num_images_temp))-initialFrame;
    
    % Calculating the fluorescence signal from each frame for all cells
    for frame=initialFrame+1:initialFrame+num_images_temp
        tempStack=Stack(:,:,frame-initialFrame);
        F(frame,:)=cellfun(@(x) mean(tempStack(x)),Spotidx);
    end
    
    initialFrame=frame;
    Stack = [];
end
toc
%% Save the data
if ~exist('save_path') || ~save_path
    [savefilename,savefilepath] = uiputfile('',...
    'Please choose the save directory', '/experiment/TwoPhoton/');
else
    [savefilepath, filename, ext] = fileparts(save_path);
    savefilename= strcat(filename,ext);
end

if ~exist('gonogo') || ~gonogo
    save(fullfile(savefilepath,savefilename),'F','frameidx','frameidx_alltrials','m','stimtrials','stimtrialvec')
else
    save(fullfile(savefilepath,savefilename),'F','frameidx',...
        'frameidx_alltrials','m','stimtrials','stimtrialvec',...
        'nostimtrials','nostimtrialvec')
end

disp('File saved successfully') 

