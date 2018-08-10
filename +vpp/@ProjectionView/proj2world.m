function worldP = proj2world(self, x, y)
worldP = struct;
[worldP.x, worldP.xClip] = bound(x, self.XYBounds(1:2, 2));
[worldP.y, worldP.yClip] = bound(y, self.XYBounds(1:2, 1));

dist2xz = x - self.XZBounds(2, 2);
dist2yz = y - self.YZBounds(2, 1);
if dist2xz < dist2yz
   args = {y, self.XZBounds(1:2, 1)};
   zShift = self.XZBounds(1, 1);
else
   args = {x, self.YZBounds(1:2, 2)};
   zShift = self.YZBounds(1, 2);
end
[worldP.z, worldP.zClip] = bound(args{:});
worldP.z = worldP.z - zShift + 0.5;
end

function [X, clip] = bound(X, minmax)
min = minmax(1);
max = minmax(2);
assert(min <= max, 'min must be less than max.');

lessThanMin = X < min;
greaterThanMax = X > max;
X(lessThanMin) = min;
X(greaterThanMax) = max;
clip = (lessThanMin * -1) + (greaterThanMax * 1);
end