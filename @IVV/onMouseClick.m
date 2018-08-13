function onMouseClick(self)
if ~self.DoAllowInteraction, return; end

self.DoAllowInteraction = false;
self.CurrentRegion = self.CurrentRegionComputed;
self.CurrentPoint = self.CurrentPointComputed;

reg = self.CurrentRegion;
P = self.CurrentPoint;
if self.IsLocked
   [P.xLock, P.yLock, P.zLock] = deal(true);
   self.CurrentPoint = P;
   for ii = 1:2
      xh = self.Crosshair;
      pause(0.2)
      [xh(:).Visible] = deal('off');
      pause(0.2)
      [xh(:).Visible] = deal('on');
   end
   self.Parent.addPoint(self.CurrentVoxelIndex);
   [P.xLock, P.yLock, P.zLock] = deal(false);
elseif reg ~= ProjViewRegion.Outside
   ind = self.CurrentVoxelIndex;
   switch reg
      case ProjViewRegion.XY
         P.xLock = true;
         P.yLock = true;
         vec = squeeze(self.VolIm(ind(1), ind(2), :));
         pstr = 'z';
      case ProjViewRegion.XZ
         P.xLock = true;
         P.zLock = true;
         vec = squeeze(self.VolIm(:, ind(2), ind(3)));
         pstr = 'y';
      case ProjViewRegion.YZ
         P.yLock = true;
         P.zLock = true;
         vec = squeeze(self.VolIm(ind(1), :, ind(3)));
         pstr = 'x';
   end
   vec = im2double(vec);
   if ~all(diff(vec) == 0)
      [~, a] = max(vec);
      [~, b] = max(flip(vec));
      b = length(vec) - b + 1;
      % FIXME - this will mess up for seperate peaks of equal value
      P.(pstr) = (a + b) / 2;
   end
end
self.CurrentPoint = P;
self.updateImageRegion;
self.DoAllowInteraction = true;
end