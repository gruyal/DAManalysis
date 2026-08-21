function plotMeanActivityFromMonitor(damTable, monitorNum, varargin)

% function plotActivityMonitor(damTable, monitorNum)
%
% Plots activity by day on ZT for the data from one activity monitor
%
% INPUT
%
% DamTable -        DAM activity table which is the output from
%                   processDAMMonitor/Folder
% MonitorNum -      either a single number or an array with all the numbers of
%                   the relevant monitors
% optional input -  Days to exclude from plotting. Excludes from the day
%                   given until the end
%


figH=figure;

smWin = 21; 
cMap = colormap(lines(length(monitorNum)+1));
    
% setting the right number of axes (how many days to plot)
zeroTab = damTable(damTable.MonNum == damTable.MonNum(1), :);
daysToPlot = unique(zeroTab.Day(~isnan(zeroTab.Day))); %nan cant be unique

if nargin == 3
    excFromDay = varargin{1};
    assert(excFromDay <= max(daysToPlot), 'excluded days exceed length of experiment')
    daysToPlot = daysToPlot(daysToPlot < excFromDay);
end

t = tiledlayout(length(daysToPlot)-1, 1, 'TileSpacing','none')
axh = gobjects(length(daysToPlot)-1, 1);
YMax = 0;

for mm=1:length(monitorNum)

    relTab = damTable(damTable.MonNum == monitorNum(mm), :);
    
    for day=1:length(daysToPlot)-1
    
        dayInds = ismember(relTab.Day, daysToPlot([day, day+1]));
        tempTab = relTab(dayInds, :);
        axh(day) = nexttile(day);
        hold on
        meanData = tempTab.meanAct;
        smMeanData = smooth(meanData, smWin, 'rloess');

        plotTime = tempTab.ztTime;
        newDayInd = find(plotTime == 0);
        plotTime(newDayInd(2):end) = plotTime(newDayInd(2):end) + days(1);
    
        plot(plotTime, smMeanData, 'LineWidth',2, 'Color',cMap(mm, :))
        if day<length(daysToPlot)
            axh(day).XTickLabel = [];
            axh(day).XTick = [];
        end
    
        if axh(day).YLim(2) > YMax
            YMax = axh(day).YLim(2);
        end
    
    end

end

% eq y axis

% lightOffInd = find(tempTab.Light ==0, 1, 'first');
% lightOnInd = find(tempTab.Light ==1, 1, 'last');
newNightInd = find(tempTab.ztTime == hours(12));
newDayInd = find(tempTab.ztTime == 0);

for ax = 1:length(axh)
    axh(ax).YLim = [0, YMax];
    patchX = [plotTime(newNightInd(1)), plotTime(newDayInd(2)-1), plotTime(newDayInd(2)-1), plotTime(newNightInd(1))];
    patchY = [0, 0, YMax, YMax];
    patch(axh(ax), patchX, patchY, [1,1,1]*0.85, 'FaceAlpha',.5)
    patchX2 = [plotTime(newNightInd(2)), plotTime(end), plotTime(end), plotTime(newNightInd(2))];
    patch(axh(ax), patchX2, patchY, [1,1,1]*0.85, 'FaceAlpha',.5)
    axh(ax).Children = flipud(axh(ax).Children);    
        
    hold off
end

axh(end).XTick = hours(0:6:48);
axh(end).XTickLabel = datestr(axh(end).XTick, 'HH:MM');

ylabel(t, 'Mean Activity Per Min')
xlabel(axh(end), 'Zeitgeber time (ZT)')

if isempty(damTable.Properties.UserData)
    legTit = arrayfun(@(x) num2str(x), monitorNum, 'uniformoutput', 0);
else
    legTit = damTable.Properties.UserData(monitorNum);
end

%legend(axh(end),axh(end).Children(1:end-2), legTit, 'location', 'northwest')
%legend('boxoff')

lgd = legend(axh(end), axh(end).Children(1:end-2), legTit);
lgd.Layout.Tile = 'south';
lgd.Orientation = 'horizontal';
lgd.Box = 'off';
end