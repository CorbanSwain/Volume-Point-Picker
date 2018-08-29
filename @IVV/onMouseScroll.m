function onMouseScroll(self, scrollCount)
reg = self.CurrentRegion;
if scrollCount && reg ~= ProjViewRegion.Outside
   P = self.CurrentPoint;
   scrollDim = self.getother(reg);
   lims = num2cell(self.([scrollDim, 'PointLims']));
   P.(scrollDim) = utils.bound(P.(scrollDim) + scrollCount, lims{:});
   self.CurrentPoint = P;
end
end