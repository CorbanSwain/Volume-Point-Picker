function V = volread(fPath)
% ensure filename ends in '.tif'
[~,~,fileext] = fileparts(fPath);
if ~strcmp(fileext, '.tif') && ~strcmp(fileext, '.tiff')
   fPath = strcat(fPath, '.tif');
end

imInfo = imfinfo(fPath);
nPages = length(imInfo);
imSize = [imInfo(1).Height, imInfo(1).Width];

readPage = @(i) imread(fPath, 'Index', i);

% grab first frame for proper class
page1 = readPage(1);
V = zeros([imSize, nPages, size(page1, 3)], class(page1));
V(:, :, 1, :) = page1;
if nPages > 1
   for iPage = 2:nPages
      V(:, :, iPage, :) = readPage(iPage);
   end
end
