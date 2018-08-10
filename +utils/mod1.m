function val = mod1(x,y)
%MOD1 Modulus-like bahavior for one-indexed lists.
%
%MOD1(x,y) returns MOD(x - 1, y) + 1. Useful for getting modulus
%behavior similar to that in zero-indexed programing languages.
%
%See also MOD.
val = mod(x - 1, y) + 1;
end

