function [B, RB] = affinewarpForward(A, RA, tform, varargin)
%% Input Handling
RB = parseInputs(varargin);

%% Setup
if isfloat(A)
   VARCLASS = class(A);
else
   VARCLASS = 'double';
end
coordsz = size(A);
coordsz = coordsz([2 1 3]);

I = eye(4, VARCLASS);
shiftsel = {4, 1:3};
scalesel = {[1 6 11]};
rotsel = {1:3, 1:3};

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
    % FIXME - move this to a function
    % points of the four corners
    testP = combvec([1 coordsz(1)], [1 coordsz(2)], [1, coordsz(3)])';
    testP = cast(testP, VARCLASS);
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
T5(shiftsel{:}) = -1 * [RB.XWorldLimits(1), ...
    RB.YWorldLimits(1), ...
    RB.ZWorldLimits(1)];

% 6 - scale to units
T6 = I;
T6(scalesel{:}) = 1 ./ [RB.PixelExtentInWorldX, ...
    RB.PixelExtentInWorldY, ...
    RB.PixelExtentInWorldZ];

% 1 - shift to one
T1 = I;
T1(shiftsel{:}) = ones(1, 3);
 
% 7 - convert from subscipt to index
T7 = [RB.ImageSize(1)           0 
      1                         0
      prod(RB.ImageSize(1:2))   0
      0                         1];

P = [utils.gridvec(coordsz, VARCLASS), ones([numel(A), 1], VARCLASS)];
% 5X Memory

%% Transform
P = round(P * (T1 * T2 * T3 * T4 * T5 * T6));

%% Filter out Invalid Points
P(:, 4) = A(:);
clear('A'); % 4X Memory
P(any(P(:, 1:3) < [0 0 0], 2), :) = [];
P(any(P(:, 1:3) > (RB.ImageSize([2 1 3]) - 1), 2), :) = [];

%% Place in Space
P = P * T7; % 2X Memory
B = zeros(RB.ImageSize, VARCLASS); % 3X memory
B(P(:, 1) + 1) = P(:, 2);
end

function RB = parseInputs(args)
p = inputParser;
p.addParameter('OutputView', [], @(x) isa(x, 'imref3d'));
p.parse(args{:});
RB = p.Results.OutputView;
end
