classdef IVV < handle
   %IVV Summary of this class goes here
   %   Detailed explanation goes here
   
   properties
      DoAllowInteraction (1, 1) logical = false
      ProjView ProjectionView
      FileName
      InitialPosition
      IsSettingPoint = false
      CurrentRegion = ProjViewRegion.XY
      VolIm
      IVVState
   end
   
   properties (SetObservable)
      % FIXME - change current region and current point to AbortSet
      % Observable
      CurrentPoint = struct(...
         'x', 0.5, 'y', 0.5, 'z', 0.5, ...
         'xLock', false, 'yLock', false, 'zLock', false, ...
         'xClip', 0, 'yClip', 0, 'zClip', -1)
      Parent VolumePointPicker
      Figure
      Axis
      Image
      Crosshair
      DropPinCollection
   end
   
   properties (Dependent)
      IsFigureOpen
      IsLocked
      CrosshairGap
      Colormap
      ColorWeight
      MousePoint
      MouseRegion
      CurrentPointComputed
      CurrentVoxelIndex
      CurrentVoxelValue
      CurrentRegionComputed
      ImageXYView
      ImageXZView
      ImageYZView
      ImageXYAlpha
      ImageXZAlpha
      ImageYZAlpha
      xPointLims
      yPointLims
      zPointLims
   end
   
   methods
      %% Constructor
      function self = IVV(parent)
         %%% didSet
         didSetVars = {'Parent', 'Figure', 'Axis', 'Image', ...
            'Crosshair', 'CurrentPoint'};         
         function addDidSet(varname)
            funcname = ['didSet', varname];
            self.addlistener(varname, 'PostSet', @(~, ~) self.(funcname));
         end
         cellfun(@(v) addDidSet(v), didSetVars);
         
         %%% willSet
         willSetVars = {'IVVState'};
         
         self.Parent = parent;
         self.DropPinCollection = DropPinCollection(self);
         self.IVVState = {'projection', 'projection', 'projection'};
      end
      
      %% Figure-like Functions
      function close(self)
         if ~isempty(self.Figure) && isvalid(self.Figure)
            close(self.Figure);
         end
      end
      
      %% Main Figure Functions
      function figure(self)
         self.Figure = figure;
         self.showProjView;
         self.showCrosshair;
         self.DoAllowInteraction = true;
      end
      
      function showProjView(self)
         self.Image = imagesc(self.ProjView.Image);
         backgroundIm = imagesc(self.ProjView.Image * 0);
         backgroundIm.AlphaData = self.ProjView.AlphaData;
         self.Axis.Children = flip(self.Axis.Children);
      end
      
      function showCrosshair(self)
         assert(isvalid(self.Image));
         self.Crosshair = arrayfun(@(~) plot(self.Axis, 0, '-'), 1:12);
      end
      
      %% DropPin Function
      function addDropPin(self, point)
         self.DropPinCollection.addDropPin(point); 
      end
      
      %% Interaction Functions
      onMouseClick(self)
      onMouseMove(self, varargin)
      onMouseScroll(self, scrollCOunt)
      
      %% Graphics Functions
      updateImage(self, varargin)
      updateCrosshair(self, varargin)
      updateImageRegion(self, varargin)
      
      %% CurrentPoint Property
      function didSetCurrentPoint(self)
         L = utils.Logger('IVV.didSetCurrentPoint');
         L.debug('Current Region Comp: %10s | Saved: %10s', ...
            self.CurrentRegionComputed, self.CurrentRegion);
         cp = self.CurrentPoint;
         cpc = self.CurrentPointComputed;
         L.debug(['Curent Point Comp: (%5.1f, %5.1f, %5.1f) (%1d, %1d, %1d) ', ...
            '| Saved: (%5.1f, %5.1f, %5.1f) (%1d %1d %1d)'], ...
            cp.x, cp.y, cp.z, cp.xClip, cp.yClip, cp.zClip, ...
            cpc.x, cpc.y, cpc.z, cpc.xClip, cpc.yClip, cpc.zClip);
         if self.CurrentRegion ~= self.CurrentRegionComputed && ~self.IsLocked
            L.debug('%s ... %s\n', ...
               self.CurrentRegion, self.CurrentRegionComputed)
            self.CurrentRegion = self.CurrentRegionComputed;
            self.updateImageRegion;
         end
         self.updateCrosshair;
         self.updateImage;
         self.DropPinCollection.refreshVisibility(self.IVVState);
      end
      
      
      
      %% Parent Property
      function didSetParent(self)
         L = utils.Logger('IVV.didSetParent');
         L.info('Setting up projection view');
         self.ProjView = ProjectionView(self.VolIm, self.ColorWeight); 
      end
      
      %% Figure Property
      function didSetFigure(self)
         f = self.Figure;
         f.DeleteFcn = @(~, ~) self.Parent.onIVVClose;
         f.Name = ['VPP - 3D Slice Viewer - ', self.FileName];
         if ~isempty(self.InitialPosition)
            f.Position = self.InitialPosition;
         end
         f.MenuBar = 'none';
         f.IntegerHandle = 'off';
         f.Color =  self.Parent.UIFigure.Color;
         f.WindowButtonMotionFcn = @(~, ~) self.onMouseMove;
         f.WindowScrollWheelFcn ...
            = @(~, cbd) self.onMouseScroll(cbd.VerticalScrollCount);
      end
      
      %% Axis Property
      function didSetAxis(self)
         ax = self.Axis;
         hold(ax, 'on');
         ax.Visible = 'off';
         ax.Box = 'off';
         ax.DataAspectRatio = [1 1 1];
         ax.DataAspectRatioMode = 'manual';
         ax.XLim = [1 - 0.5, size(self.ProjView.Image, 2) + 0.5];
         ax.YLim = [1 - 0.5,  size(self.ProjView.Image, 1) + 0.5];
         ax.XTick = [];
         ax.YTick = [];
         colormap(ax, self.Colormap);
         ax.YDir = 'reverse';
      end
      
      %% Image Property
      function didSetImage(self)
         self.Axis = self.Image.Parent;
         self.Image.AlphaData = self.ProjView.AlphaData;
         self.Image.ButtonDownFcn = @(~, ~) self.onMouseClick;
      end
      
      %% Crosshair Property
      function didSetCrosshair(self)
         if isa(self.Crosshair, 'matlab.graphics.chart.primitive.Line')
            [self.Crosshair(:).Color] = deal('g');
            [self.Crosshair(:).LineWidth] = deal(1);
            [self.Crosshair(:).ButtonDownFcn] = deal(@(~, ~) self.onMouseClick);
         end
      end
      
      %% IsFigureOpen Property
      function out = get.IsFigureOpen(self)
         out = ~isempty(self.Figure) && isvalid(self.Figure);
      end
      
      
      %% IsLocked Property
      function out = get.IsLocked(self)
         P = self.CurrentPoint;
         out = P.zLock || P.yLock || P.xLock;
      end
      %% VolIm Property
      function out = get.VolIm(self)
         L = utils.Logger('IVV.get.VolIm');
         if isempty(self.VolIm)
            V = self.Parent.volImage;
            L.info('Original volume size: [%s]', num2str(size(V)));
            V = utils.downsample(V, ceil(size(V) / 750));
            L.info('New volume size: [%s]', num2str(size(V)));
%             V = im2double(V);
%             V = utils.fullscaleim(V);
%             V= utils.double2im(V, 'uint8');
            self.VolIm = V;
         end
         out = self.VolIm;
      end
      
      %% Colormap Property
      function out = get.Colormap(self)
         out = self.Parent.cmap;
      end
      
      %% CrosshairGap Property
      function out = get.CrosshairGap(self)
         out = min(size(self.VolIm)) * 0.1;
      end
      
      %% MousePoint
      function out = get.MousePoint(self)
         out = self.ProjView.proj2world(self.Axis.CurrentPoint(1, 1), ...
            self.Axis.CurrentPoint(1, 2));
      end
      
      function out = get.MouseRegion(self)
         out = self.point2region(self.MousePoint);
      end      
      
      %% CurrentPointComputed
      function out = get.CurrentPointComputed(self)
         P = self.CurrentPoint;
         mouseP = self.MousePoint;
         xyz = {'x', 'y', 'z'};
         function updateP(x)
            lockParam = [x 'Lock'];
            clipParam = [x 'Clip'];
            if ~P.(lockParam) && ~mouseP.(clipParam)
               P.(x) = mouseP.(x);
            end
            P.(clipParam) = mouseP.(clipParam);
         end
         utils.cellmap(@updateP, xyz);
         out = P;
      end
      
      %% CurentVoxelIndex Property
      function out = get.CurrentVoxelIndex(self)
         out = cellfun(@(x) self.CurrentPoint.(x), {'y', 'x', 'z'});
         out = round(out);
         
         % for debugging
         % utils.bound(out, 1, size(self.VolIm) + 1, 'CurrentVoxelIndex');
         
         sz = size(self.VolIm);
         out = utils.bound(out, 1, sz(1:3));
      end
      
      %% CurrentVoxelValue Property
      function out = get.CurrentVoxelValue(self)
         ind = num2cell(self.CurrentVoxelIndex);
         out = self.VolIme(ind{:});
      end
      
      %% CurrentRegion Property
      function out = get.CurrentRegionComputed(self)
         out = self.point2region(self.CurrentPoint);
      end
      
      %% ColorWeight Property
      function out = get.ColorWeight(self)
         L = utils.Logger('IVV.get.ColorWeight');
         out = self.Parent.ColorWeight;
         L.info('Getting ColorWeight > [%s]', num2str(out));
      end
      
      %% _PointLims Properties
      function out = get.xPointLims(self)
         out = [0.5, size(self.VolIm, 2)];
      end    
      
      function out = get.yPointLims(self)
         out = [0.5, size(self.VolIm, 1)];
      end        

      function out = get.zPointLims(self)
         out = [0.5, size(self.VolIm, 3)];
      end        


      %% Image__Views Properties
      function out = get.ImageXYView(self)
         out = self.Image.CData(self.ProjView.XYSel{:});
      end
      
      function out = get.ImageXZView(self)
         out = self.Image.CData(self.ProjView.XZSel{:});
      end
      
      function out = get.ImageYZView(self)
         out = self.Image.CData(self.ProjView.YZSel{:});
      end
      
      function out = get.ImageXYAlpha(self)
         out = self.Image.AlphaData(self.ProjView.XYSel{1:2});
      end
      
      function out = get.ImageXZAlpha(self)
         out = self.Image.AlphaData(self.ProjView.XZSel{1:2});
      end
      
      function out = get.ImageYZAlpha(self)
         out = self.Image.AlphaData(self.ProjView.YZSel{1:2});
      end
      
      function set.ImageXYView(self, im)
         self.Image.CData(self.ProjView.XYSel{:}) = im;
      end

      function set.ImageXZView(self, im)
         self.Image.CData(self.ProjView.XZSel{:}) = im;
      end
      
      function set.ImageYZView(self, im)
         self.Image.CData(self.ProjView.YZSel{:}) = im;
      end
      
      function set.ImageXYAlpha(self, im)
         self.Image.AlphaData(self.ProjView.XYSel{1:2}) = im;
      end
      
      function set.ImageXZAlpha(self, im)
         self.Image.AlphaData(self.ProjView.XZSel{1:2}) = im;
      end
      
      function set.ImageYZAlpha(self, im)
         self.Image.AlphaData(self.ProjView.YZSel{1:2}) = im;
      end
      
   end
   
   methods (Static)
      function reg = point2region(P)
         inQuery = boolean([P.xClip, P.yClip, P.zClip]);
         if sum(inQuery) == 1
            if inQuery(3)
               reg = ProjViewRegion.XY;
            elseif inQuery(2)
               reg = ProjViewRegion.XZ;
            else
               reg = ProjViewRegion.YZ;
            end
         else
            reg = ProjViewRegion.Outside;
         end
      end
      
      function other = getother(s)
         L = utils.Logger('IVV.getother');
         switch lower(char(s))
            case 'x'
               other = 'YZ';
            case 'y'
               other = 'XZ';
            case 'z'
               other = 'XY';
            case 'xy'
               other = 'z';
            case 'xz'
               other = 'y';
            case 'yz'
               other = 'x';
            otherwise
               L.warn('Unexpected value: %s', s);
               other = 'xyz';
         end            
      end
      
      function idx = xyzGetIndex(s)
         L = utils.Logger('IVV.xyzGetIndex');
         switch lower(char(s))
            case 'x'
               idx = 1;
            case 'y'
               idx = 2;
            case 'z'
               idx = 3;
            case 'xy'
               idx = 1;
            case 'xz'
               idx = 2;
            case 'yz'
               idx = 3;
            otherwise
               L.error('Unexpected value: %s', s);
         end   
      end
      
   end
end

