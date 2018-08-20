function f = calcZFactor(PSF)
L = utils.Logger('utils.calcZFactor');
f = PSF.zspacing / diff(PSF.x1objspace(1:2));
if ~utils.isint(f)
   L.warn('Expected zFactor to be an integer.');
end
f = round(f);
