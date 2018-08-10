function volume2tif(V, filepath)
% converts a 3d array, V, to a tif stack at the specified file path
% V can also be a volume struct of length 3 with each of the color chanels
L = utils.Logger('utils.volume2tif');

% TODO - check for and add support for other file formats
% TODO - add additional input argument to handle casting to uint8 and other
% formats automatically

% ensure filename ends in '.tif'
[~,~,fileext] = fileparts(filepath);
if ~strcmp(fileext, '.tif') && ~strcmp(fileext, '.tiff')
   filepath = strcat(filepath, '.tif');
end

if iscell(V)
   L.assert(isvector(V) && length(V) == 3, ...
      'Incorrectly formated color volumes.');
   L.assert(all((size(V{1}) == size(V{2})) & (size(V{1}) == size(V{3}))),...
      'Color volumes of different sizes.');

   buildColorIm = @(page) cat(3, V{1}(:,:,page), V{2}(:,:,page), ...
      V{3}(:,:,page));
   
   % Initial write to tif file
   imwrite(buildColorIm(1), filepath);
   
   % add all layers to tif stack
   nLayers = size(V{1}, 3);
   for iLayer = 2:nLayers
      imwrite(buildColorIm(iLayer), filepath, 'WriteMode', 'append');
   end
   
else
   % Initial write to tif file
   imwrite(V(:, :, 1), filepath);
   
   % add all layers to tif stack
   nLayers = size(V, 3);
   for iLayer = 2:nLayers
      imwrite(V(:,:,iLayer), filepath, 'WriteMode', 'append');
   end
end
