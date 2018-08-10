function lims = expandRange(lims, fraction)

delta = diff(lims);
lims = lims + ([-delta, delta] * fraction);
