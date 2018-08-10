function tform = df2tform(rotation, translation, doReverse)
%DF2TFORM converts rotation and translation vectors to an affine3d object
%
% See also DFTRANSFORM
L = utils.Logger('utils.df2tform');

switch nargin
  case 2
    doReverse = false;
  case 3
  otherwise
    L.error(['Unexpected number of arguments 2 or 3 expected but %d ' ...
           'were passed'], nargin)
end

% generating rotation matrices
R2 = rotx(rotation(2)); % TWO
R1 = roty(rotation(1)); % then ONE
R3 = rotz(rotation(3)); % then THREE
[R, T] = deal(eye(4));
R(1:3, 1:3) = R1 * R2 * R3; % rotating about y (dim1) then x (dim2) 
                            % then z (dim3).
T(4, 1:3) = translation([2, 1, 3]); % generating translation matrix
tform = affine3d(R * T); % rotation before translation
if doReverse 
   tform = tform.invert;
else
end
