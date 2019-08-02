function [mask_array,Spotidx] = loadMasks(path)
%[mask_array,Spotidx] = loadMasks(path)
%   loadMasks() imports .bmp binary masks by file name and outputs a 
%   logical tensor and linear index cell array. 
%
%   loadMasks(path) specifies optional path to folder containing the masks
%   
%   JG 2018

if nargin == 1
    fpathPat = path;
else
    fpathPat=uigetdir('','Please choose the mask directory');
end

mask_list = dir(fullfile(fpathPat,'*.bmp'));
mask_array = NaN(512,512,length(mask_list));
Spotidx = cell(length(mask_list),1);
for idx = 1:length(mask_list)
    temp = imread(fullfile(fpathPat,mask_list(idx).name));
    temp = logical(temp./max(max(temp)));
    mask_array(:,:,idx) = temp;
    Spotidx{idx} = find(temp); % *Note* retained Spotidx for legacy use
end
mask_array = logical(mask_array);