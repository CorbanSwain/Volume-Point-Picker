function onMouseMove(self, varargin)

if self.DoAllowInteraction
   self.CurrentPoint = self.CurrentPointComputed;
end

% persistent t
% try
%    if nargin == 2 && strcmpi(varargin{1}, 'clear')
%       delete(t);
%       t = [];
%       return;
%    end
% catch
% end

% if isempty(t)
%     t = timer;
%     t.ExecutionMode = 'fixedRate';
%     t.Period = 1;
%     t.TimerFcn = @(~, ~) updatePoint;
% end

% FIXME - have a set refresh schedule that begins on mouse move and ends
% after the figure is closed or interaction stops for some set amout of
% time (e.g. 0.5 s).

% % for debugging
%    function out = genstr(lett)
%       clip = P.([lett 'Clip']);
%       uLett = upper(lett);
%       if clip == 0
%          out = '';
%       elseif clip < 0
%          out = [' v ' uLett ' v '];
%       else
%          out = [' ^ ' uLett ' ^ '];
%       end
%       
%       if P.([lett 'Lock'])
%          out = ['###' uLett '###'];
%       end
%    end
% outstr = utils.cellmap(@genstr, xyz); 
% disp([sprintf('(%5.1f, %5.1f, %5.1f) ', P.x, P.y, P.z), ...
%    sprintf('(%7s, %7s, %7s)', outstr{:})]);
end