function R = centerImRef(sz)
L = utils.Logger('utils.centerImRef');
limFun = @(x) [-1 1] * x / 2;
lims = arrayfun(limFun, sz, 'UniformOutput', false);
switch length(sz)
  case 2
    R = imref2d(sz, lims{[2, 1]}); % switching order because of y
                                   % then x indexing for images 
  case 3
    R = imref3d(sz, lims{[2, 1, 3]});
  otherwise
    L.error(['Unexpected length for sz; sz must be a vector ', ... 
           'of 2 or 3 elements.']);
end

    
