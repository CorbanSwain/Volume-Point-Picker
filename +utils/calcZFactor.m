function f = calcZFactor(PSF)
L = utils.Logger('utils.calcZFactor');
f = PSF.zspacing / diff(PSF.x1objspace(1:2));
L.assert(utils.isint(f), 'Expected zFactor to be an integer.');
f = round(f);
