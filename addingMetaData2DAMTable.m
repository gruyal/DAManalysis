function combDAMTab = addingMetaData2DAMTable(combDAMTab, monOrd, monLabels)

% function addingMetaData2DAMTable(monOrd, monLabels)
%
% This function adds a column in the table with ordered numbers based on
% the order given in the input. This is done to facilitate plotting 
%
% INPUT
%
% combDAMTab -  output Table from processDAMDataFolder
% monOrd -      1XN array of monitor numbers ordered by the required order. For
%               example, if the monitors are 67,68, and 69 a monOrd of 
%               [68, 67, 69] will result in a column of 1s for 68, 2s for 67
%               and 3s for 69
%               Note! monOrd should include all monitors
% monLabels -   cell array of labels ordered in the same order as given in
%               monOrd. In the example above - first label will be assigned
%               to 68
% OUTPUT
% adding a monOrd column to the table based on the input, and adding a
% dictionary into the UserData properties of the table. 

% Adding MonOrd column 
allMon = unique(combDAMTab.MonNum);
assert(all(allMon == sort(monOrd)'), 'monOrd does not match monitors in table')

combDAMTab.MonOrd = zeros(height(combDAMTab), 1);
combDAMTab = movevars(combDAMTab, 'MonOrd', 'After', 'MonNum');

for ii=1:length(monOrd)
    combDAMTab{combDAMTab.MonNum == monOrd(ii), 'MonOrd'} = ii;
end

% Adding Dictionary
assert(length(monLabels) == length(monOrd), 'labels do not match monitor number')
expDic = dictionary(monOrd, monLabels);
combDAMTab.Properties.UserData = expDic; 






end