function [xf, yf] = du2fu(axs,x,y)
% DU2FUN Transforms data units to normalided figure units.
    pos = axs.Position
    xLimits = axs.XLim
    yLimits = axs.YLim
    
    xf = (x - xLimits(1)) ./ (xLimits(2) - xLimits(1))
    xf = (xf .* pos(3)) + pos(1)
        
    yf = (y - yLimits(1)) ./ (yLimits(2) - yLimits(1))
    yf = (yf .* pos(4)) + pos(2)
    
end