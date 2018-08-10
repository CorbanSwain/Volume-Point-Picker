function A = alphaProject(V, dim)
if nargin == 1
   dim = 3;
end
S = squeeze(sum(V, dim));
A = S / max(S(:));