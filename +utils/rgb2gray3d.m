function Igray = rgb2gray3d(I, varargin)
%RGB2GRAY converts a color image into grayscale image for 2d and 3d images.

%% Defaults
DEFAULT_COLOR_WT = [0.2989, 0.5870, 0.1140];

%% Input Parsing
p = inputParser;
p.addOptional('ColorWeight', DEFAULT_COLOR_WT, ...
   @(x) isempty(x) || (isvector(x) && length(x) == 3));
p.parse(varargin{:});
colorwt = p.Results.ColorWeight;

%% Perform Conversion
switch ndims(I)
   case 2
      error('An RGB image must be passed.');
   case 3
      Igray = rgb2gray(I);
   case 4
      assert(size(I, 4) == 3, 'Input image must have exactly 3 color channels');
      Igray = I(:, :, :, 1) * colorwt(1) ...
         + I(:, :, :, 2) * colorwt(2) ...
         + I(:, :, :, 3) * colorwt(3);
   otherwise
      error('Input image must be either a 2d or 3d color image.');
end
