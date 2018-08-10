function cellVal = convert2cell(val)
% convert2cell returns the value if it is a cell otherwise convert.
if iscell(val)
    cellVal = val;
else
    cellVal{1} = val;
end
end