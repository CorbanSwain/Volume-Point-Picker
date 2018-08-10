function assert(self, varargin)
try
   assert(varargin{:})
catch ME_1
   try
      ME_1.throwAsCaller
   catch ME_2
      self.logException(self.ERROR, ME_2)
      ME_2.rethrow
   end
end
