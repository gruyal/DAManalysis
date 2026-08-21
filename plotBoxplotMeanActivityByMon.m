function plotBoxplotMeanActivityByMon(combDAMTab)

% function plotBoxplotMeanActivityByMon(combDAMTab)
%
% plots a boxplot for the mean activity by fly by day for each monitor
%
% INPUT
% combDAMTab -      Table from processDAMDataFolder
%
% OUTPUT
% boxplot


figure

flyNames = arrayfun(@(x) ['Fly', num2str(x)], 1:32, 'uniformoutput', 0);
sumAct = varfun(@sum, combDAMTab, InputVariables= flyNames, GroupingVariables={'MonNum', 'Day'});
sumNames = cellfun(@(x) ['sum_', x], flyNames, 'uniformoutput', 0);
% nan is there to take into account flies that stopped moving after a few
% days
meanByDayAct = varfun(@nanmean, sumAct, InputVariables= sumNames, GroupingVariables='MonNum');

meanByDayActF = rows2vars(meanByDayAct(:, 3:end)); % flipping the table and getting rid of first two column
monNames = arrayfun(@(x) num2str(x), meanByDayAct{:, 1}', 'uniformoutput', 0);
meanByDayActF.Properties.VariableNames = ['Flies', monNames];

cMap = colormap(lines(length(monNames)));

bH = boxchart(meanByDayActF, monNames);
hold on 
if ~isempty(combDAMTab.Properties.UserData)
    xticklabels(values(combDAMTab.Properties.UserData))
else
    xticklabels(monNames)
end
ylabel('Mean Counts Per Day')


% will not work if there is only one box
axh = bH(1).Parent;
tempYLim = axh.YLim;
axh.YLim = [0, tempYLim(2)];

xVal = repmat(axh.XTick, height(meanByDayActF), 1);
yVal = meanByDayActF{:, monNames};

sH = swarmchart(xVal, yVal, XJitter='rand', XJitterWidth=0.1 * min(diff(double(unique(xVal)))));
hold off

for ii=1:length(bH)
    bH(ii).BoxFaceColor = cMap(ii, :);
    bH(ii).MarkerColor = 'w';
    sH(ii).CData = cMap(ii, :);
    sH(ii).MarkerFaceColor = cMap(ii, :);
end


end