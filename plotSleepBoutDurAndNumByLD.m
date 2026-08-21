function plotSleepBoutDurAndNumByLD(slpTab, logFlag)

% function plotSleepBoutDurAndNumByLD(slpTab, logFlag)
%
% Uses the output from generateSleepBoutTable to plot Sleep bout duration
% and number by Dark/Light state. 
%
% INPUT
%
% slpTab -      Table that is the output from generateSleepBoutTable
% logFlag -     (optional) if true plots the log 10 of bout duration and
%               not the duration in min

if nargin == 2
    lgF = logFlag;
else
    lgF = 0;
end

if lgF
    relVar = 'LogLen';
    yLabSt = 'Logged Bout Duration log10(min)';
else
    relVar = 'SleepBtLen';
    yLabSt = 'Bout Duration (min)';
end


figure

tiledlayout(2, 1) %, 'TileSpacing','none')
axh = gobjects(2, 1);

axh(1) = nexttile(1);

% plotting duration of bouts
bH = boxchart(slpTab.Light, slpTab{:, relVar}, 'GroupByColor', slpTab.MonOrd);
for ii=1:length(bH)
    bH(ii).MarkerStyle = '.';
end

axh(1).XTick = [0,1];
axh(1).XTickLabel = {'Dark', 'Light'};
axh(1).Title.String = 'Bout Duration by Light';
axh(1).YLabel.String = yLabSt;

legTit = values(slpTab.Properties.UserData);
legend(legTit, 'location', 'northeast');
legend('boxoff')

% Plotting number of bouts

[slpGrp, TID] = findgroups(slpTab(:, {'MonOrd', 'FlyInd', 'Light'}));
TID.numBouts = splitapply(@numel,slpTab.SleepBtLen,slpGrp);


axh(2) = nexttile(2);

bH = boxchart(TID.Light, TID.numBouts, 'GroupByColor', TID.MonOrd);
for ii=1:length(bH)
    bH(ii).MarkerStyle = '.';
end

axh(2).XTick = [0,1];
axh(2).XTickLabel = {'Dark', 'Light'};
axh(2).Title.String = 'Bout Number by Light';
axh(2).XLabel.String = 'Dark/Light Stage';
axh(2).YLabel.String = 'Number of Bouts';
end