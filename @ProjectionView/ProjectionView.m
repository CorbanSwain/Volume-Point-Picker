classdef ProjectionView < handle
%PROJECTIONVIEW Summary of this class goes here
%   Detailed explanation goes here
   
   properties (Access = private)
      Cache
   end
   
   properties
      VolIm % FIXME - this shouldne be here ... avoid duplicating it
      XYAlpha
      XZAlpha
      YZAlpha
      AlphaImage
      ColorWeight
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
      xWorldLims
      yWorldLims
      zWorldLims
   end
   
   methods
      %% Constructor
      function self = ProjectionView(volImage, colorwt)
         self.Cache = cell(1, 4);
         self.ColorWeight = colorwt;
         [self.Cache{:}] = utils.projectionView(volImage, 'ColorWeight', ...
            self.ColorWeight);
         self.createAlpha(volImage);
         self.VolIm = volImage;
      end
      
      %% Alpha Data
      function createAlpha(self, volImage)
         pFun = @(dim) utils.alphaProject(volImage, dim, 'ColorWeight', ...
            self.ColorWeight);
         self.XYAlpha = pFun(3);
         self.XZAlpha = permute(pFun(1), [2 1 3]);
         self.YZAlpha = pFun(2);
         
         self.AlphaImage = zeros(size(self.AlphaData));
         function applyIm(s)
            self.AlphaImage(self.([s 'Sel']){1:2}) = self.([s 'Alpha']);
         end
         cellfun(@applyIm, {'XY', 'YZ', 'XZ'});
      end
      
      %% Conversion Methods
      worldP = proj2world(self, x, y)
      [xData, yData] = world2proj(self, point)
      
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
      
      function out = get.xWorldLims(self)
         out = [0.5, size(self.VolIm, 2)];
      end    
      
      function out = get.yWorldLims(self)
         out = [0.5, size(self.VolIm, 1)];
      end        

      function out = get.zWorldLims(self)
         out = [0.5, size(self.VolIm, 3)];
      end 
   end
end

