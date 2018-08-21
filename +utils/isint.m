function bool = isint(x)
%ISINT Returns true if the value is numerically an integer.
bool = isinteger(x) | mod(x, 1) <= eps(x);
end

