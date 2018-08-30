function onMouseClick(self)
L = utils.Logger('IVV.onMouseClick');
L.debug('Mouse Clicked');
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
   self.addDropPin(P);
   self.Parent.addPoint(P);
   [P.xLock, P.yLock, P.zLock] = deal(false);
elseif reg ~= ProjViewRegion.Outside
   ind = self.CurrentVoxelIndex;
   switch reg
      case ProjViewRegion.XY
         P.xLock = true;
         P.yLock = true;
         vec = self.VolIm(ind(1), ind(2), :, :);
         pstr = 'z';
      case ProjViewRegion.XZ
         P.xLock = true;
         P.zLock = true;
         vec = self.VolIm(:, ind(2), ind(3), :);
         pstr = 'y';
      case ProjViewRegion.YZ
         P.yLock = true;
         P.zLock = true;
         vec = self.VolIm(ind(1), :, ind(3), :);
         pstr = 'x';
   end
   if ndims(vec) == 4
      vec = utils.rgb2gray3d(vec, self.ColorWeight);
   end
   vec = double(squeeze(vec));
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
self.DropPinCollection.refreshVisibility(self.IVVState);
self.DoAllowInteraction = true;
end