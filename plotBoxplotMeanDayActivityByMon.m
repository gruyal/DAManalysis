function plotBoxplotMeanDayActivityByMon(combDAMTab, varargin)

% function plotBoxplotMeanDayActivityByMon(combDAMTab)
%
% plots a boxplot for the mean daytime activity by fly by day for each monitor
%
% INPUT
% combDAMTab -      Table from processDAMDataFolder
% lightFlag -       (optional) if given will plot only Day (lightFlag=1) or
%                   only night (0) or both (2) if you want to select days
%                   also
% dayToPlot -       (optional) should be given as second input 1XD array of
%                   the days to plot, either as sequence (1:4) or vector (e.g. [1,3,4])
%
% OUTPUT
% boxplot


combDAMTab = combDAMTab(~isnan(combDAMTab.Day), :);
if nargin == 2
    lightF = varargin{1};
    assert(ismember(lightF, [0,1]), 'LightFlag should be a 0 or 1')
    % Filter for light condition 
    combDAMTab = combDAMTab(combDAMTab.Light == lightF, :);
elseif nargin == 3
    lightF = varargin{1};
    assert(ismember(lightF, [0,1,2]), 'LightFlag should be a 0 or 1')
    daysToPlot = varargin{2};
    assert(all(ismember(daysToPlot, unique(combDAMTab.Day(~isnan(combDAMTab.Day))))), 'days to plot outside of experiment days range')
    % Filter for light condition and days
    if lightF < 2
        combDAMTab = combDAMTab(combDAMTab.Light == lightF & ismember(combDAMTab.Day, daysToPlot), :);
    else
        combDAMTab = combDAMTab(ismember(combDAMTab.Day, daysToPlot), :);
    end
else
   error('Only 2 optional inputs are allowed')
end


%
figure

flyNames = arrayfun(@(x) ['Fly', num2str(x)], 1:32, 'uniformoutput', 0);
sumAct = varfun(@sum, combDAMTab, InputVariables= flyNames, GroupingVariables={'MonOrd', 'Day'});
sumNames = cellfun(@(x) ['sum_', x], flyNames, 'uniformoutput', 0);
% nan is there to take into account flies that stopped moving after a few
% days
meanByDayAct = varfun(@nanmean, sumAct, InputVariables= sumNames, GroupingVariables='MonOrd');

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