function I = contrastAdjust(I, contrast)

maxVal = max(I(:));
% scale to 1
I = I / maxVal;

% center on 0, scale by the contrast amount, center on 1
I = (contrast * ((2 * I) - 1)) + 1;

% scale back to original range
I = I / 2 * maxVal;
