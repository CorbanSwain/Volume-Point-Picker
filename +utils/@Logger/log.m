function log(self, level, lineNum, varargin)
name = self.truncatedScriptName;
if ~isempty(lineNum)
   name = sprintf('%s (% 4d)', name, lineNum);
else
   if self.doAutoLineNumber
      name = sprintf('%s (----)', name);
   end
end

if isstruct(varargin{1})
   if length(varargin) > 1
      structName = sprintf(varargin{2:end});
   else
      structName = 'struct';
   end
   message = struct2str(varargin{1}, structName);
else
   message = sprintf(varargin{:});
end

if strlength(message) == 0
   return
   % message = '[empty line]';
end

msgLines = splitlines(message);
nLines = length(msgLines);
if nLines > 1
   for iLine = 1:nLines
      self.log(level, lineNum, char(msgLines{iLine}))
   end
   return
end

% If necessary write to command window
if self.doIndent && self.indentLevel > 0
   makeLogstring = @() sprintf(['%s', self.format], ...
      repmat('|  ', 1, self.indentLevel), name, message);
else
   makeLogstring = @() sprintf(self.format, name, message);
end
logstring = char;
if self.windowLevel <= level
   logstring = makeLogstring();
   fprintf ('%s \n', logstring);
end

%If currently set log level is too high, just skip this log
if self.level > level
   return
end

% Append new log to log file
if isempty(logstring), logstring = makeLogstring(); end
try
   fid = fopen(self.path, 'a');
   fprintf (fid, [self.stampFormat, '%s \n'], ...
      datestr(now, self.datetimeFormat), level, logstring);
   fclose(fid);
catch ME_1
   disp(ME_1);
end
end

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
   str = [{sprintf("%s (%s struct with fields)", sName, ...
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
         x = strrep(string(x), '%', '%%%%');
         if ischar(x)
            str(iField) = sprintf("'%s'", x);
         else
            str(iField) = sprintf('"%s"', x);
         end
      elseif isempty(x)
         str(iField) = "[]";
      elseif isstruct(x)
         str(iField) = utils.struct2str(x, '', preSpaces + 4 + maxLen);
      elseif (isnumeric(x) || islogical(x)) && isvector(x) ...
            && length(x) < 5
         if isscalar(x)
            str(iField) = string(x);
         else
            str(iField) = sprintf("[%s]", join(string(x)));
         end
      elseif iscell(x) && isvector(x) && length(x) < 5 
         nVals = length(x);
         innerStrings = strings(1, length(x));
         for iVal = 1:nVals
            innerStrings(iVal) = sprintf("[%s]", join(string(x{iVal})));
         end
         str(iField) = sprintf('{%s}', join(innerStrings, ', '));
      else
         str(iField) = sprintf("(%s %s array)", ...
            join(string(size(x)), "x"), class(x));
      end
      str(iField) = sprintf("%-*s: %s", maxLen, fnames{iField}, ...
         str(iField));
   end
   
   str = [sName, str];
end
str = cellfun(@(x) strrep(x, '\', '\\\\'), str, 'UniformOutput', false);
str = join(str, ['\n', repmat(' ', 1, preSpaces)]);
str = str{:};
str = sprintf(str);
end