function score = scoreim(I, varargin)
L = utils.Logger('utils.scoreim');

% FIXME - this only works with boolean reference images right now.
persistent R;
if nargin == 1
   L.info('utils.scoreim: saving reference image in persistent store.\n')
   R = I;
   return;
end

p = inputParser;
methodList = {'sumOutside', 'fakeSnr', 'psnr', 'correlation', 'all'};
p.addParameter('method', 'all', @(x) any(strcmp(x, methodList)));
p.parse(varargin{:});
method = p.Results.method;

L.assert(all(size(I) == size(R)), ['Image and reference image must have', ...
   ' the same size.']);

try
   clsmax = double(intmax(class(I)));
   L.assert(strcmp(class(I), class(R)), ...
      'If int type, image and reference must be of the same int type.');
catch
   clsmax = 1;
end

doAll = strcmp(method, 'all');
nMeth = length(methodList) - 1;
score = [];

for iMeth = 1:nMeth
   if doAll
      method = methodList{iMeth};
   end
   switch method
      case 'sumOutside'
         outsideSelect = ~boolean(R);
         score = [score, (mean(I(outsideSelect)) / clsmax * 100)];
         
      case 'fakeSnr'
         insideSelect = boolean(R);
         signal = mean(I(insideSelect));
         noise = mean(I(~insideSelect));
         score = [score, (20 * log10(signal / noise))];
         
      case 'psnr'
         if ~isfloat(I), I = double(I); end
         if ~isfloat(R), R = double(R); end
         rmse = @(x, y) sqrt(mean((x(:) - y(:)) .^ 2));
         score = [score, (20 * log10(clsmax / rmse(I, R)))];
         
      case 'correlation'
         if ~isfloat(I), I = double(I); end
         if ~isfloat(R), R = double(R); end
         corrmat = corrcoef(I(:), R(:));
         score = corrmat(1, 2);
         
      otherwise
         L.error('Unrecognized method: ''%s''', method);
   end
   if ~doAll
      if ~isreal(score)
         L.warn('Score for "%s" has imaginary component.', method);
         score = real(score);
      end
      return;
   end
end
