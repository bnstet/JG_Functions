function plot_traces(dF,stimframes,targets)
%plot_traces(dF,stimframes,targets)
%   plot_traces produces plots of dF/F activity across time.
%
%   JG 2018
cells_perplot = 50;

num_cells = size(dF,1);
num_plots = ceil(num_cells/cells_perplot);
% Plot your traces

j = 1;
for i = 1:num_plots
    fig_idx(i) = figure(i);
    k = 1;
    while j <= num_cells && k <= cells_perplot
        plot(dF(j,:)-(k*500),'k')
        hold on
        j = j+1;
        k = k+1;
    end
    ax = fig_idx(i);
    outerpos = ax.OuterPosition;
    ti = ax.TightInset;
    left = outerpos(1) + ti(1);
    bottom = outerpos(2) + ti(2);
    ax_width = outerpos(3) - ti(1) - ti(3);
    ax_height = outerpos(4) - ti(2) - ti(4);
    ax.Position = [left bottom ax_width ax_height];
    makeNiceFigure(ax)
    %   pbaspect([1 4 1])
    %   makeTightFigure(fig_idx(i))
end

