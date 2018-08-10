function out = refeq(r1, r2)
% computed equality for spatial reference objects
if isempty(r1) || isempty(r2)
    out = isempty(r1) && isempty(r2);
    return
end

out = false;

if ~strcmpi(class(r1), class(r2))
    return
end

% TODO - add imref2d case
if isa(r1, 'imref3d')
    params = {'XWorldLimits', 'YWorldLimits', 'ZWorldLimits', 'ImageSize'};
    for i = 1:length(params)
        if ~all(r1.(params{i}) == r2.(params{i}))
            return
        end
    end
    out = true;
else
    out = all(r1 == r2);
end
end
