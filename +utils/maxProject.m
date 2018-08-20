function I = maxProject(V, varargin)
%% Unit Test
if nargin == 0
   unittest;
   return
end

%% Parse Inputs
%%% Check Inputs
p = inputParser;
p.addOptional('dim', 3, @(x) any(x == (1:3)));
p.addParameter('ColorWeight', []);
p.parse(varargin{:});


%%% Assign Inputs
dim = p.Results.dim;
colorwt = p.Results.ColorWeight;
if ndims(V) == 4 && size(V, 4) == 3
   isColorIm = true;
else 
   isColorIm = false;
end

%% Perform Projection
if ~isColorIm
   I = squeeze(max(V, [], dim));
   return;
end

%%% Handling color images
if isempty(colorwt)
   Vgray = utils.rgb2gray3d(V);
else
   Vgray = utils.rgb2gray3d(V, colorwt);
end

[~, ind] = max(Vgray, [], dim);
vsz = size(V);
indsz = size(squeeze(ind));
indnumel = prod(indsz);
sel = zeros(indnumel, 3);
subsel = cell(1, 3);

makesubsel = makesubselfun(dim);

for i = 1:indnumel
   [a, b] = ind2sub(indsz, i);
   [subsel{:}] = makesubsel(a, b, ind(i));
   sel(i, :) = arrayfun(@(z) sub2ind(vsz, subsel{:}, z), 1:3);
end

I = reshape(V(sel(:)), [indsz, 3]);
end

function fun = makesubselfun(dim)
switch dim
   case 1
      fun = @(a, b, idx) {idx, a, b};
   case 2
      fun = @(a, b, idx) {a, idx, b};
   case 3
      fun = @(a, b, idx) {a, b, idx};
end
fun = @(a, b, idx) utils.cell2csl(fun(a, b, idx));
end

function unittest
L = utils.Logger('utils.maxProject>unittest');
printtest = @(s) L.info('\t%s ...', s);
printpass = @() L.info('\t\tpassed.');
L.info('Unit tests for utils.maxProject:\n');

printtest('Simple Test');
V = zeros(3, 3, 3);
V(1, 1, 3) = 1;
mip = utils.maxProject(V);
assert(all(mip(:) == [1 0 0 0 0 0 0 0 0]'));
printpass();

printtest('Color Test');
V = zeros(3, 3, 3, 3);
V(1, 1, 3, 2) = 1;
mip = utils.maxProject(V);
assert(mip(1, 1, 1) == 0);
assert(mip(1, 1, 2) == 1);
printpass();

printtest('Color Weight Test')
V = zeros(3, 3, 3, 3);
V(1, 1, 3, 1) = 1;
V(1, 1, 2, 2) = 0.9;
colorwt = [0.5 1 1];
mip = utils.maxProject(V, 'ColorWeight', colorwt);
assert(mip(1, 1, 1) == 0);
assert(mip(1, 1, 2) == 0.9);
printpass();
end