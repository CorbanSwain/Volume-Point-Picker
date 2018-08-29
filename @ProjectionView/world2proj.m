function [xData, yData] = world2proj(self, point)

   function boundXYZ(s)
      lims = self.([s, 'WorldLims']);
      point.(s) = utils.bound(point.(s), lims(1), lims(2), ...
         [s, ' (in ProjectionView.world2proj>boundXYZ)']);
   end
arrayfun(@boundXYZ, 'xyz');

xpv = point.x;
ypv = point.y;
zpv = {self.XZBounds(1, 1) + point.z - 0.5, ...
   self.YZBounds(1, 2) + point.z - 0.5};
xData = [xpv, xpv, zpv{2}];
yData = [ypv, zpv{1}, ypv];
end