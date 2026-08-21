
function sleepBtDurTab = generateSleepBoutTable(proccessDAMTab)

% function sleepBtDurTab = generateSleepBoutTable(proccessDAMTab)
%
% This function generates a sleepBout table from the output of processDAMDataFolder
% and addingMetaData2DAMTable.
% It only analyzes days that were deemed relevant (excludes Nan) and flies
% that were active enough.
%
% The output is a table with rows for every monitor fly, with all the sleep
% bouts length and start time

sleepRelTab = proccessDAMTab(~isnan(proccessDAMTab.sleepProp), :);
sleepRelTab.Properties.UserData = proccessDAMTab.Properties.UserData;

relMon = unique(sleepRelTab.MonNum);
sleepFlyInds = cellfun(@(x) contains(x, '_sleep'), sleepRelTab.Properties.VariableNames);
sleepFlyNames = sleepRelTab.Properties.VariableNames(sleepFlyInds);

sleepBtDurTab = table();

for ii=1:length(relMon)
    
    tempTab = sleepRelTab(sleepRelTab.MonNum == relMon(ii), :);
    
    for jj=1:length(sleepFlyNames)
        
        sleepVec = tempTab{:, sleepFlyNames{jj}};

        if all(~isnan(sleepVec))
        
            [tempVal, tempInds, tempLen] = SplitVec(tempTab{:, sleepFlyNames{jj}}, 'equal', 'firstval', 'loc', 'length');
            
            relFirstInd = cellfun(@(x) x(1), tempInds(tempVal == 1));
            SleepBtLen = tempLen(tempVal == 1);
            LogLen = log10(SleepBtLen);

            RelZtHr = floor(hours(tempTab.ztTime(relFirstInd)));
            % altough flynum is just jj
            FlyInd = ones(length(relFirstInd), 1) * str2double(extract(sleepFlyNames{jj}, digitsPattern));

            tempFlyTab = [tempTab(relFirstInd, {'MonNum', 'MonOrd', 'Day', 'Light'}), table(FlyInd, RelZtHr, SleepBtLen, LogLen)];
            sleepBtDurTab = [sleepBtDurTab; tempFlyTab];
        end
        
    end
    
end

end