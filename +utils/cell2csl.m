function [varargout] = cell2csl(c)
%CELL2CSL Converts a cell array to a comma separated list of output args.
%
% See also DEAL.
assert(iscell(c));
varargout = c;