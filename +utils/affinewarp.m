function [varargout] = affinewarp(A, RA, tform, varargin)
%% Input Handling
L = utils.Logger('utils.affinewarp');
if nargin == 0
   levelOld = L.windowLevel;
   L.globalWindowLevel(L.ALL);
   L.info('Performing unit tests.');
   unittest;
   L.globalWindowLevel(levelOld);
   return
end
RB = parseInputs(varargin);
L.assert(all(size(A) == RA.ImageSize));
L.assert(any(nargout == [1 2 4]));
%% Setup
L.trace('Setting up transform matrices');
if isfloat(A)
   VARCLASS = class(A);
else
   VARCLASS = 'double';
end
L.trace('VARCLASS = %s', VARCLASS);

I = eye(4);
shiftsel = {4, 1:3};
scalesel = {[1 6 11]};

% 1 - shift to zero
T1 = I;
T1(shiftsel{:}) = -1 * ones(1, 3);

% 2 - scale to world
T2 = I;
T2(scalesel{:}) = [RA.PixelExtentInWorldX, ...
   RA.PixelExtentInWorldY, ...
   RA.PixelExtentInWorldZ];

% 3 - shift to world lim
T3 = I;
T3(shiftsel{:}) = [RA.XWorldLimits(1), ...
   RA.YWorldLimits(1), ...
   RA.ZWorldLimits(1)];

% 4 - transform
T4 = tform.T;

if isempty(RB)
   testP = corners(RA.ImageSize);
   testP = [testP, ones(8, 1)];
   testP = testP * (T1 * T2 * T3 * T4);
   testP(:, 4) = [];
   testLims = [min(testP); max(testP)];
   testSz = ceil(diff(testLims) + 1);
   RB = imref3d(testSz([2 1 3]), ...
      [0 testSz(1)] + testLims(1, 1), ...
      [0 testSz(2)] + testLims(1, 2), ...
      [0 testSz(3)] + testLims(1, 3));
end

% 5 - shift to zero
T5 = I;
T5(shiftsel{:}) = -1 .* [RB.XWorldLimits(1), ...
   RB.YWorldLimits(1), ...
   RB.ZWorldLimits(1)];

% 6 - scale to units
T6 = I;
T6(scalesel{:}) = 1 ./ [RB.PixelExtentInWorldX, ...
   RB.PixelExtentInWorldY, ...
   RB.PixelExtentInWorldZ];

% 7 - shift to one
T7 = I;
T7(shiftsel{:}) = ones(1, 3);

% 8 - convert from subscript to an index into A
T8 = [RA.ImageSize(1); 1; prod(RA.ImageSize(1:2))];
T8Shift = 1 - sum(T8);
T8 = [T8; T8Shift];

L.trace('Input image size [%s]', num2str(RA.ImageSize))
L.trace('Output image size [%s]', num2str(RB.ImageSize))

%% Performing Warp Computation
numelB = prod(RB.ImageSize);
minChunkSz = 1e8;
if numelB > minChunkSz
   L.trace('numelB (%.5e) over threshold (%.5e)', numelB, minChunkSz);
   [~, sv] = memory;
   avalailableMem = sv.PhysicalMemory.Available;
   L.trace('Avalible Memory: %f GB', avalailableMem / 1E9);
   heuristic = 15 * 32;
   chunkSz = avalailableMem / heuristic;
   threshChunkSz = chunkSz * 4;
   L.trace('Threshold chunk size = %.5e', threshChunkSz);
   doIter = numelB > threshChunkSz;
else
   L.trace('numelB (%.5e) NOT over threshold (%.5e)', numelB, ...
      minChunkSz);
   doIter = false;
end

T = affine3d(T1 * T2 * T3 * T4 * T5 * T6 * T7);
helperArgs = {RA, RB, T, T8, VARCLASS};
if doIter
   L.debug(['Volume is too large to warp in one-pass,', ...
      ' performing chunked computation']);
   pgSz = prod(RB.ImageSize(1:2));
   % round to multiple of the volumes pagesize to speed up gridvec
   chunkSz = round(chunkSz / pgSz) * pgSz;
   %chunkSz = 100 * pgSz;
   L.debug('ChunkSize = %d pages', chunkSz / pgSz);
   chunks = utils.getchunks(chunkSz, numelB, 'greedy');
   nChunks = length(chunks);
   filt = false(1, numelB);
   P = zeros(1, numelB);
   Psel = [0, 0];
   startIdx = 0;
   for iChunk = 1:nChunks
      L.trace('Beginnging chunk %2d / %2d', iChunk, nChunks);
      tic;
      chunkSel = (1:chunks(iChunk)) + startIdx;
      [subP, subfilt] = awHelper(helperArgs{:}, chunkSel);
      L.trace('Placing chunk of filter');
      filt(chunkSel) = subfilt;
      L.trace('Placing chunk of A point selection');
      Psel = [Psel(2) + 1, Psel(2) + length(subP)];
      P(Psel(1):Psel(2)) = subP;
      startIdx = chunkSel(end);
      L.trace('\t... took %7.3f seconds', toc);
   end
   L.trace('Removing extra points in P.');
   P = P(1:Psel(2));
else
   L.trace('Performing computation in one pass');
   chunkSel = 1:prod(RB.ImageSize);
   [P, filt] = awHelper(helperArgs{:}, chunkSel);
end

tic;
L.trace('Allocating output volume');
B = zeros(RB.ImageSize, VARCLASS);
L.trace('Placing points into output output space.');
B(filt) = A(P);
L.trace('Placing points took %.3f seconds', toc);

%% Place in Space
L.trace('Returning output');
switch nargout
   case 1
      varargout = {B};
   case 2
      varargout = {B, RB};
   case 4
      varargout = {B, RB, P, filt};
end
end

function [P, filt] = awHelper(RA, RB, T, T8, VARCLASS, chunkSel)
L = utils.Logger('utils.affinewarp>awHelper');

L.trace('Creating point vectors');
% TODO - time this with padarray
P = [gridvec(RB.ImageSize, 'ChunkSel', chunkSel, 'Class', VARCLASS), ...
   ones(length(chunkSel), 1, VARCLASS)];

%% Inverse Transform
L.trace('Performing inverse transformation');
P = round(P * T.invert.T);

%% Filter out Invalid Points
L.trace('Building filter');
filt = all(P >= 1, 2) & all(P <= [RA.ImageSize([2 1 3]), 1], 2);
L.trace('Filtering out invalid points');
P = P(filt, :);

L.trace('Converting to double then mat-multiplying to get indices');
P = double(P) * T8; % must convert to double because of indices > 1e9
end

function RB = parseInputs(args)
p = inputParser;
p.addParameter('OutputView', [], @(x) isa(x, 'imref3d'));
p.parse(args{:});
RB = p.Results.OutputView;
end

function P = corners(sz, varargin)
% locations of the corners of a volume with size sz
p = inputParser;
p.addOptional('onlyAxes', [], @(x) strcmpi(x, 'axes'));
p.parse(varargin{:});
doOnlyAxes = ~isempty(p.Results.onlyAxes);
if doOnlyAxes
   P = [1 1 1; sz(2) 1 1; 1 sz(1) 1; 1 1 sz(3)];
else
   P = combvec([1 sz(2)], [1 sz(1)], [1, sz(3)]);
   P = P';
end
end

function V = makevecs(a, b, sz)
V = {linspace(a(1), b(1), sz(2)), ...
   linspace(a(2), b(2), sz(1))', ...
   reshape(linspace(a(3), b(3), sz(3)), 1, 1, [])};
end

function P = vecs2points(v)
sz = [num2cell(cellfun(@(x) length(x), v([2 1 3]))), {1}];
P = [reshape(repmat(v{1}, sz{[1 4 3]}), [], 1), ... % sz{4} represents 1
   reshape(repmat(v{2}, sz{[4 2 3]}), [], 1), ...
   reshape(repmat(v{3}, sz{[1 2 4]}), [], 1)];
end

function P = gridvec(sz, varargin)
L = utils.Logger('utils.affinewarp>gridvec');
L.assert(isvector(sz), 'sz must be a vector.');
p = inputParser;
p.addParameter('ChunkSel', [], @(x) isvector(x) & all(x > 0));
p.addParameter('Class', 'double', @(x) ischar(x) & isvector(x));
p.parse(varargin{:});
chunkSel = p.Results.ChunkSel;
VARCLASS = p.Results.Class;

if isempty(chunkSel)
   L.trace('Calulating grid vectors for all points');
   %%% hardcoding for speed
   a = ones(1, 3, VARCLASS);
   b = cast(sz([2 1 3]), VARCLASS);
   P = vecs2points(makevecs(a, b, sz));
   
   %%% more elegant method
   % ne = prod(sz);
   % nd = length(sz);
   % P = cell(1, nd);
   % for i = 1:nd
   %     P{i} = colon(cast(1, VARCLASS), cast(sz(i), VARCLASS));
   % end
   % [P{[2 1 3]}] = ndgrid(P{:});
   % P = reshape(cat(nd + 1, P{:}), [], nd);
else
   L.trace('Calculating grid vectors for a chunk of points.');
   Plim = cell(3, 1);
   [Plim{:}] = ind2sub(sz, chunkSel([1, end]));
   Plim = cell2mat(Plim);
   Plim = cast(Plim, VARCLASS);
   Plim = mat2cell(Plim, 3, [1 1]);
   [a, b] = Plim{:};
   a(1:2) = 1;
   b(1:2) = sz(1:2);
   coordOrder = [2 1 3];
   P = vecs2points(makevecs(a(coordOrder), b(coordOrder), ...
      [sz(1:2), b(3) - a(3) + 1]));
   if ~all(Plim{1}(1:2)' == 1 & Plim{2}(1:2)' == sz(1:2))
      startPage = double(a(3));
      P = P(chunkSel - ((startPage - 1) * prod(sz(1:2))), :);
   end
end
end

function unittest
L = utils.Logger('utils.affinewarp>utest');

%% Gridvec Test
a = tic;
sz = [10 11 12];
sel = (105:315) + 400;
P1 = gridvec(sz, 'Class', 'single');
P2 = gridvec(sz, 'ChunkSel', sel, 'Class', 'single');
L.assert(all(all(P1(sel, :) == P2)));
L.info('Gridvec test passed in %f seconds.', toc(a));

%% Case 1
a = tic;
sz = [10 11 12];
A = rand(sz);
RA = utils.centerImRef(sz);
tform = affine3d;
B = utils.affinewarp(A, RA, tform);
L.assert(all(A(:) == B(:)));
L.info('Identity transform test passed in %f seconds.', toc(a));

%% Case 2
a = tic;
sz = round([1200 975 975] * 1);
A = rand(sz, 'single');
RA = utils.centerImRef(sz);
tform = utils.df2tform([88 0 1], [10 0 5]);
[B, RB, P, filt] = utils.affinewarp(A, RA, tform);
L.info('Large volume transform test passed in %f seconds.', toc(a));
end
