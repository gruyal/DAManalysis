function plotMeanActivityOverDays(damTable, monitorNum, daysToPlot)

% function plotActivityMonitor(damTable, monitorNum)
%
% Plots activity by day on ZT for the data from one activity monitor
%
% INPUT
%
% damTable -        DAM activity table which is the output from
%                   processDAMMonitor/Folder
% MonitorNum -      either a single number or an array with all the numbers of
%                   the relevant monitors
% daysToPlot -      array with the numbers of the days to plot


figure

smWin = 21;
cMap = colormap(lines(length(monitorNum)+1));

for mm=1:length(monitorNum)

    relTab = damTable(damTable.MonNum == monitorNum(mm) & ismember(damTable.Day, daysToPlot), :);
    
    meanAct = varfun(@mean, relTab, InputVariables= 'meanAct', GroupingVariables='ztTime');
    meanLgt = varfun(@mean, relTab, InputVariables= 'Light', GroupingVariables='ztTime');
    % smoothing data
    smMeanData = smooth(meanAct.mean_meanAct, smWin, 'rloess');

    if mm==1
        lh = plot(meanAct.ztTime, smMeanData, 'LineWidth',2, 'Color',cMap(mm,:));
        hold on
        axh = lh.Parent;
    else
        plot(axh, meanAct.ztTime, smMeanData, 'LineWidth',2, 'Color',cMap(mm,:))
    end

end
hold off
lightOffInd = find(meanLgt.mean_Light ==0, 1, 'first');
plotTime = meanAct.ztTime;

YMax = axh.YLim(2);
patchX = [plotTime(lightOffInd), plotTime(end), plotTime(end), plotTime(lightOffInd)];
patchY = [0, 0, YMax, YMax];
patch(axh, patchX, patchY, [1,1,1]*0.85, 'FaceAlpha',.5)
axh.Children = flipud(axh.Children);    
hold off


axh.XTick = hours(0:6:24);
axh.XTickLabel = cellfun(@(x) x(1:2), axh(end).XTickLabel, 'UniformOutput', false);

if isempty(damTable.Properties.UserData)
    legTit = arrayfun(@(x) num2str(x), monitorNum, 'uniformoutput', 0);
else
    legTit = damTable.Properties.UserData(monitorNum);
end
legend(axh,axh.Children(1:end-1), legTit, 'location', 'northwest')
legend('boxoff')

end