function [varargout] = dftransform(A, rotation, translation, varargin)
%DFTRANSFORM transforms a volumetric image with 6 degrees of freedom.
%   B = DFTRANSFORM(A, rotation, translation) rotates A about the d1,
%   d2, and d3 axes (in that order) as specified by the rotation vector.
%   Then translates the rotated volume along the d1, d2, and d3 axes as
%   specified by the translation vector. The transformed result is
%   returned as B.
%
%   B = DFTRANSFORM(A, rotation, translation, 'reverse') performs a
%   trasformation which would undo the indicated rotation and translation.
%
%   B = DFTRANSFORM(..., PARAM1, VAL1, PARAM2, VAL2, ...) specifies
%   parameters that control the transformation.
%
%   Parameters include:
%
%   'SpatialRef'        An imref3d object defining the extents of the image
%                       in world coordinates. The volume is assumed to be
%                       centered on the origin with pixel extents of 1 in
%                       world coordinates if this is not defined.
%
%   'OutputView'        Controls the extents of the output image.
%                       'full' will not crop the image while 'same' will
%                       limit the output image to the same dimensions as
%                       the inputs or, if SpatialRef is passed, to the same
%                       extents as SpatialRef. This parameter cannot be set
%                       if the 'OutputView' parameter is set in WarpArgs.
%
%   'WarpArgs'          Cell array of arguments to be passed to imwarp
%                       after the arguments A, RA, and tform.
%
%   [B, RB] = DFTRANSFORM(...) also returns a spatial reference object for
%   the transformed volume.
%
%   Inputs
%   ------
%      A                Volumetric image to be transformed.
%
%      rotation         Vector of length 3 speficying rotation, in degrees,
%                       about the x, y and z axes.
%
%      translation      Vector of length 3 specitying the translation, in
%                       pixels, along the x, y and z axes.
%
%   Output
%   ------
%      B               Transfomed volumetric image.
%
%   See also IMWARP, IMREF3D, AFFINE3D
%
%   Copyright Corban Swain, 2018

L = utils.Logger('utils.dftransform');
persistent tformCache;
try
    if strcmpi(A, 'clear')
        L.debug('Clearing tformCache.');
        tformCache = [];
        return
    end
catch % when A is not a string, just continue
end

L.assert(length(rotation) == 3, 'Rotation vector must have length 3.');
L.assert(length(translation) == 3, ...
   'Translation vector must have length 3.');

[doSameView, doReverse, RApassed, RBpassed, warpArgs, doSave] = ...
    parseInputs(varargin);

tform = utils.df2tform(rotation, translation, doReverse);

if isempty(RApassed)
    % set volume to be centered on origin using a spatial reference
    RA = utils.centerImRef(size(A));
else
    RA = RApassed;
end

if doSameView
    RB = RA;
elseif ~isempty(RBpassed) % FYI: these cant both be true, see inputParser
    RB = RBpassed;
end

if ~isempty(RB)
    warpArgs = [warpArgs, {'OutputView'}, {RB}];
end

% no transformation just, potentially, a view change
isTrivial = all(tform.T(:) == reshape(eye(4), [], 1));
if isTrivial
   L.debug('Performing trivial transform')
    if isempty(RB) || doSameView
        B = A;
        RB = RA;
    else
        B = utils.changeView(A, RA, RB);
    end 
else
    cacheLength = length(tformCache);
    doLoad = [];
    for i = 1:cacheLength
        isSame = [all(tformCache(i).tform.T(:) == tform.T(:)), ...
            utils.refeq(tformCache(i).RApassed, RApassed), ...
            utils.refeq(tformCache(i).RBpassed, RBpassed)];
        if all(isSame)
            doLoad = i;
            break
        end
    end
    if isempty(doLoad)
        if doSave
            [B, RB, Aidx, Bfilt] = utils.affinewarp(A, RA, tform, ...
                warpArgs{:});
            if isempty(tformCache), tformCache = struct; end
            i = cacheLength + 1;
            tformCache(i).tform = tform;
            tformCache(i).RApassed = RApassed;
            tformCache(i).RBpassed = RBpassed;
            tformCache(i).RB = RB;
            tformCache(i).isTrivial = isTrivial;
            tformCache(i).Bfilt = Bfilt;
            tformCache(i).Aidx = Aidx;
            tformCache(i).class = class(B);
        else
            [B, RB] = utils.affinewarp(A, RA, tform, warpArgs{:});
        end
    else
        B = zeros(tformCache(doLoad).RB.ImageSize, tformCache(doLoad).class);
        B(tformCache(doLoad).Bfilt) = A(tformCache(doLoad).Aidx);
        RB = tformCache(doLoad).RB;
    end
end

switch nargout
    case 1
        varargout = {B};
    otherwise
        varargout = {B, RB};
end
end


function [doSameView, doReverse, RA, RB, warpArgs, doSave] = ...
    parseInputs(args)
%PARSEINPUTS parses inputs for DFTRANSFORM.
L = utils.Logger('utils.dftransform>parseInputs');
p = inputParser;
p.addOptional('reverse', [], @(x) strcmpi(x, 'reverse'));
p.addParameter('SpatialRef', [], @(x) isa(x, 'imref3d'));
p.addParameter('OutputView', [], ...
    @(x) any(strcmpi(x, {'full', 'same'})) || isa(x, 'imref3d'));
p.addParameter('WarpArgs', {}, @(x) iscell(x));
p.addParameter('Save', false, @(x) islogical(x) && isscalar(x));
p.parse(args{:});

if any(strcmpi('OutputView', p.Results.WarpArgs)) ...
        && ~isempty(p.Results.OutputView)
    L.error(['OutputView cannot be set in WarpArgs if the OutputView ', ...
        'parameter is set for dftransform.']);
end

doReverse = ~isempty(p.Results.reverse);
RA = p.Results.SpatialRef;

if isa(p.Results.OutputView, 'imref3d')
    RB = p.Results.OutputView;
    doSameView = false;
else
    % TODO - implement 'full'
    RB = [];
    doSameView = strcmpi(p.Results.OutputView, 'same');
end

warpArgs = p.Results.WarpArgs;
doSave = p.Results.Save;
end

