function PSF = reducePSF(PSF, outsize, fName)
L = utils.Logger('utils.reducePSF');
psfsize = size(PSF.H);
psfsize = psfsize([1 2 5]);
if nargin == 1
    outsize = [181, 181, 31];
else
    L.assert(isvector(outsize) && length(outsize) == 3);
    L.assert(all(outsize <= psfsize));
    L.assert(all(outsize > 1));
    outsize = round((outsize - 1) / 2) * 2 + 1;
end

if ~all(outsize == psfsize)
   startidx = (psfsize - 1) / 2 - (outsize - 1) / 2 + 1;
   endidx = startidx + outsize - 1;
   sels = {startidx(1):endidx(1), ...
      startidx(2):endidx(2), ...
      startidx(3):endidx(3)};
   PSF.H = PSF.H(sels{1:2}, :, :, sels{3});
   PSF.Ht =  PSF.Ht(sels{1:2}, :, :, sels{3});
   PSF.objspace = PSF.objspace(sels{3});
   PSF.x1space = PSF.x1space(sels{1});
   PSF.x2space = PSF.x2space(sels{2});
   PSF.x3objspace = PSF.x3objspace(sels{3});
   PSF.settingPSF.reducedFrom = num2str(psfsize);
   PSF.settingPSF.reducedTo = num2str(outsize);
   
   newzextent = (str2double(PSF.settingPSF.zmax) ...
      - str2double(PSF.settingPSF.zmin)) ...
      * (outsize(3) - 1) / (psfsize(3) - 1);
   zcenter = (str2double(PSF.settingPSF.zmax) ...
      + str2double(PSF.settingPSF.zmin)) / 2;
   PSF.settingPSF.zmin = num2str(zcenter - newzextent / 2);
   PSF.settingPSF.zmax = num2str(zcenter + newzextent / 2);
end

if nargin == 3
   [path, name, ~] = fileparts(fName);
   utils.touchdir(path);
   if exist(fName, 'file')
      L.warn(['Do you want to overwrite the existing PSF file?', ...
         '\n\t"%s"\n'], fName)
      sAns = ''; count = 0;
      while ~strcmpi(sAns, 'y')
         sAns = input('Y/N: ', 's');
         count = count + 1;
         if strcmpi(sAns, 'n') || count >= 3
            L.info('Aborting save.\n')
            return
         end
      end
   end
   save(fName, '-struct', 'PSF', '-v7.3');
   s = PSF.settingPSF;
   sFields = fieldnames(s);
   fid = fopen(fullfile(path, strcat(name, '.txt')), 'w');
   % TODO - create function that converts PSF to sidecar file
   for i = 1:length(sFields)
      fprintf (fid, '%s: %s\r\n', sFields{i}, s.(sFields{i}));
   end
   fclose(fid);
end
