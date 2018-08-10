function V = rot90dim(V, dim, varargin)
% rotates the volume, V, by k * 90 degrees about the specified dimension.
%
% Runs significantly faster than IMROTATE3 for 90 degree rotations of large 
% martices by using ROT90, FLIP, and SHIFTDIM.
L = utils.Logger('utils.rot90dim');

%% PARSING INPUTS
% FIXME - allow for rotations of lower dimensional images
L.assert(ndims(V) == 3, 'V must be 3D.')

if ~isscalar(dim)
   L.assert(isvector(dim) && nnz(logical(dim)) == 1, ...
      ['dim must be a vector or scalar. If vector, dim must have only,' ...
      ' one non zero element.'])
   dimSel = find(dim);
   dim = dimSel * sign(dim(dimSel));
end
L.assert(any(abs(dim) == [1 2 3]), ...
   'dim must correspond to dimension 1, 2, or 3.')

p = inputParser;
p.addOptional('k', 1, @(k) mod(k, 1) == 0);
coordSystems = {'default', 'image'};
p.addParameter('coordSystem', 'default', ...
   @(x) any(strcmp(x, coordSystems)));
p.parse(varargin{:})

k = mod(p.Results.k, 4) * sign(dim);
dim = abs(dim);
useImageCoords = strcmp(p.Results.coordSystem, 'image');

%% CONVERTING COORDINATE SYSTEMS
if useImageCoords
   switch dim
      case 1
         dim = 2;
      case 2
         dim = 1;
   end
end

%% PERFORMING ROTATION
switch k
   case 0  % no net rotation
      return
      
   case 2  % net 180 degree rotation
      V = rot180(V, dim);
      
   otherwise  % net + or - 90 degree rotation
      switch dim
         case 1
            V = rot90(shiftdim(V, 2), -1);       
         case 2
            V = rot180(rot90(shiftdim(V, 1)), 2);
         case 3
            V = rot90(V, k);
      end
      
      if k == 3
         V = rot180(V, dim);
      end  % switch dim
         
end  % switch k
end

function V = rot180(V, dim)
for iDim = 1:3
   if dim ~= iDim
      V = flip(V, iDim);
   end
end
end
