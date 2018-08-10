function saveAllFigures(trial_name)
% SAVEALLFIGURES saves all open figures as 300 dpi png files.

fprintf('%s - Saving all figures ...\n\n', datestr(now));
num = 1;
figs = findall(groot, 'Type', 'figure');
num_figs = length(figs);

for i = 1:num_figs
    f = figs(i);
    
    if isempty(f.Name)
        name = sprintf('Untitled%02d',num);
        num = num + 1;
    else
        name = f.Name;
    end
    
    if nargin == 1
        name = sprintf('%s - %s',trial_name,name);
    end
    
    fprintf('Saving Figure %d of %d, \"%s\" ... \n',...
        i, num_figs, name);
    saveFigure(f, name);
end
fprintf('Saving Done!\n\n')

end