classdef DropPinCollection < handle
   properties
      Parent
      ScatterPlot
      DropPins
      DropPinIndex
      ColorIndex
      Colors = {[255, 000, 000]
                [000, 255, 000]
                [000, 255, 255]
                [255, 255, 000]
                [238, 130, 238]}       
   end
   
   properties (Dependent)
      NumColors
   end
   
   methods
      function self = DropPinCollection(parent)
         self.Parent = parent;
         self.Colors = utils.cellmap(@(c) c / 255, self.Colors);
      end
      
      function addDropPin(self, point)
         dropPin = DropPin(point, self.Parent.ProjView, self.Parent.Axis);
         colorId = self.computeNextColor(point);
         dropPin.Color = self.Colors{colorId}; 
         self.DropPins = [self.DropPins, dropPin];
         self.DropPinIndex = cat(1, self.DropPinIndex, ...
            [point.x, point.y, point.z]);
         self.ColorIndex = cat(1, self.ColorIndex, colorId); 
      end
      
      function colorId = computeNextColor(self, point)
         if isempty(self.DropPinIndex)
            colorId = 1;
            return;
         end
         
         dists = sum((self.DropPinIndex - [point.x, point.y, point.z]) ...
            .^ 2, 2);
         [~, sortidx] = sort(dists);
         closestPointIds = sortidx(1:min(end, self.NumColors));
         closestPointColors = self.ColorIndex(closestPointIds);
         colorIdScores = arrayfun(@(i) sum(dists(closestPointColors == i)) ...
            / (sum(closestPointColors == i) .^ 2), 1:self.NumColors);
         colorIdScores(isnan(colorIdScores)) = Inf;
         [~, colorId] = max(colorIdScores);
      end
      
      function refreshVisibility(self, viewerState)
         if isempty(self.DropPins), return; end
         regionOrder = {'XY', 'XZ', 'YZ'};
         axisOrder = [3, 2, 1];
         for i = 1:3
            reg = regionOrder{i};
            switch viewerState{i}               
               case 'projection'
                  self.DropPins.(['show' reg 'Pin']);
                  self.DropPins.setScatterProp(i, 'SizeData', 40);
               otherwise
                  axisValue = viewerState{i};
                  dists = abs(self.DropPinIndex(:, axisOrder(i)) - axisValue);
                  selection = dists < 5;
                  r = subplus(((1 - dists(selection) / 5) .^ 2)) * 40;
                  self.DropPins(selection).(['show' reg 'Pin']);
                  self.DropPins(selection).setScatterProp(i, 'SizeData', r, ...
                     true);
                  self.DropPins(~selection).(['hide' reg 'Pin']);
                  
            end
         end
      end
      
      %% NumColors Property
      function out = get.NumColors(self)
         out = length(self.Colors);
      end
      
   end
   
   
   
end