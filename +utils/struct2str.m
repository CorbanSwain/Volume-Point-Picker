function str = struct2str(s, sName, preSpaces)
switch nargin
   case 1
      sName = 'struct';
      preSpaces = 2;
   case 2
      preSpaces = 2;
end

fnames = fieldnames(s);

if ~isscalar(s)
   str = [{sprintf("%s (a %s struct with fields)", sName, ...
      join(string(size(s)), "x"))}; fnames];
   str = string(str);
else
   nFields = length(fnames);
   maxLen = 0;
   for iField = 1:nFields
      if length(fnames{iField}) > maxLen
         maxLen = length(fnames{iField});
      end
   end
   
   str = strings(1, nFields);
   for iField = 1:nFields
      x = s.(fnames{iField});
      
      if (ischar(x) && isvector(x)) || (isstring(x) && isscalar(x))
         if ischar(x)
            str(iField) = sprintf("'%s'", x);
         else
            str(iField) = sprintf('"%s"', x);
         end
      elseif isempty(x)
         str(iField) = "[]";
      elseif isstruct(x)
         str(iField) = utils.struct2str(x, '', preSpaces + 4 + maxLen);
      elseif (isnumeric(x) || islogical(x)) && isvector(x)
         if isscalar(x)
            str(iField) = string(x);
         else
            str(iField) = sprintf("[%s]", join(string(x)));
         end
      else
         str(iField) = sprintf("(a %s %s array)", ...
            join(string(size(x)), "x"), class(x));
      end
      str(iField) = sprintf("%-*s: %s", maxLen, fnames{iField}, ...
         str(iField));
   end
   
   str = [sName, str];
end
str = join(str, ['\n', repmat(' ', 1, preSpaces)]);
str = sprintf(str);
end