function szout = fftsize(sz1, sz2)
%FFTSIZE calculates the array size to use for speeding up fft convolutions.

% calculate the minimum extended image size by adding half of the PSF
% image width and heigth to the image width and heigth, respectively
minSize = sz1 + min(floor(sz1 / 2), floor(sz2 / 2));

% expand the padded dimensions to either a power of two or a multiple
% of 2^p, choosing whichever is smaller. This to speed up the FFT
% calculations used for convolution.
p = 7; 
szout = min(2 .^ ceil(log2(minSize)), 2 ^ p * ceil(minSize ./ 2 ^ p));
