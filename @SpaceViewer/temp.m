        function [out] = get.sphere(app)
            if isempty(app.sphere)
                app.sphere = cell(1, 3);
                [app.sphere{:}] = sphere(5);
                app.sphere = cellfun(@(x) x * app.crosshairGap, app.sphere, ...
                    'UniformOutput', false);
            end
            out = app.sphere;
        end


function openSliceFig(app)
            [~, fName] = fileparts(app.imPath);
            app.SliceFig = figure('Name', ['VPP - 3D Slice Viewer - ', fName], 'Position', ...
                [app.UIFigure.Position(1) + app.UIFigure.Position(3) + 600, ...
                app.UIFigure.Position(1), 600, app.UIFigure.Position(4)], 'MenuBar', 'none' , ...
                'IntegerHandle', 'off', 'Color', app.UIFigure.Color);
            app.SliceAx = gca;
            hold(app.SliceAx, 'on');
            grid(app.SliceAx, 'on');
            app.SliceAx.Visible = 'on';
            [app.SliceAx.XColor, app.SliceAx.YColor, app.SliceAx.ZColor] ...
                = deal([0.85 0.85 0.85]);
            app.SliceAx.Color = [0.6 0.6 0.6];
            app.SliceAx.Box = 'on';
            app.SliceAx.XLabel.String = 'X';
            app.SliceAx.YLabel.String = 'Y';
            app.SliceAx.ZLabel.String = 'Z';
            view(app.SliceAx, [45 30]);
            app.SliceAx.GridColor = [0.85 0.85 0.85];
            app.SliceFig.WindowButtonMotionFcn = @app.onSliceFigMouseMove;
            app.SliceFig.DeleteFcn = @app.onSliceFigClose;
            
            app.SlicePlots = gobjects(1, 3);
            for i = 1:3
                app.SlicePlots(i) = plot3(app.SliceAx, 1, 1, 1, 'r', 'LineWidth', 2);
            end
            [sx, sy, sz] = app.sphere{:};
            app.SliceSurfaces = surf(sx, sy, sz, 'EdgeColor', 'none', 'FaceColor', [0.9 0.9 0.9]);
            app.sliceFigRefresh;
            
            [f, v, c] =  isosurface(double(app.volImage > 0.1), 0.5, app.volImage);
            p = patch(app.SliceAx, 'Faces', f, 'Vertices', v, ...
                'FaceAlpha', 0.6, 'EdgeColor', 'none', 'FaceColor', 'b');
            camlight(app.SliceAx);
            lighting(app.SliceAx, 'gouraud');
            
            rotate3d(app.SliceFig, 'on');
            colormap(app.SliceAx, app.cmap);
            sz = size(app.volImage);
            app.SliceAx.XLim = [0.5, sz(2) + 0.5];
            app.SliceAx.YLim = [0.5, sz(1) + 0.5];
            app.SliceAx.ZLim = [0.5, sz(3) + 0.5];
            [app.SliceAx.XLimMode, app.SliceAx.YLimMode, app.SliceAx.ZLimMode] ...
                = deal('manual');
            drawnow('limitrate');
        end
        
        function sliceFigRefresh(app)
            if isempty(app.SliceFig) || ~isvalid(app.SliceFig), return; end
            %          points = cellfun(@(s) round(app.P.(s)), {'x', 'y', 'z'}, 'UniformOutput', false);
            %           app.SliceSurfaces = slice(app.SliceAx, app.volImage, points{:}, 'nearest');
            %           [app.SliceSurfaces(:).EdgeColor] = deal('none');
            [sx, sy, sz] = app.sphere{:};
            app.SliceSurfaces.XData = sx + app.P.x;
            app.SliceSurfaces.YData = sy + app.P.y;
            app.SliceSurfaces.ZData = sz + app.P.z;
            
            [app.SlicePlots(:).XData] = deal([1 1] * app.P.x);
            [app.SlicePlots(:).YData] = deal([1 1] * app.P.y);
            [app.SlicePlots(:).ZData] = deal([1 1] * app.P.z);
            
            % xy
            app.SlicePlots(1).ZData = [0.5 size(app.volImage, 3) + 0.5];
            % xz
            app.SlicePlots(2).YData = [0.5 size(app.volImage, 1) + 0.5];
            % yz
            app.SlicePlots(3).XData = [0.5 size(app.volImage, 2) + 0.5];
            
            if app.P.xLock < 2
                app.SlicePlots(3).Color = 'g';
            else
                app.SlicePlots(3).Color = 'r';
            end
            
            if app.P.yLock < 2
                app.SlicePlots(2).Color = 'g';
            else
                app.SlicePlots(2).Color = 'r';
            end
            
            if app.P.zLock < 2
                app.SlicePlots(1).Color = 'g';
            else
                app.SlicePlots(1).Color = 'r';
            end
        end
        
        function onSliceFigMouseMove(app, src, event)
            app.listStatus('Rotate the volume by clicking and dragging.', '', 5);
            app.SliceFig.WindowButtonMotionFcn = [];
        end
        
        function onSliceFigClose(app, src, event)
            disp('Closing Figure');
            app.VolumeViewSwitch.Value = false;
            figure(app.UIFigure);
        end