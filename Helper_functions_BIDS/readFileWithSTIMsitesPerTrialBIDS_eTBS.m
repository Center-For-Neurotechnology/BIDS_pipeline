function [stimSitesFromLog, stWithStimInfo] = readFileWithSTIMsitesPerTrialBIDS(dataFilePath)

stWithStimInfo=[];
stimSitesFromLog = [];
if isempty(dataFilePath)
    return;
end
%cellWithStimInfo=cell(0,0);
% how to integrate a folder in this - ask Rina

% if contains(lower(fileNameStimSites),'.txt')
%     [stimSitesFromLog] = readStimSiteFromTxtFile(stimLogFile);
if ischar(dataFilePath) || isstring(dataFilePath)
    if contains(lower(dataFilePath),'.mat') %assumes .mat file
        stStimSites = load(dataFilePath);
    if isfield(stStimSites,'stimLogStruct') && isfield(stStimSites.stimLogStruct,'data')
        stimSitesFromLog = stStimSites.stimLogStruct.data(:,2:3);
        stWithStimInfo = stStimSites.stimLogStruct.data; 
    elseif isfield(stStimSites,'stimSitesFromLog')
        stimSitesFromLog = stStimSites.stimSitesFromLog;
        stWithStimInfo = stStimSites.stWithStimInfo;
     %   cellWithStimInfo = stStimSites.cellWithStimInfo;
    elseif isfield(stStimSites,'stimchans') % directly use the original .mat file with stim info (only 2 columns with Cerestim ch number)
        stimSitesFromLog = stStimSites.stimchans;
        stimSitesFromLog = [[0:(size(stimSitesFromLog,1)-1)]',stimSitesFromLog];
    elseif isfield(stStimSites,'databystim') % use Britni's dataset to get stim channel (MG108)
        stimSitesFromLog = stStimSites.databystim{1}.stimchans';
        stimSitesFromLog = [stimSitesFromLog,stimSitesFromLog+1]; % add second channel (assuming it was the next one)
        stimSitesFromLog = [[0:(size(stimSitesFromLog,1)-1)]',stimSitesFromLog];
    elseif isfield(stStimSites,'stimMatrix') % 
        stimSitesFromLog = stStimSites.stimMatrix;
        stimSitesFromLog = stimSitesFromLog(:,2,3); % add second channel (assuming it was the next one)
        stWithStimInfo    = stimMatrix;
    end
    end
else % if NO file Return empty and then ->USE ALL STIM
    stimSitesFromLog = [];
end
