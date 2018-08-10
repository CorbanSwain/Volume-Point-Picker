function str = strrepi(str, old, new)
if nargin == 0
   unittest;
   return
end
cls = class(str);
str = string(str);
assert(isscalar(str));
locs = strfind(lower(str), lower(old));
patternLen = strlength(old);
for loc = locs
   str = strrep(str, str{1}(loc:(loc + patternLen - 1)), new);
end
str = cast(str, cls);
end

function unittest
a = utils.strrepi('Hello, world!', 'hello', 'Goodbye');
b = 'Goodbye, world!';
assert(strcmp(a, b), 'Expected ( %s ), but got (  %s  )', b, a);
end