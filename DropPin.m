classdef DropPin < handle % FIXME - subclass Point?
   properties
      x
      y
      z
      ScatterDataCache
      World2ProjFun
      % ProjView
   end
   
   properties (SetObservable)
      ScatterPlot
      Color        
   end
   
   properties (Dependent)
      XScatterData
      YScatterData
      XYScatterPlot
      XZScatterPlot
      YZScatterPlot      
   end
      
   methods
      function self = DropPin(point, projView, axis)
         didSetVars = {'Color', 'ScatterPlot'};         
         function addDidSet(varname)
            funcname = ['didSet', varname];
            self.addlistener(varname, 'PostSet', @(~, ~) self.(funcname));
         end
         cellfun(@(v) addDidSet(v), didSetVars);
         
         function assignToSelf(s)
            self.(s) = point.(s);
         end
         arrayfun(@assignToSelf, 'xyz');
         % TODO - figure out why this doesnt work
         self.World2ProjFun = @projView.world2proj;
         % self.ProjView = projView;
         
         self.ScatterPlot = arrayfun(@(xd, yd) scatter(axis, xd, yd, ...
            'Visible', 'off'), self.XScatterData, self.YScatterData);
      end
      
      %% Pin Visibility Methods
      function showXYPin(self)
         self.setScatterProp(1, 'Visible', 'on');
      end
      
      function showXZPin(self)
         self.setScatterProp(2, 'Visible', 'on');
      end

      function showYZPin(self)
         self.setScatterProp(3, 'Visible', 'on');
      end

      function hideXYPin(self)
         self.setScatterProp(1, 'Visible', 'off');
      end
      
      function hideXZPin(self)
         self.setScatterProp(2, 'Visible', 'off');
      end

      function hideYZPin(self)
         self.setScatterProp(3, 'Visible', 'off');
      end

      function setScatterProp(self, index, name, value, doMap)
         if nargin == 4
            doMap = false;
         end
         if isempty(self), return; end
         if (ischar(index) || isstring(index)) && strcmpi(':', index)
            index = 1:length(self.ScatterPlot);
         end
         s = arrayfun(@(dp) squeeze(dp.ScatterPlot(index)), self, ...
            'UniformOutput', false);
         s = cat(1, s{:});
         if ~doMap || ischar(value)
            value = {value};
         else
            value = num2cell(value);
         end
         [s(:).(name)] = deal(value{:});
      end
      
      
      %% Color Property
      function didSetColor(self)
         self.setScatterProp(':', 'CData', self.Color);
      end
      
      %% ScatterPlot Property
      function didSetScatterPlot(self)
         propValPairs = {{'MarkerEdgeColor', 'flat'}, ...
            {'MarkerFaceColor', 'flat'}, ...
            {'Marker', 'o'}, ...
            {'LineWidth', 0.2}};
         cellfun(@(arg) self.setScatterProp(':', arg{:}), propValPairs);
      end
      
      %% ScatterDataCache Property
      function out = get.ScatterDataCache(self)
         if isempty(self.ScatterDataCache)
            self.ScatterDataCache = cell(2, 1);
            % [self.ScatterDataCache{:}] = self.ProjView.world2proj(self);
            [self.ScatterDataCache{:}] = self.World2ProjFun(self);
         end
         out = self.ScatterDataCache;
      end
      
      %% _ScatterData Properties
      function out = get.XScatterData(self)
         out = self.ScatterDataCache{1};
      end
      
      function out = get.YScatterData(self)
         out = self.ScatterDataCache{2};
      end
      
      %% __ScatterPlot Properties
      function out = get.XYScatterPlot(self)
         out = arrayfun(@(dp) dp.ScatterPlot(1), self);
      end

      function out = get.XZScatterPlot(self)
         out = self.ScatterPlot(2);
      end

      function out = get.YZScatterPlot(self)
         out = self.ScatterPlot(3);
      end


   end
end