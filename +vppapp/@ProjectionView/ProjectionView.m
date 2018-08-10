classdef ProjectionView < handle
   %PROJECTIONVIEW Summary of this class goes here
   %   Detailed explanation goes here
   
   properties (Access = private)
      Cache
   end
   
   properties
      XYAlpha
      XZAlpha
      YZAlpha
      AlphaImage
   end
   
   properties (Dependent)
      Image
      AlphaData
      Bounds
      Sels
      XYBounds
      XZBounds
      YZBounds
      XYSel
      XZSel
      YZSel
   end
   
   methods
      %% Constructor
      function self = ProjectionView(volImage)
         self.Cache = cell(1, 4);
         [self.Cache{:}] = utils.projectionView(volImage);
         self.createAlpha(volImage);
      end
      
      %% Alpha Data
      function createAlpha(self, volImage)
         pFun = @(dim) utils.alphaProject(volImage, dim);
         self.XYAlpha = pFun(3);
         self.XZAlpha = pFun(1)';
         self.YZAlpha = pFun(2);
         
         self.AlphaImage = self.AlphaData;
         function applyIm(s)
            self.AlphaImage(self.([s 'Sel']){:}) = self.([s 'Alpha']);
         end
         cellfun(@applyIm, {'XY', 'YZ', 'XZ'});
      end
      
      %% Conversion Method
      worldP = proj2world(self, x, y)
      
      %% Dependent Methods
      function out = get.Image(self)
         out = self.Cache{1};
      end
      
      function out = get.AlphaData(self)
         out = self.Cache{4};
      end
      
      function out = get.Bounds(self)
         out = self.Cache{2};
      end
      
      function out = get.Sels(self)
         out = self.Cache{3};
      end
      
      function out = get.XYBounds(self)
         out = self.Bounds{1};
      end
      
      function out = get.XZBounds(self)
         out = self.Bounds{2};
      end
      
      function out = get.YZBounds(self)
         out = self.Bounds{3};
      end
      
      function out = get.XYSel(self)
         out = self.Sels{1};
      end
      
      function out = get.XZSel(self)
         out = self.Sels{2};
      end
      
      function out = get.YZSel(self)
         out = self.Sels{3};
      end
   end
end

