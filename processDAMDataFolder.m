function combDAMTab = processDAMDataFolder(dirName)
warning('off','backtrace')
damFiles = dir(fullfile(dirName, 'Monitor*.txt'));
combDAMTab = table;

for ii=1:length(damFiles)

    [tempTab, dayCountTab] = processDAMMonitor(damFiles(ii).name);
    fprintf('loaded data from %s \n', damFiles(ii).name)
    disp(dayCountTab(:, {'Day', 'GroupCount'}))
    combDAMTab = [combDAMTab; tempTab];

end

warning('on','backtrace')
end

