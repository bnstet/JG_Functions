function [tiffInfo]=tiff_info(name,path,redchannel)
% image_info Get the file list, pathlist and image information for a block 

if nargin<1 || isempty(name) || isempty(path)
[name,path]=uigetfile('*.tif',...
    'Please choose the first Tiff Stack files of this session');
end

if nargin<3 || isempty(redchannel)
    redchannel = 0;
end

% Get all the paths and file names.
fname=[path,name];
filelist = dir([path,name(1:25),'*.tif']); % this step broken by alignment
filelist = filelist( cellfun(@length, {filelist.name}) == length(name))



pathlist = cell(size(filelist,1),1);
num_images = zeros(size(filelist,1),1);

% Go through tiffs and figure out number of figures
for idx = 1:length(pathlist)
    pathlist{idx} = [path,filelist(idx).name];
    info = imfinfo(pathlist{idx}); %slow step. scales with number of images
    num_images(idx) = numel(info);
end


% Calculate total and dims.
totnumimages=sum(num_images)/(redchannel+1);
width=info(1).Width; height=info(1).Height;

% Save in struct for portability
tiffInfo.filelist = filelist;
tiffInfo.pathlist = pathlist;
tiffInfo.num_images = num_images;
tiffInfo.totnumimages = totnumimages;
tiffInfo.width = width;
tiffInfo.height = height;
