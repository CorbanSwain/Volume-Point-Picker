function I = maxProject(V, varargin)
p = inputParser;
p.addOptional('dim', 3, @(x) any(x == (1:3)));
p.parse(varargin{:});
dim = p.Results.dim;

I = squeeze(max(V, [], dim));
