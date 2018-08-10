classdef IVV < handle
   %IVV Summary of this class goes here
   %   Detailed explanation goes here
   
   properties
      DoAllowInteraction (1, 1) logical = false
      ProjView vppapp.ProjectionView
      FileName
      InitialPosition
      IsSettingPoint = false
      CurrentRegion = vppapp.ProjViewRegion.XY
      VolIm
   end
   
   properties (SetObservable)
      % FIXME - change current region and current point to AbortSet
      % Observable
      CurrentPoint = struct(...
         'x', 0.5, 'y', 0.5, 'z', 0.5, ...
         'xLock', false, 'yLock', false, 'zLock', false, ...
         'xClip', 0, 'yClip', 0, 'zClip', -1)
      Parent volumePointPicker
      Figure
      Axis
      Image
      Crosshair
   end
   
   properties (Dependent)
      IsFigureOpen
      IsLocked
      CrosshairGap
      Colormap
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
   end
   
   methods
      %% Constructor
      function self = IVV(parent)
         didSetVars = {'Parent', 'Figure', 'Axis', 'Image', ...
            'Crosshair', 'CurrentPoint'};
         cellfun(@(v) addDidSet(v), didSetVars);
         
         function addDidSet(varname)
            funcname = ['didSet', varname];
            self.addlistener(varname, 'PostSet', @(~, ~) self.(funcname));
         end
         
         % self.onMouseMove('clear');
         %          self.updateImage('clear');
         %          self.updateCrosshair('clear');
         %          self.updateImageRegion('clear');
         
         self.Parent = parent;
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
      
      %% Interaction Functions
      onMouseClick(self)
      onMouseMove(self, varargin)
      
      %% Graphics Functions
      updateImage(self, varargin)
      updateCrosshair(self, varargin)
      updateImageRegion(self, varargin)
      
      %% CurrentPoint Property
      function didSetCurrentPoint(self)
         if ~(self.CurrentRegion == self.CurrentRegionComputed ...
               || self.IsLocked)
            fprintf('%s ... %s\n', self.CurrentRegion, self.CurrentRegionComputed)
            self.CurrentRegion = self.CurrentRegionComputed;
            self.updateImageRegion;
         end
         self.updateCrosshair;
         self.updateImage;
      end
      
      
      
      %% Parent Property
      function didSetParent(self)
         disp('Setint up projection view');
         self.ProjView = vppapp.ProjectionView(self.VolIm);
      end
      
      %% Figure Property
      function didSetFigure(self)
         f = self.Figure;
         f.Name = ['VPP - 3D Slice Viewer - ', self.FileName];
         if ~isempty(self.InitialPosition)
            f.Position = self.InitialPosition;
         end
         f.MenuBar = 'none';
         f.IntegerHandle = 'off';
         f.Color =  self.Parent.UIFigure.Color;
         self.Figure.WindowButtonMotionFcn = @(~, ~) self.onMouseMove;
         self.Figure.DeleteFcn = @(~, ~) self.Parent.onIVVClose;
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
         if isempty(self.VolIm)
            V = im2double(self.Parent.volImage);
            V = utils.fullscaleim(V);
            self.VolIm = utils.double2im(V, 'uint8');
         end
         out = self.VolIm;
      end
      
      %% Colormap Property
      function out = get.Colormap(self)
         out = self.Parent.cmap;
      end
      
      %% CrosshairGap Property
      function out = get.CrosshairGap(self)
         out = self.Parent.crosshairGap;
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
         mouseReg = self.MouseRegion;
         xyz = {'x', 'y', 'z'};
         invReg = {'YZ', 'XZ', 'XY'};
         function updateP(x, ir)
            lockParam = [x 'Lock'];
            clipParam = [x 'Clip'];
            if ~P.(lockParam) && mouseReg ~= vppapp.ProjViewRegion.(ir)
               P.(x) = mouseP.(x);
               P.(clipParam) = mouseP.(clipParam);
            end
         end
         utils.cellmap(@updateP, xyz, invReg);
         out = P;
      end
      
      %% CurentVoxelIndex Property
      function out = get.CurrentVoxelIndex(self)
         out = cellfun(@(x) self.CurrentPoint.(x), {'y', 'x', 'z'});
         out = round(out);
         
         % for debugging
         utils.bound(out, 1, size(self.VolIm) + 1, 'CurrentVoxelIndex');
         
         out = utils.bound(out, 1, size(self.VolIm));
      end
      
      %% CurrentVoxelValue Property
      function out = get.CurrentVoxelValue(self)
         ind = num2cell(self.CurrentVoxelIndex);
         out = self.VolImage(ind{:});
      end
      
      %% CurrentRegion Property
      function out = get.CurrentRegionComputed(self)
         out = self.point2region(self.CurrentPoint);
      end
      
      %% MOVE ME %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      function reg = point2region(self, P)
         inQuery = boolean([P.xClip, P.yClip, P.zClip]);
         if sum(inQuery) == 1
            if inQuery(3)
               reg = vppapp.ProjViewRegion.XY;
            elseif inQuery(2)
               reg = vppapp.ProjViewRegion.XZ;
            else
               reg = vppapp.ProjViewRegion.YZ;
            end
         else
            reg = vppapp.ProjViewRegion.Outside;
         end
      end
      
      %% ImageViews
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
         out = self.Image.AlphaData(self.ProjView.XYSel{:});
      end
      
      function out = get.ImageXZAlpha(self)
         out = self.Image.AlphaData(self.ProjView.XZSel{:});
      end
      
      function out = get.ImageYZAlpha(self)
         out = self.Image.AlphaData(self.ProjView.YZSel{:});
      end
      
      function set.ImageXZView(self, in)
         self.Image.CData(self.ProjView.XZSel{:}) = in;
      end
      
      function set.ImageYZView(self, in)
         self.Image.CData(self.ProjView.YZSel{:}) = in;
      end
      
      function set.ImageXYAlpha(self, in)
         self.Image.AlphaData(self.ProjView.XYSel{:}) = in;
      end
      
      function set.ImageXZAlpha(self, in)
         self.Image.AlphaData(self.ProjView.XZSel{:}) = in;
      end
      
      function set.ImageYZAlpha(self, in)
         self.Image.AlphaData(self.ProjView.YZSel{:}) = in;
      end
      
      function set.ImageXYView(self, in)
         self.Image.CData(self.ProjView.XYSel{:}) = in;
      end
      
   end
end

