function szout = fftsize(sz1, sz2, varargin)
%FFTSIZE calculates the array size to use for speeding up fft calculations.

%% Defaults
DEFAULT_EXPT = 7;

%% Input Parsing
ip = inputParser;
ip.addOptional('expt', DEFAULT_EXPT, ...
   @(x) isscalar(x) && utils.isint(x) && x >= 0);
ip.parse(varargin{:});
expt = ip.Results.expt;

%% Main Computation
% Calculate the minimum extended image size by adding half of the smaller
% dimensions to the larger dimensions.
minSize = max(sz1, sz2) + min(floor(sz1 / 2), floor(sz2 / 2));

% Expand the padded dimensions to either a power of two or a multiple
% of (2 ^ expt), choosing whichever is smaller. This to speed up the FFT
% calculations used for convolution. 
pow = 2 ^ expt;
szout = min(2 .^ ceil(log2(minSize)), pow * ceil(minSize / pow));
