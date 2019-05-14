function plot_spot(spots,whichSpot)
% plot_spot Plot specific targeted patch for stimulation. 

if nargin<1 || isempty(spots)
    disp('spots not provided')
    return
end

xcoordsAll = spots.xcoordsAll;
ycoordsAll = spots.ycoordsAll;
sizesAll = spots.sizesAll;

    convert=whichSpot;
    rectangle('Position',[xcoordsAll(convert)-sizesAll(convert)/2,...
        ycoordsAll(convert)-sizesAll(convert)/2,sizesAll(convert),...
        sizesAll(convert)],'Curvature',[1,1],'EdgeColor','y');
    text(xcoordsAll(convert)+sizesAll(convert)/2,...
        ycoordsAll(convert)+sizesAll(convert)/2,num2str(convert),...
        'FontSize',8,'Color',[1 1 0]);
end