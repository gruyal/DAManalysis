% load the file

damTab = readtable('./DAManalysis/Monitor68.txt');
flyNames = arrayfun(@(x) ['Fly', num2str(x)], 1:32, 'uniformoutput', 0);
colNames = [{'Index'}, {'DateDay'}, {'DateMonth'}, {'DateYear'}, {'Time'},...
            {'Status'}, {'Ext'}, {'MonNum'}, {'TubeNum'}, {'DataType'}, ...
            {'Unused'}, {'Light'}, flyNames];


damTab.Properties.VariableNames = colNames;

clear colNames

%% finding the first time in the second day when the light turns on

uniDays = unique(damTab.DateDay, 'stable');
day1Size = sum(damTab.DateDay == uniDays(1));
day2Light = damTab{damTab.DateDay == uniDays(2), 'Light'};
firstOnInd = find(day2Light == 1, 1, 'first');

tempTime = damTab.Time;
tempTime = tempTime - tempTime(day1Size+firstOnInd);
tempTime(1:day1Size+firstOnInd-1) = missing; 

for tt=1:length(tempTime)
    if ~isnan(tempTime(tt)) && tempTime(tt) < 0
        tempTime(tt) = tempTime(tt)+ hours(24);
    end
end

damTab.ztTime = tempTime;
damTab = movevars(damTab,'ztTime','after', 'Time');

clear day1Size uniDays firstOnInd tt day2Light tempTime

%% Defining days based on ZT

zt0Inds = find(damTab.ztTime == hours(0));
tempDay = nan(height(damTab), 1);
for ii=1:length(zt0Inds)-1
    tempDay(zt0Inds(ii):zt0Inds(ii+1)-1) = ii;
end

damTab.Day = tempDay;
damTab = movevars(damTab,'Day','after', 'ztTime');

clear zt0Inds tempDay ii


%% excluding dead flies

noiseCutoff = 5; % samples per day

sumByDay = varfun(@sum, damTab, 'InputVariables', flyNames, 'GroupingVariables','Day');

% warning if the number of samples per day is too small
for ii=1:height(sumByDay)

    if sumByDay.GroupCount(ii) < 24*60
        warning('Day %d has only %d samples in it', sumByDay.Day(ii), sumByDay.GroupCount(ii))
    end
end

for fly=1:length(flyNames)

    for dd=1:height(sumByDay)

        if all(sumByDay{dd:end, ['sum_', flyNames{fly}]} <= noiseCutoff)

            damTab{ismember(damTab.Day, sumByDay.Day(dd:end)), flyNames{fly}} = missing;
            warning('%s has been excluded from analysis from day %d onwards', flyNames{fly}, sumByDay.Day(dd))
            break % to avoid running through the loop for the next days
        end

    end

end

clear fly dd noiseCutoff ii

%% Calculate sleep

numOfConsecSamp = 5;
offset = floor(numOfConsecSamp/2);

for fly = 1:length(flyNames)
    
    tempFlySleep = zeros(height(damTab), 1);

    for samp = 1+offset:height(damTab)-offset

        if all(isnan(damTab{samp-offset:samp+offset, flyNames{fly}}))

            tempFlySleep(samp-offset:samp+offset) = missing;

        elseif all(damTab{samp-offset:samp+offset, flyNames{fly}} == 0)

            tempFlySleep(samp-offset:samp+offset) = 1;

        end

    end

    damTab(:, [flyNames{fly}, '_sleep']) = table(tempFlySleep);
    damTab = movevars(damTab,[flyNames{fly}, '_sleep'],'after',flyNames{fly});

end



clear fly samp tempFlySleep numOfConsecSamp offset

%% Adding mean activity and proportion sleep columns

sleepNames = cellfun(@(x) [x, '_sleep'], flyNames, 'uniformoutput', 0);
daysToPlot = unique(damTab.Day(~isnan(damTab.Day))); %nan cant be unique
meanAct = nan(height(damTab), 1);
sleepProp = nan(height(damTab), 1);

for day=1:length(daysToPlot)
    dayInds = damTab.Day == daysToPlot(day);
    tempTab = damTab(dayInds, :);
    relFliesInd = ~isnan(tempTab{1, flyNames}); % since the first sample is indicative of the whole day
    relFlyNames =flyNames(relFliesInd); 
    relSleepNames = sleepNames(relFliesInd);
    tempMeanAct = mean(tempTab{:, relFlyNames}, 2);
    tempSleepProp = sum(tempTab{:, relSleepNames}, 2)./sum(relFliesInd);

    meanAct(dayInds) = tempMeanAct;
    sleepProp(dayInds) = tempSleepProp;

end

damTab.meanAct = meanAct;
damTab.sleepProp = sleepProp; 

clear meanAct sleepProp day rel* temp*



%% Activity plot

tiledlayout(length(daysToPlot), 1, 'TileSpacing','none')
axh = gobjects(length(daysToPlot), 1);
YMax = 0;

for day=1:length(daysToPlot)

    dayInds = damTab.Day == daysToPlot(day);
    tempTab = damTab(dayInds, :);
    axh(day) = nexttile;
    hold on
    meanData = tempTab.meanAct;
    smMeanData = smooth(meanData, 11, 'rloess');
    plotTime = tempTab.ztTime;

    plot(plotTime, smMeanData, 'LineWidth',2, 'Color','k')
    if day<length(daysToPlot)
        axh(day).XTickLabel = [];
        axh(day).XTick = [];
    end

    if axh(day).YLim(2) > YMax
        YMax = axh(day).YLim(2);
    end

end

% eq y axis

figH = gcf;

lightOffInd = find(tempTab.Light ==0, 1, 'first');

for ax = 1:length(axh)
    axh(ax).YLim = [0, YMax];
    patchX = [plotTime(lightOffInd), plotTime(end), plotTime(end), plotTime(lightOffInd)];
    patchY = [0, 0, YMax, YMax];
    patch(axh(ax), patchX, patchY, [1,1,1]*0.85, 'FaceAlpha',.5)
    axh(ax).Children = flipud(axh(ax).Children);    
        
    hold off
end

axh(end).XTick = hours(0:6:24);
axh(end).XTickLabel = cellfun(@(x) x(1:2), axh(end).XTickLabel, 'UniformOutput', false);


%% Sleep plot

tiledlayout(length(daysToPlot), 1, 'TileSpacing','none')
axh = gobjects(length(daysToPlot), 1);

for day=1:length(daysToPlot)

    dayInds = damTab.Day == daysToPlot(day);
    tempTab = damTab(dayInds, :);
    axh(day) = nexttile;
    hold on
    sleepData = tempTab.sleepProp;
    smSleepData = smooth(sleepData, 11, 'rloess');
    plotTime = tempTab.ztTime;

    plot(plotTime, smSleepData, 'LineWidth',2, 'Color','k')
    if day<length(daysToPlot)
        axh(day).XTickLabel = [];
        axh(day).XTick = [];
    end

end

% eq y axis

figH = gcf;

lightOffInd = find(tempTab.Light ==0, 1, 'first');

for ax = 1:length(axh)
    axh(ax).YLim = [-0.1, 1.1];
    patchX = [plotTime(lightOffInd), plotTime(end), plotTime(end), plotTime(lightOffInd)];
    patchY = [-0.1, -0.1, 1.1, 1.1];
    patch(axh(ax), patchX, patchY, [1,1,1]*0.85, 'FaceAlpha',.5)
    axh(ax).Children = flipud(axh(ax).Children);    
        
    hold off
end

axh(end).XTick = hours(0:6:24);
axh(end).XTickLabel = cellfun(@(x) x(1:2), axh(end).XTickLabel, 'UniformOutput', false);

%% checking sleep bouts length (before assigning sleep)

% dirty and does not check for Nans
relInds = ~isnan(damTab.Day);
allSleepBoutLenCell = cell(length(flyNames), 1);
for fly=1:length(flyNames)

    relDat = damTab{relInds, flyNames(fly)};
    [spVec, boutLen, firstVal] = SplitVec(relDat == 0, 'equal', 'split', 'length', 'firstVal');
    allSleepBoutLenCell{fly} = boutLen(firstVal); % since when it is one here, the original value was zero

end
%%

figure  
histogram(vertcat(allSleepBoutLenCell{:}), 200)

set(gca, 'YScale', 'log')

%%
figure
plot(sort(vertcat(allSleepBoutLenCell{:})), 'linewidth', 2)
