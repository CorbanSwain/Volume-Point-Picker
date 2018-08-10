function A = tile(obj, positions, varargin)
% Copies the object to the given positions within some n-dimensional space.
L = utils.Logger('utils.tile');

%% INPUT HANDLING
nDims = size(positions, 1);

p = inputParser;
p.addOptional('A', [], @(x) isempty(x) || (ndims(x) == nDims));
p.addParameter('gain', 1, @(x) isscalar(x) || isvector(x));
p.addParameter('intersect', 'default', ...
   @(x) ismember(x, {'add', 'logicalOr', 'max'}) && ischar(x));
p.addParameter('zeroCenter', 'obj', ...
   @(x) ismember(x, {'obj', 'space', 'both', 'neither'}) && ischar(x));

p.parse(varargin{:});
A = p.Results.A;
gain = p.Results.gain;
intersectMethod = p.Results.intersect;
zeroCenter = p.Results.zeroCenter;

if ~isempty(A)
   L.assert(nDims == ndims(A), 'nDims must have the same dimensions as V.');
end
L.assert(ndims(positions) <= 2, ...
   'Positions must be a 2D matrix or 1D vector.');
L.assert(ndims(obj) <= nDims, ['Object must have the same number or', ...
   ' fewer dimensions than implied by the position matrix (i.e.', ...
   ' SIZE(positions, 1)).']);
nCopies = size(positions, 2);
if ~isscalar(gain)
   L.assert(length(gain) == nCopies, ['The gain vector must have ', ...
      ' length = size(positions, 2)']);
end


%% OBJ TO VECTOR ARRAY
objSz = size(obj);
eyeSz = nDims + 2;
% FIXME - maybe move this to input handling?
szDelta = nDims - length(objSz);
if szDelta > 0
   objSz = [objSz, ones(1, szDelta)];
end

if islogical(obj) && islogical(A)
   intersectMethod = 'logicalOr';
end

isNonzero = boolean(obj(:));
objValues = obj(isNonzero);

objSub = cell(nDims, 1);
[objSub{:}] = ind2sub(objSz, find(isNonzero));
clear('isNonzero', 'obj');
objSub = cellfun(@(x) x', objSub, 'UniformOutput', false);

objVec = zeros(eyeSz, length(objValues));
objVec(1:nDims, :) = cell2mat(objSub);
if any(strcmp(zeroCenter, {'obj', 'both'}))
   objVec(1:nDims, :) = objVec(1:nDims, :)  - ((objSz' + 1) / 2);
end
objVec(eyeSz - 1, :) = 1;
objVec(eyeSz, :) = objValues;


%% TRANSFORMANTION MATRIX
T = repmat(eye(eyeSz), 1, 1, nCopies);
T(1:nDims, nDims + 1, :) = reshape(positions, nDims, 1, []);
T(eyeSz, eyeSz, :) = gain;
T = mat2cell(T, eyeSz, eyeSz, ones(1, nCopies));
T = squeeze(T);


%% TRANSFORMATIONS
% TODO - add GPU option
result = cellfun(@(t) t * objVec, T, 'UniformOutput', false);
newVec = horzcat(result{:});


%% SHIFT POINTS AND ASSESS VALIDITY
newSub = newVec(1:nDims, :);
newValues = newVec(eyeSz, :);
if ~isempty(A)
   aSz = size(A);
end
if any(strcmp(zeroCenter, {'space', 'both'}))
   if isempty(A)
      aSz = ceil(2 * max(abs(newSub), [], 2)');
   end
   newSub = newSub + ((aSz' + 1) / 2);
else
   if isempty(A)
      newSub = newSub - min(newSub, [], 2) + 1;
      aSz = ceil(max(newSub, [], 2)');
   end
end
if isempty(A)
   A = zeros(aSz);
end
% TODO - could add antialiasing here, instead of shifting to nearest
newSub = round(newSub);
isValid = all((newSub >= 1) & (newSub <= aSz'), 1); 


%% PLACE INTO SPACE
nPoints = nnz(isValid);
newValues = newValues(isValid);
newSub = mat2cell(newSub(:, isValid), ones(1, nDims), nPoints);
newInd = sub2ind(aSz, newSub{:});

% switch on intersection method
if strcmp(intersectMethod, 'default')
   intersectMethod = 'add';
end

switch intersectMethod
   case 'add'
      intersectFunc = @(a, b) a + b;
   case 'logicalOr'
      intersectFunc = @(a, b) a | b;
   case 'max'
      intersectFunc = @(a, b) max(a, b);
   otherwise
      L.error('Unrecognized intersect method: ''%s''', intersectMethod);
end

while ~isempty(newInd)
   [unqInd, unqSel] = unique(newInd);
   A(unqInd) = intersectFunc(A(unqInd), newValues(unqSel));
   newInd(unqSel) = [];
   newValues(unqSel) = [];
end

end

