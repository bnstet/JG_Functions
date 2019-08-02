function [Xcoordinates,Ycoordinates,Avgimg] = Plot_Pattern(pattern_path,tiff_path,only_pat)
%[Xcoordinates,Ycoordinates,Avgimg] = Plot_Pattern(pattern_path,tiff_path)
%   Plot an image with a pattern mat file overlayed.
%
%   JG 2018
%% Parameters
loc_sort = false; %sort the numbering by location in the FOV (default LR).

%% loading the pattern file
if nargin<1
    [fnamePat, fpathPat]=uigetfile('','Please choose the pattern file');
    pattern_path = [fpathPat fnamePat];
end

load(pattern_path);% loading the pattern file

% Seperating the pattern to the different cells and show figs on subplots
[ Xcoordinates , Ycoordinates ] = Cam_spot_builder(pattern, sizesave, xsave ,ysave  );

spot_num=size(Xcoordinates,2);
[c1,d1]=cellfun(@size ,Xcoordinates);[c2,d2]=cellfun(@size ,Ycoordinates);
if sum(c1.*d1.*c2.*d2)/size(c1,2)==1  % if it is 1 pixels spot draws a circle around it for analysis
    [ Xcoordinates ,Ycoordinates ] = CircleDrawer( Xcoordinates, Ycoordinates );
end
% Spotidx{spot_num}=[];
% SpotMat=cell(spot_num,1); SpotMat(:)={zeros(size(pattern))};
% for idx=1:spot_num
%     Spotidx{idx}=sub2ind(size(pattern),Xcoordinates{idx},Ycoordinates{idx});
%     SpotMat{idx}(Spotidx{idx})=1;
% end

%% Plot avg tiff
if nargin<3
    if nargin<2
        [name,path]=uigetfile('*.tif','Please choose the first Tiff Stack files of this session');
        tiff_path=[path,name];
        %     Avgimg= imread(fname);
    end
    Avgimg= imread(tiff_path);
    
    % % make 0 the min
    % Avgimg = Avgimg-min(min(Avgimg,[],1));
    Avgimg = double(Avgimg);
    Avgimg = Avgimg./max(max(Avgimg));
    Avgimg = Avgimg-min(min(Avgimg));
    
    figure
    imagesc(Avgimg);hold on; colormap('gray');
    axis equal
    axis tight
end

%% ROIs
if ~loc_sort
    for convert=1:size(Xcoordinates,2)
        %plot(imgmean,xsave(convert),ysave(convert),'or');hold on
        %     subplot(2,12,14:16);
        %     rectangle('Position',[xsave(convert)-sizesave(convert)/2,ysave(convert)-sizesave(convert)/2,sizesave(convert),sizesave(convert)],'Curvature',[1,1],'EdgeColor','y');
        %     text(xsave(convert)+sizesave(convert)/2,ysave(convert)+sizesave(convert)/2,num2str(convert),'FontSize',8,'Color',[1 1 0]);
        %plot(imgtot,xsave(convert),ysave(convert),'or');hold on
        %     subplot(2,12,2:4);
        rectangle('Position',[xsave(convert)-sizesave(convert)/2,ysave(convert)-sizesave(convert)/2,sizesave(convert),sizesave(convert)],'Curvature',[1,1],'EdgeColor','y');
        text(xsave(convert)+sizesave(convert)/2,ysave(convert)+sizesave(convert)/2,num2str(convert),'FontSize',8,'Color',[1 1 0]);
        
    end
end

%% Sort ROIs by position
% Experimental functionality for location based sorting (let's you compare
% across sessions if the numbering chnages but relative position doesn't).

% leftPos = min(xsave); % Sort by extreme left pixel
% [~,idx] = sort(xsave);
if loc_sort
    new_order = sort_order(xsave);
    for convert=1:size(Xcoordinates,2)
        %     newlabel(convert) = find(idx == convert);
        %     reorderTargets=idx(convert);
        %plot(imgmean,xsave(convert),ysave(convert),'or');hold on
        %     subplot(2,12,14:16);
        %     rectangle('Position',[xsave(convert)-sizesave(convert)/2,ysave(convert)-sizesave(convert)/2,sizesave(convert),sizesave(convert)],'Curvature',[1,1],'EdgeColor','y');
        %     text(xsave(convert)+sizesave(convert)/2,ysave(convert)+sizesave(convert)/2,num2str(convert),'FontSize',8,'Color',[1 1 0]);
        %plot(imgtot,xsave(convert),ysave(convert),'or');hold on
        %     subplot(2,12,2:4);
        rectangle('Position',[xsave(convert)-sizesave(convert)/2,ysave(convert)-sizesave(convert)/2,sizesave(convert),sizesave(convert)],'Curvature',[1,1],'EdgeColor','y');
        text(xsave(convert)+sizesave(convert)/2,ysave(convert)+sizesave(convert)/2,num2str(new_order(convert)),'FontSize',8,'Color',[1 1 0]);
        
    end
end
