% getlinesandshadebetween
% 
%   takes two lines and shades between them
% 
function [h,p,ks2stat, x1, x2, y1, y2] = getlinesandshadebetween(ax,h, Color)
    if nargin < 1
        ax = gca;
    end
    if nargin<2
        h = get(ax, 'children');
    end
    if nargin < 3
        C = 'c';
    end

    x1 = h(1).XData;
    y1 = h(1).YData;

    x2 = h(2).XData;
    y2 = h(2).YData;

    % do a quick ks test on this:
    [h,p,ks2stat] = kstest2(x1, x2, 'alpha', 0.025);
    % determine if dAUC is + or -

    try
        patch(ax, [x1, fliplr(x2)], [y1, fliplr(y2)], Color)
    catch
        patch(ax, [x1; fliplr(x2')], [y1; fliplr(y2')], Color)
    end
end