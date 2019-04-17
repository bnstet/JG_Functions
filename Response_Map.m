function [response_map] = Response_Map(dFint,responders_idx,mask_array,...
                                             pattern_path, plotimg, bgmask)


mask_array = double(mask_array);
% response_mat = zeros(size(mask_array,1),size(mask_array,2),...
%                                         size(mask_array,3));
for i = 1:length(responders_idx)
    
    mask_array(:,:,responders_idx(i)) = ...
        (mask_array(:,:,responders_idx(i))*(dFint(responders_idx(i))+1));
end


response_map = sum(mask_array(:,:,1:end),3); % edit, made it 1:end
% response_map = response_map;
%
% pattern_path = '/Users/crossxface/Dropbox/CodeJon/Specificity_test_analysis/patternforSLM/30_cells_1Pattern.mat';
% tiff_path = '/Users/crossxface/Dropbox/CodeJon/Specificity_test_analysis/Template_green.tif';

if nargin>4 && ~isempty(plotimg)
    imagesc(response_map)
    colormap hot
    % caxis([.995 max(unique(response_map))])
    caxis([.991 1.1])
    axis equal
    axis tight
end

if nargin>3 && ~isempty(pattern_path)
    hold on
    Plot_Pattern(pattern_path,[],1);
end

if nargin>5 && ~isempty(bgmask)
    response_map = sum(mask_array(:,:,1:end-1),3);
end