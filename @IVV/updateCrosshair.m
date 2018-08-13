function updateCrosshair(self, varargin)
% % L = utils.Logger('IVV.updateCrosshair');
% persistent t;
% try
%    if nargin == 2 && strcmpi(varargin{1}, 'clear')
%       t = [];
%       return;
%    end
% catch
% end
% 
% if isempty(t)
%    t = timer;
%    t.BusyMode = 'drop';
%    t.StartDelay = 0;
%    t.TimerFcn = @(tmr, ~) helper(self, tmr);
%    
%    t.Name = 'updateCrosshairTimer';
% end
% % L.info(t.Name);
% if strcmpi(t.Running, 'off')
%    start(t);
% end
helper(self);
end

function helper(self)
%L = utils.Logger('IVV.updateCrosshair>helper');
xh = self.Crosshair;
xhGap = self.CrosshairGap;
P = self.CurrentPoint;

cellfun(@applyColor, {'x', 'y', 'z'}, {1:4, 5:8, 9:12})

   function applyColor(x, lineInds)
      if P.([x 'Lock'])
         color = 'r';
      else
         color = 'g';
      end
      [xh(lineInds).Color] = deal(color);
   end

%% Tracks X
%%% XY : y-axis
vertGapLine(xh(1:2), P.x, self.ProjView.XYBounds(1:2, 1), P.y);

%%% XZ : y-axis
vertGapLine(xh(3:4), P.x, self.ProjView.XZBounds(1:2, 1), P.z);

%% Tracks Y
%%% XY : x-axis
horzGapLine(xh(5:6), self.ProjView.XYBounds(1:2, 2), P.y, P.x);

%%% YZ : x-axix
horzGapLine(xh(7:8), self.ProjView.YZBounds(1:2, 2), P.y, P.z);

%% Tracks Z
%%% XZ : x-axis
horzGapLine(xh(9:10), self.ProjView.XZBounds(1:2, 2), ...
   self.ProjView.XZBounds(1, 1) + P.z - 0.5, P.x);

%%% YZ : y-axis 
vertGapLine(xh(11:12), self.ProjView.YZBounds(1, 2) + P.z - 0.5, ...
   self.ProjView.YZBounds(1:2, 1), P.y);

drawnow('limitrate');

   function [l1, l2] = gapLine(lim, point)
      l1 = [lim(1), max(lim(1), lim(1) + point - 0.5 - (xhGap / 2))];
      l2 = [min(lim(2), l1(2) + xhGap), lim(2)];
   end

   function vertGapLine(phs, x, yLim, yVal)
      [l1, l2] = gapLine(yLim, yVal);
      vertLine(phs(1), x, l1);
      vertLine(phs(2), x, l2);
   end

   function horzGapLine(phs, xLim, y, xVal)
      [l1, l2] = gapLine(xLim, xVal);
      horzLine(phs(1), l1, y);
      horzLine(phs(2), l2, y);
   end


end

function vertLine(ph, x, yLim)
ph.XData = [1, 1] * x;
ph.YData = yLim;
end

function horzLine(ph, xLim, y)
ph.XData = xLim;
ph.YData = [1, 1] * y;
end

