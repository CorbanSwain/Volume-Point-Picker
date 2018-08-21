function V = volread(fPath)
% ensure filename ends in '.tif'
[~,~,fileext] = fileparts(fPath);
if ~strcmp(fileext, '.tif') && ~strcmp(fileext, '.tiff')
   fPath = strcat(fPath, '.tif');
end

imInfo = imfinfo(fPath);
nPages = length(imInfo);
readPage = @(i) imread(fPath, 'Index', i);

% grab first frame for proper class
page1 = readPage(1);
sz = arrayfun(@(i) size(page1, i), 1:3);
V = zeros([sz(1:2), nPages, sz(3)], class(page1));
V(:, :, 1, :) = page1;

% grab the remaining pages, if there are any
if nPages > 1
   for iPage = 2:nPages
      V(:, :, iPage, :) = readPage(iPage);
   end
end
