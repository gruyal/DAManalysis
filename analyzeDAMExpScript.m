%% Analyzing experiment script

dirName = pwd;

combDAMTab = processDAMDataFolder(dirName);

%% adding metadata

expMon = [51, 52, 53, 54, 59, 60, 61];
monDesc = {'A', 'B', 'C', 'D', 'E', 'F', 'H'};

combDAMTab = addingMetaData2DAMTable(combDAMTab, expMon, monDesc);
% 
% expDic = dictionary(expMon, monDesc);
% 
% combDAMTab.Properties.UserData = expDic; 
% 
clear expMon monDesc 

%% Plots double actograms for sequential days in the experiment
%% variable 2 specifies number and order of monitors to plot (e.g., 67:69 or [67,69], it will plot the monitors in order specified in variable 2)
%% variable 3 specifies days to exclude at the end (e.g., "4" cuts day for and onward)

plotMeanActivityFromMonitor(combDAMTab, [51, 52, 53, 54, 59, 60, 61])

%% Plots sleep over ZT for sequential days in the experiment 
%% variable 2 specifies number and order of monitors to plot (e.g., 67:69 or [67,69], it will plot the monitors in order specified in variable 2)
%% variable 3 specifies days to exclude at the end (e.g., "4" cuts day 4 and onward)

plotMeanSleepFromMonitor(combDAMTab, [51, 52, 53, 54, 59, 60, 61])


%% Plots mean actogram for all days 
%% variable 2 specifies monitors to plot (e.g., 67:69 or [67,69]) it will plot the monitors in order specified in variable 2
%% variable 3 specifies days to plot (e.g., 1:5 or [1,4])

plotMeanActivityOverDays(combDAMTab, [51, 52, 53, 54, 59, 60, 61], 1:4)

%% Plots mean sleep ZT plot for all days 
%% variable 2 specifies monitors to plot (e.g., 67:69 or [67,69]) it will plot the monitors in order specified in variable 2
%% variable 3 specifies days to plot (e.g., 1:5 or [1,4])

plotMeanSleepOverDays(combDAMTab, [51, 52, 53, 54, 59, 60, 61], 1:4)

%% Plots total activity per 24hrs, averaged over days, as a boxplot 
%% variable 2 specifies night day or total: 0=night, 1=day, 2=total
%% variable 3 specifies days to plot (e.g., 1:5 or [1,4])
%% if variable 3 is specified, variable 2 is needed, if variable 3 is blank leave variable 2 blank if plotting total (day and night)

plotBoxplotMeanDayActivityByMon(combDAMTab, 1)

%%
%% Make the sleep version of 'plotBoxplotMeanDayActivityByMon'
%%


%% Generates the sleep bout table

sleepTab = generateSleepBoutTable(combDAMTab);


%% Plots average bout length and number per 24hrs in light and dark

plotSleepBoutDurAndNumByLD(sleepTab,1)

%% Plots average bout length and number over ZT time

plotSleepBoutDurAndNumByZT(sleepTab,1)