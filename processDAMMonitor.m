function [damTab, varargout] = processDAMMonitor(fileName)
% function processDAMMonitor(fileName)
%
% This function processes the data from one activity monitor and outputs a
% table with sleep and mean activity per row.
%
% INPUT
% monitor text file name. The text file should include the standard columns
% as detialed in https://trikinetics.com/Downloads/DAMSystem3%20Software%20Data%20Sheet.pdf
% Note! light sensor should be in column 10 for the function to parse the
% data correctly into days
%
%
% OUTPUT
%
% 'Index','DateDay', 'DateMonth','DateYear','Time' - Taken from the original table
% 'ztTime' - calculated based on the light column
% 'Day','Status','Ext','MonNum','TubeNum','DataType','Unused','Light' -
% taken from original table
% Fly#, Fly#_sleep - original and sleep data calculated per fly
% meanAct - meanActivity calculated over all the live flies of that day. 
% sleep Prop - sleep proportion claculated over all the live flies of that
% day


numOfConsecSamp = 5; % number of consecutive samples to consider a sleep bout
noiseCutoff = 5; % samples per day to consider a fly alive

damTab = readtable(fileName);
flyNames = arrayfun(@(x) ['Fly', num2str(x)], 1:32, 'uniformoutput', 0);
colNames = [{'Index'}, {'DateDay'}, {'DateMonth'}, {'DateYear'}, {'Time'},...
            {'Status'}, {'Ext'}, {'MonNum'}, {'TubeNum'}, {'DataType'}, ...
            {'Unused'}, {'Light'}, flyNames];


damTab.Properties.VariableNames = colNames;

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

% Defining days based on ZT
zt0Inds = find(damTab.ztTime == hours(0));
tempDay = nan(height(damTab), 1);
for ii=1:length(zt0Inds)-1
    tempDay(zt0Inds(ii):zt0Inds(ii+1)-1) = ii;
end

damTab.Day = tempDay;
damTab = movevars(damTab,'Day','after', 'ztTime');


% excluding dead flies


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

% Calculate sleep


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

% Adding mean activity and proportion sleep columns

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

if nargout > 1
    varargout{1} = sumByDay;
end


end