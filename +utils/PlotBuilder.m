classdef PlotBuilder
    properties
        X
        Y
        LineSpecCycleLength
        ColorOrderCycleLength
        LineSpec = {'-'} % setter update cell length
        MarkerSize % setter update cell length
        MarkerFaceColor % setter update cell length
        FillMarker = true
        LineWidth % setter update cell length
        Grid = 'off'
        XScale = 'linear'
        YScale = 'linear'
        XLabel
        YLabel
        XLim
        YLim
        LegendLabels
        LegendLineWidth = 1.5
        LegendLocation = 'best'
        LegendColumns = 1
        LegendBox = 'on'
        LegendTitle
        YError
        AxisAssignment
        Box = 'off'
    end
    methods
       
        function obj = set.X(obj, val)
            obj.X = CNSUtils.convert2cell(val);
        end
        function obj = set.Y(obj, val)
            obj.Y = CNSUtils.convert2cell(val);
        end
        function obj = CNSUtils.PlotBuilder(X, Y)
            if nargin == 2
                obj.X = X;
                obj.Y = Y;
            end
        end
        
        function plot(obj, axes)
            if isempty(obj.Y)
                error('Y-Values must be passed to build a plot.');
            end
            nYVals = length(obj.Y);
            if isempty(obj.X)
                for i = 1:nYVals
                    obj.X{i} = 1:length(obj.Y{i});
                end
            end
            if  nYVals ~= length(obj.X)
               if length(obj.X) == 1
                  Xtemp = obj.X{1};
                  obj.X = cell(nYVals, 1);
                  [obj.X{:}] = deal(Xtemp);
               else
                  error('x and y cell arrays have mismatched dimensions.');
               end
            end
            if nargin == 1
                figure; clf;
                axes = subplot(1, 1, 1);                
            end
            box(axes, obj.Box); 
            plotSettingNames = {'MarkerSize','MarkerFaceColor', ...
                                'LineWidth'};
            lineSpecIndex = 1;
            for i = 1:nYVals
                % FIXME - maybe functionalize this more? Be able to take in
                % shorter cell arrays then vars.
                if ~isempty(obj.AxisAssignment)
                    % FIXME - Check obj.AxisAssignment has length equal to
                    % nYVals
                    if obj.AxisAssignment(i) == 1
                        yyaxis left
                    else
                        yyaxis right
                    end
                    % FIXME - handle incorrectly formatted axes assignment
                    % value
                end
               
                if ~isempty(obj.YError) && ~isempty(obj.YError{i})
                    h = errorbar(axes, obj.X{i}, obj.Y{i}, ...
                                 obj.YError{i}, ...
                                 obj.LineSpec{lineSpecIndex});                    
                else
                    h = plot(axes, obj.X{i}, obj.Y{i}, ...
                             obj.LineSpec{lineSpecIndex});
                end
               
                hold(axes,'on');
                h.AlignVertexCenters = 'on';
                
                if ~isempty(obj.ColorOrderCycleLength)
                    if (mod(i, obj.ColorOrderCycleLength) == 0)
                        axes.ColorOrderIndex = 1;
                    end
                end
                
                if ~isempty(obj.LineSpecCycleLength)
                    if (mod(i, obj.LineSpecCycleLength) == 0)
                        lineSpecIndex = lineSpecIndex + 1;
                    end
                else
                   if length(obj.LineSpec) > 1                      
                      lineSpecIndex = lineSpecIndex + 1;
                   end
                end
                
                if isempty(obj.MarkerFaceColor)
                   if obj.FillMarker
                      h.MarkerFaceColor = h.Color;
                   end
                end
                
                for iSetting = 1:length(plotSettingNames)
                    name = plotSettingNames{iSetting};
                    propertyVal = obj.(name);
                    if ~isempty(propertyVal)
                       if iscell(propertyVal)
                          h.(name) = propertyVal{i};
                       else
                          h.(name) = propertyVal;
                       end
                    end
                end
                           
            end
        grid(axes, obj.Grid);
        axes.XScale = obj.XScale;
        axes.YScale = obj.YScale;
        if ~isempty(obj.XLabel)
            xlabel(obj.XLabel);
        end
        if ~isempty(obj.YLabel)
            if iscell(obj.YLabel)
                yyaxis left
                ylabel(obj.YLabel{1});
                yyaxis right
                ylabel(obj.YLabel{2});
            else
                ylabel(obj.YLabel);
            end
        end
        
        if ~isempty(obj.XLim)
                xlim(obj.XLim);
        end
        
        if ~isempty(obj.YLim)
            if iscell(obj.YLim)
                yyaxis left
                ylim(obj.YLim{1});
                yyaxis right
                ylim(obj.YLim{2});
            else
                ylim(obj.YLim);
            end
        end

        if ~isempty(obj.LegendLabels)
            lgd = legend(obj.LegendLabels);
            if ~isempty(obj.LegendTitle)
                title(lgd, obj.LegendTitle);
            end
            lgd.LineWidth = obj.LegendLineWidth;
            lgd.Location = obj.LegendLocation;
            lgd.Box = obj.LegendBox;
            try
               lgd.NumColumns = obj.LegendColumns;
            catch
               if obj.LegendColumns > 1
                  warning(['No NumColumns property of legend,', ...
                     ' using Orientation instead.'])
                  lgd.Orientation = 'horizontal';
               end
            end
        end
    end
end
end