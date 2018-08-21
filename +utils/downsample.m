function Idown = downsample(I, factor, varargin)


%% Unit Test
if nargin == 0
   unittest;
   return;
end

%% Defaults
%%% Default Dimension
if isscalar(factor)
   if isvector(I)
      [~, DEFAULT_DIM] = find(size(I) ~= 1);
   else
      DEFAULT_DIM = 1;
   end
else
   DEFAULT_DIM = 1:length(factor);
end

%% Input Parsing
%%% Check Inputs
assert(isvector(factor), 'Downsampling factor must be a scalar or vector.'); 
assert(all(factor >= 1), 'Downsampling factor must be >= 1.');
p = inputParser;
p.addOptional('dim', DEFAULT_DIM, @(x) isvector(x) && all(utils.isint(x)) ...
   && all(x > 0));
p.parse(varargin{:});
dim = p.Results.dim;

if length(factor) > 1 && length(dim) > 1
   assert(length(dim) == length(factor), ['If vectors, downsampling ', ...
      'factor and dimension must have the same length.']);
end

if length(dim) > 1
   assert(length(unique(dim)) == length(dim), ['If a vector, each of the ', ... 
      'downsampling dimensions must be unique']);
end

%% Computation
if all(factor == 1)
   Idown = I;
   return;
end

% TODO - add support for non integer downsampleing values

nd = ndims(I);
allfactors = ones(1, nd);

for iDim = 1:nd
   if any(iDim == dim)
      if isscalar(factor)
         allfactors(iDim) = factor;
      else
         allfactors(iDim) = factor(iDim == dim);
      end
   end
end

sz = size(I);
downsampSel = utils.cellmap(@(f, i) 1:f:sz(i), num2cell(allfactors), ...
   num2cell(1:nd));
Idown = I(downsampSel{:});
end

function unittest
L = utils.Logger('utils.downsample>unittest');
logtest = @(name) L.info('Beginning %s test ...', name);
logpass = @() L.info('\tpassed.');

logtest('unity downsample');
L.assert(all(all(utils.downsample(magic(5), 1) == magic(5))));
logpass();

logtest('simple 1D 2 factor downsample');
L.assert(all(utils.downsample(1:10, 2) == (1:2:10))); 
logpass();

logtest('2D');
I = magic(20);
Iin = I;
Iout = I(1:2:20, 1:4:20);
L.assert(all(all(utils.downsample(Iin, [2, 4]) == Iout)));
L.assert(all(all(utils.downsample(Iin, [4, 2], [2 1]) == Iout)));
logpass();

logtest('large 3D');
I = rand(1e3, 1e3, 1e3, 'single');
Iin = I;
Iout = Iin(1:3:end, 1:3:end, 1:3:end);
t = tic;
L.assert(all(all(all(utils.downsample(Iin, 3, 1:3) == Iout))));
L.info('\ttook %.3f seconds', toc(t));
logpass();
end