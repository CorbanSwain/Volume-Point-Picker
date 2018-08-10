function V = imrot(V, angle, ax, varargin)
L = utils.Logger('utils.imrot');

if nnz(ax) == 1 && mod(angle, 90) == 0
   V = utils.rot90dim(V, ax, angle / 90, 'coordSystem', 'image');
else
   if isscalar(ax)
      L.assert(any(abs(ax) == [1 2 3]), 'ax must correspond to dim 1 2 3');
      sgn = sign(ax);
      dim = abs(ax);
      ax = zeros(1, 3);
      ax(dim) = sgn; 
   end
   V = imrotate3(V, angle, ax, varargin{:});
end

