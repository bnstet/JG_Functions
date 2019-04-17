function F = get_traces(Spotidx,tiffInfo,redchannel)

if nargin<1 || isempty(Spotidx)
    [~,Spotidx] = loadMasks;
end

if nargin<2 || isempty(tiffInfo)
    [tiffInfo]=tiff_info;
end

if nargin<3 || isempty(redchannel)
    answer = questdlg('Did you record the red channel? A(0=no/1=yes)');
    switch answer
        case 'Yes'
            redchannel = 1;
        case 'No'
            redchannel = 0;
    end
end

%% open file after file of this session and calculate the relevant parameters

% Initialize the traces variable 
F = zeros(tiffInfo.totnumimages,length(Spotidx));

% Set the initial frame pointer
initialFrame=0;
filenum=1;

tic
for idx = 1:length(tiffInfo.filelist)
    
    % Read file with NormCorre's read_file function
    Stack = read_file(tiffInfo.pathlist{idx},1);
    
    % Throw out the red frames if redchannel=1
    if redchannel
        Stack(:,:,2:2:end)=[];
    end
    
    % Get number for Tiffs in each file
    num_images_temp = size(Stack,3);

    % Calculating the fluorescence signal from each frame for all cells
    for frame=initialFrame+1:initialFrame+num_images_temp
        
        % Grab each frame and pull out the mean values from each spot
        tempStack=Stack(:,:,frame-initialFrame);
        F(frame,:)=cellfun(@(x) mean(tempStack(x)),Spotidx);
        
    end
    
    Stack = [];
    % Display the current file
    filenum=filenum+1
    
    % Set the initial frame pointer to the last frame of the file
    initialFrame=frame;
end
toc