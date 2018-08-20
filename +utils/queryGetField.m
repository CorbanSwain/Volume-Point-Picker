function [val, S] = queryGetField(S, fieldName, default)
%QUERYGETFIELD Gets a field or sets and gets a default value from a struct.
%   [val, S] = QUERYGETFIELD(S, fieldName, default) takes in a struct S
%   and either (A) returns the value stored in the struct under fieldName
%   and the struct unaltered or (B) returns default and the struct
%   altered to have a new field with name fieldName storing the given 
%   default value. 
%
%   Inputs
%   ------
%
%   S                   the struct to get the value from
%
%   fieldName           the name of the field
%
%   default             the value to be returned if the field does not 
%                       exist
%
%   Example
%   -------
%
%   This function is most useful if it is locally redefiend to 
%   automatically update a local struct.
% 
%      function someFunction
%         localStruct = struct;
%         localStruct.magic = magic(5);
%
%         function val = qgf(fieldName, default);
%            [val, localStruct] = queryGetField(localStruct, fieldName, ...
%               default);
%         end
%       
%         qgf('magic', 7); % this wont be stored because localStruct.magic
%                          % is already assigned.
%         localStruct
%         % localStruct = 
%         %
%         %   struct with fields:
%         %
%         %     magic: [5x5 double]
%
%         qgf('x', 1:5);
%         localStruct
%         % localStruct = 
%         %
%         %   struct with fields:
%         %
%         %     magic: [2x2 double]
%         %         x: [1 2 3 4 5]
%
%         a = qgf('x', 6:10);
%         a
%         % a =
%         %
%         %     1    2    3    4    5
%
%         b = qgf('y', 99);
%         b
%         % b =
%         %
%         %     99
%        
%      end

if ~isfield(S, fieldName)
    S.(fieldName) = default;
end
val = S.(fieldName);
end
