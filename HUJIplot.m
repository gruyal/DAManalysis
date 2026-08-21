pfosTab = readtable('./DAManalysis/PFOA Young Climbing.xlsx');

%%

maleTab =pfosTab(:, {'Treatment', 'Replicate', 'FeMales'});
maleTab = renamevars(maleTab, 'Males', 'Climbing');
maleTab.pSex = repmat({'M'}, height(maleTab), 1);

femaleTab =pfosTab(:, {'Treatment', 'Replicate', 'Females'});
femaleTab = renamevars(femaleTab, 'Females', 'Climbing');
femaleTab.pSex = repmat({'F'}, height(femaleTab), 1);

newTab = [maleTab; femaleTab];
newTab.Sex = categorical(newTab.pSex);
conOrder = {'Control', '5nM', '50nM', '100nM'};
newTab.Concentration = categorical(newTab.Treatment, conOrder);

%%
bH = boxchart(newTab.Concentration,newTab.Climbing,'GroupByColor',newTab.Sex);
% ylabel('Temperature (F)')
legend
bH(1).Parent.YLim = [0,100];
bH(1).Parent.YTick = [0,50, 100];

saveas(gcf,'climbingPFOA.pdf')
