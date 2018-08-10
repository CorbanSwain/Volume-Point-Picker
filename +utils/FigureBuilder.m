classdef FigureBuilder
    properties
        Number
        Name
        Position
        SubplotSize = [1, 1]
        PlotBuilders
    end %properties
    properties (GetAccess = 'private', SetAccess = 'private')
        FigureHandle
    end % private properties
    methods
        function [obj, figureHandle] = figure(obj)
            if ~isempty(obj.Number)
                obj.FigureHandle = figure(obj.Number);
            else
                obj.FigureHandle = figure;
            end
            figureHandle = obj.FigureHandle;
            clf(figureHandle);
            if ~isempty(obj.Name)
                figureHandle.Name = obj.Name;
            end
            if  ~isempty(obj.Position)
                figureHandle.Position = obj.Position;
            end
            if prod(obj.SubplotSize) < length(obj.PlotBuilders)
                error(['The subplot dimensions are too small ', ...
                       'for the number of plots.']);
            end
            for iPlot = 1:length(obj.PlotBuilders)
                ax = subplot(obj.SubplotSize(1), ...
                             obj.SubplotSize(2), iPlot);
                hold on;
                plot(obj.PlotBuilders(iPlot), ax);
            end
        end % function figure(obj)
        
        function save(obj, varargin)
            if isempty(obj.FigureHandle)
                figure(obj);
            end
            obj.saveFigure(obj.FigureHandle, varargin{:});
        end % function save(obj)
    end % methods
    
    methods (Static)
        function saveFigure(figureHandle, varargin)
            % saveFigure Saves the passed figure as a 300 dpi png.
            
            p = inputParser;
            p.addOptional('figureDir', 'figures', @isstr)
            p.parse(varargin{:})
            figureDir = p.Results.figureDir;
            
            if ~isdir(figureDir)
                mkdir(figureDir)
            end
            f = gobjects(1,1);
            name = '';
            switch nargin
                case 0
                    f = gcf;
                case 1
                    f = figureHandle;
                case 2
                    f = figureHandle;
            end
            if isempty(name)
                if isempty(f.Name)
                    name = 'untitled';
                else
                    name = f.Name;
                end
            else
                if ~isempty(f.Name)
                    name = [name, '_', f.Name];
                end
            end
            filename = fullfile(figureDir, [name, '.png']);
            print(f,filename,'-dpng','-r300');
        end % saveFigure()
        
        function setDefaults
            % setFigureDefaults Sets default values to make pretty figures.
            if ismac
               fontSize = 18;
            else
               fontSize = 11.5;
            end
            font = 'Helvetica';
            set(groot, ...
                'defaultLineMarkerSize', 8,...
                'defaultLineLineWidth', 2, ...
                'defaultAxesFontSize', fontSize, ...
                'defaultAxesTitleFontWeight', 'normal', ...
                'defaultAxesFontName', font, ...
                'defaultAxesLabelFontSizeMultiplier', 1.1, ...
                'defaultAxesLineWidth', 2, ...
                'defaultFigureColor', [1 1 1], ...
                'defaultTextInterpreter', 'tex', ...
                'defaultTextFontSize',fontSize, ...
                'defaultTextFontName', font ...
                );
        end % setFigureDefaults()
    end % static methods
end