function updateImage(self, varargin)
% % L = utils.Logger('IVV.updateImage');
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
%    t.Name = 'updateImageTimer';
% end
% % L.info(t.Name);
% if strcmpi(t.Running, 'off')
%    start(t);
% end
helper(self);
end

function helper(self)
L = utils.Logger('IVV.updateImage>helper');
L.debug('updatingImage');
ind = self.CurrentVoxelIndex;
xysel = self.ProjView.XYSel;
xzsel = self.ProjView.XZSel;
yzsel = self.ProjView.YZSel;
reg = self.CurrentRegion;

   function showXYPage
      self.Image.CData(xysel{:}) = squeeze(self.VolIm(:, :, ind(3), :));
   end

   function showXZPage
      self.Image.CData(xzsel{:}) ...
         = permute(squeeze(self.VolIm(ind(1), :, :, :)), [2 1 3]);
   end

   function showYZPage
      self.Image.CData(yzsel{:}) = squeeze(self.VolIm(:, ind(2), :, :));
   end

if self.IsLocked
   showXYPage;
   showXZPage;
   showYZPage;
elseif reg ~= ProjViewRegion.Outside
   cFun = @(c) contains(char(reg), c);
   if cFun('X')
      showYZPage;
   end
   if cFun('Y')
      showXZPage;
   end
   if cFun('Z')
      showXYPage;
   end
end
drawnow('limitrate');
end