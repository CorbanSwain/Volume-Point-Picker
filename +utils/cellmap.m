function [varargout] = cellmap(varargin)
evaluate = @() cellfun(varargin{:}, 'UniformOutput', false);
if nargout < 1
   varargout = {};
   evaluate();
else
   [varargout{:}] = evaluate();
end