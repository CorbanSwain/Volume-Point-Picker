function chunks = getchunks(chunkSz, totalLength, varargin)
if nargin == 0
   L = utils.Logger('utils.getchunks');
   unittest;
   L.info('All unit tests passed.');
   return
end
p = inputParser;
p.addOptional('Method', 'greedy', ...
   @(x) any(strcmpi({'greedy', 'balanced'}, x)));
p.parse(varargin{:});
method = p.Results.Method;
switch method
   case 'greedy'
      chunks = [repmat(chunkSz, 1, floor(totalLength / chunkSz)), ...
         mod(totalLength, chunkSz)];
      if chunks(end) == 0
         chunks = chunks(1:(end - 1));
      end
   case 'balanced'
      nChunks = ceil(totalLength / chunkSz);
      newSz = round(totalLength / nChunks);
      chunks = ones(1, nChunks) * newSz;
      chunks(end) = totalLength - sum(chunks(1:(end-1)));
end
end

function unittest
L = utils.Logger('utils.getchunks>utest');
chunkSz = 30;
totalLength = 75;
L.assert(all(utils.getchunks(chunkSz, totalLength) == [30, 30, 15]))
L.assert(all(utils.getchunks(chunkSz, totalLength, 'balanced') == 25))
end