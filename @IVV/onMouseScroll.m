function onMouseScroll(self, scrollCount)
reg = self.CurrentRegion;
if scrollCount && reg ~= ProjViewRegion.Outside
   P = self.CurrentPoint;
   scrollDim = self.getother(reg);
   P.(scrollDim) = P.(scrollDim) + scrollCount;
   self.CurrentPoint = P;
end
end