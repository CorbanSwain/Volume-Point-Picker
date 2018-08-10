function varargout = zeroCenterVector(vecLengths)
nVectors = length(vecLengths);
varargout = cell(nVectors, 1);
for iVectors = 1:nVectors
   n = vecLengths(iVectors);
   varargout{iVectors} = (1:n) - ((n + 1) / 2);
end
