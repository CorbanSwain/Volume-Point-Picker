function A = alphaProject(V, varargin)
%ALPHAPROJECT TODO - add documentation ...

%% Unit test
if nargin == 0
   unittest;
   return;
end

%% Defaults
DEFAULT_DIM = 3;


%% Input Parsing
%%% Check Inputs
p = inputParser;
p.addOptional('dim', DEFAULT_DIM, @(x) isscalar(x));
p.addParameter('ColorWeight', []);
p.parse(varargin{:});

%%% Assign Inputs
dim = p.Results.dim;
colorwt = p.Results.ColorWeight;

%% Computation
if ndims(V) == 4 && size(V, 4) == 3
   args = {};
   if ~isempty(colorwt)
      args = [args {'ColorWeight', colorwt}];
   end
   V = utils.rgb2gray3d(V, args{:});
end
S = squeeze(sum(V, dim));
A = S / max(S(:));
end

function unittest
L = utils.Logger('utils.alphaProject>unittest');
L.info('color image test ...');
mri = load('mri');
V = utils.fullscaleim(im2double(squeeze(mri.D))) * 0.5;
V = repmat(V, 1, 1, 1, 3);
V = V + rand(size(V)) * 0.5;
mip = utils.maxProject(V);
ad = utils.alphaProject(V);
figure;
imagesc(mip, 'AlphaData', ad);
end