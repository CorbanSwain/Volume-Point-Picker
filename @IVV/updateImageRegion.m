function updateImageRegion(self, varargin)
% % L = utils.Logger('IVV.updateImageRegion');
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
%    t.TimerFcn = @(~, ~) helper(self);
%    
%    t.Name = 'updateImageRegionTimer';
% end
% % L.info(t.Name);
% if strcmpi(t.Running, 'off')
%    start(t);
% end
helper(self);
end

function helper(self)
L = utils.Logger('IVV.updateImageRegion>helper');
L.debug('Updating IVV Region to %s', self.CurrentRegion);
PV = self.ProjView;
reg = self.CurrentRegion;

    function showMIP(s)
        self.(['Image' s 'View']) = PV.Image(PV.([s 'Sel']){:});
    end
 
   function showAlpha(s)
      self.(['Image' s 'Alpha']) = PV.([s 'Alpha']);
   end

if self.IsLocked
   self.ImageXYAlpha = 1;
   self.ImageXZAlpha = 1;
   self.ImageYZAlpha = 1;
elseif reg == ProjViewRegion.Outside
   self.Image.CData = PV.Image;
   self.Image.AlphaData = PV.AlphaImage;
   [self.IVVState{:}] = deal('projection');
else
   s = char(reg);
   self.IVVState{self.xyzGetIndex(s)} = 'projection';
   showMIP(s);
   showAlpha(s);
   
   cFun = @(c) contains(char(reg), c);
   if cFun('X')
      self.ImageYZAlpha = 1;
   end
   if cFun('Y')
      self.ImageXZAlpha = 1;
   end
   if cFun('Z')
      self.ImageXYAlpha = 1;
   end
end
drawnow('limitrate');
end
