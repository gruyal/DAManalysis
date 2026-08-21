%% Analyzing experiment script changed here

dirName = '/Users/eyalgruntman/Library/CloudStorage/OneDrive-UniversityofToronto/Documents/DAManalysis';

combDAMTab = processDAMDataFolder(dirName);

%% adding metadata

expMon = [69,67,68];
monDesc = {'WT', 'mettle3D', 'something else'};

combDAMTab = addingMetaData2DAMTable(combDAMTab, expMon, monDesc);
% 
% expDic = dictionary(expMon, monDesc);
% 
% combDAMTab.Properties.UserData = expDic; 
% 
clear expMon monDesc 

%%

plotMeanActivityFromMonitor(combDAMTab, [67, 69], 5)

%%

plotMeanSleepFromMonitor(combDAMTab, 67:69)


%%


plotMeanActivityOverDays(combDAMTab, 67:69, 1:5)

%%

plotBoxplotMeanActivityByMon(combDAMTab)

%%

plotBoxplotMeanDayActivityByMon(combDAMTab,2, [2,3,5])


%%

sleepTab = generateSleepBoutTable(combDAMTab);

%%

bH = boxchart(sleepTab.RelZtHr, sleepTab.SleepBtLen, 'GroupByColor', sleepTab.MonOrd);
for ii=1:length(bH)
    bH(ii).MarkerStyle = '.';
end

figure

bH = boxchart(sleepTab.RelZtHr, sleepTab.LogLen, 'GroupByColor', sleepTab.MonOrd);
for ii=1:length(bH)
    bH(ii).MarkerStyle = '.';
end

%%

tempSlpTab = sleepTab(sleepTab.MonOrd == 1, :);

bH = boxchart(tempSlpTab.FlyInd, tempSlpTab.SleepBtLen, 'GroupByColor', tempSlpTab.Light);
for ii=1:length(bH)
    bH(ii).MarkerStyle = '.';
end

%%

bH = boxchart(sleepTab.Light, sleepTab.LogLen, 'GroupByColor', sleepTab.MonOrd);
for ii=1:length(bH)
    bH(ii).MarkerStyle = '.';
end

%%

plotSleepBoutDurAndNumByLD(sleepTab,1)
