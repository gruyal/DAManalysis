function plotSleepBoutDurAndNumByZT(slpTab, logFlag)

% function plotSleepBoutDurAndNumByZT(slpTab, logFlag)
%
% Uses the output from generateSleepBoutTable to plot Sleep bout duration
% and number by ZT hour. 
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
bH = boxchart(slpTab.RelZtHr, slpTab{:, relVar}, 'GroupByColor', slpTab.MonOrd);
for ii=1:length(bH)
    bH(ii).MarkerStyle = '.';
end

axh(1).XTick = 0:6:24;
axh(1).XTickLabel = arrayfun(@(x) num2str(x), axh(1).XTick, 'UniformOutput',0);
axh(1).Title.String = 'Bout Duration by ZT';
axh(1).YLabel.String = yLabSt;

legTit = values(slpTab.Properties.UserData);
legend(legTit, 'location', 'northeast');
legend('boxoff')

% Plotting number of bouts

[slpGrp, TID] = findgroups(slpTab(:, {'MonOrd', 'FlyInd', 'RelZtHr'}));
TID.numBouts = splitapply(@numel,slpTab.SleepBtLen,slpGrp);


axh(2) = nexttile(2);

bH = boxchart(TID.RelZtHr, TID.numBouts, 'GroupByColor', TID.MonOrd);
for ii=1:length(bH)
    bH(ii).MarkerStyle = '.';
end

axh(2).XTick = 0:6:24;
axh(2).XTickLabel = arrayfun(@(x) num2str(x), axh(1).XTick, 'UniformOutput',0);
axh(2).Title.String = 'Bout Number by ZT';
axh(2).XLabel.String = 'ZT';
axh(2).YLabel.String = 'Number of Bouts';
end