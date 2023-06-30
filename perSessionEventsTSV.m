function perSessionEventsTSV(directoryBIDS,sub_XXXX,taskName,ieeg_run,filenameNSx_nsp1,filenameNSx_nsp2,stimParameters,channInfo,fileNameStimSites,hdrNS3_nsp1,hdrNS3_nsp2)
%{
-	Onset
-	Duration
-	electrical_stimulation_trial_type
-	response_time
-	stim_file
-	HED
-	electrical_stimulation_StimOnset_sec
-	electrical_stimulation_StimOffset_sec
-	electrical_stimulation_Frequency_Hz
-	electrical_stimulation_Current_mA
-	electrical_stimulation_site
-	electrical_stimulation_type
-	electrical_stimulation_Channel1Stim	
-	electrical_stimulation_Channel1StimNSP
-	electrical_stimulation_Channel2Stim
-	electrical_stimulation_Channel2StimNSP
%}

% sub_XXXX\ses-postimp\ieeg\sub-XXXX_ses-postimp_task-NetworkWake1RAWNSP1_run-01_events.tsv
filename_eventsTSV_nsp1 = [directoryBIDS,'/',sub_XXXX,'/ses-postimp/ieeg/',sub_XXXX,'_ses-postimp_task-',...
    taskName,'RAWNSP1_run-',ieeg_run,'_events.tsv'];
filename_eventsTSV_nsp2 = [directoryBIDS,'/',sub_XXXX,'/ses-postimp/ieeg/',sub_XXXX,'_ses-postimp_task-',...
    taskName,'RAWNSP2_run-',ieeg_run,'_events.tsv'];

response_time = 'n/a';
stim_file = 'n/a';
HED = 'n/a';

cerestimAllBanks = [channInfo.bankInfo.bankANSP; channInfo.bankInfo.bankBNSP; channInfo.bankInfo.bankCNSP];

stimLogChannels = load(fileNameStimSites);
stimLogChannels = stimLogChannels.stimchans(:,1:2);
stimLogNSPs = [];
stimLogChannelsNSP = [];

% using log file to map cerestim stim channels to nsp channels to get: nsp
% number and channel number
for i = 1:size(stimLogChannels,1)
    for j = 1:size(stimLogChannels,2)
        if stimLogChannels(i,j) <= 32
            stimLogNSPs(i,j) = cerestimAllBanks(1);
            if cerestimAllBanks(1) == 1
                stimLogChannelsNSP(i,j) = stimLogChannels(i,j);
            else
                stimLogChannelsNSP(i,j) = stimLogChannels(i,j)+128;
            end
        elseif stimLogChannels(i,j) <= 65
            stimLogNSPs(i,j) = cerestimAllBanks(2);
            if cerestimAllBanks(2) == 1
                stimLogChannelsNSP(i,j) = stimLogChannels(i,j);
            else
                stimLogChannelsNSP(i,j) = stimLogChannels(i,j)+128;
            end
        else 
            stimLogNSPs(i,j) = cerestimAllBanks(3);
            if cerestimAllBanks(3) == 1
                stimLogChannelsNSP(i,j) = stimLogChannels(i,j);
            else
                stimLogChannelsNSP(i,j) = stimLogChannels(i,j)+128;
            end
        end 
    end
end

stimBipolarSites_nsp1 = {}; % getting the stim site channels
stimBipolarSites_nsp2 = {};
NSP1_counter = 0;
NSP2_counter = 0;
for i = 1:size(stimLogChannelsNSP,1)
    if stimLogChannelsNSP(i,1) <= 128
        stim_ch1 = hdrNS3_nsp1.hdr.label(stimLogChannelsNSP(i,1));
        currNSP = 1;
        NSP1_counter = NSP1_counter+1;
    else
        stim_ch1 = hdrNS3_nsp2.hdr.label(stimLogChannelsNSP(i,1)-128);
        currNSP = 2;
        NSP2_counter = NSP2_counter+1;
    end
    if stimLogChannelsNSP(i,2) <= 128
        stim_ch2 = hdrNS3_nsp1.hdr.label(stimLogChannelsNSP(i,2));
    else
        stim_ch2 = hdrNS3_nsp2.hdr.label(stimLogChannelsNSP(i,2)-128);
    end
    if currNSP == 1
        stimBipolarSites_nsp1{NSP1_counter,1} = join([stim_ch1 stim_ch2],'-'); % are both chs always in the same nsp?
        stimBipolarSites_nsp1{NSP1_counter,2} = stim_ch1;
        stimBipolarSites_nsp1{NSP1_counter,3} = 1;
        stimBipolarSites_nsp1{NSP1_counter,4} = stim_ch2;
        stimBipolarSites_nsp1{NSP1_counter,5} = 1;
    elseif currNSP == 2
        stimBipolarSites_nsp2{NSP2_counter,1} = join([stim_ch1 stim_ch2],'-');
        stimBipolarSites_nsp2{NSP2_counter,2} = stim_ch1;
        stimBipolarSites_nsp2{NSP2_counter,3} = 2;
        stimBipolarSites_nsp2{NSP2_counter,4} = stim_ch2;
        stimBipolarSites_nsp2{NSP2_counter,5} = 2;
    end

end

% 'Bipolar Single Pulse stim, channels: LTB_10-LTB_11, current: 7 mA, stimulation duration: 0.233 ms, frequency: 0 Hz'
stimTrialType_nsp1 = {};
stimTrialType_nsp2 = {};
part1 = join([stimParameters.stim_type{1},"Single Pulse stim"],' ');
part3 = join(["current:", string(stimParameters.stimCurrent), 'mA'],' ');
part4 = join(["stimulation duration:", string(stimParameters.stimPulseDuration), 'ms'],' ');
part5 = join(["frequency:", string(stimParameters.stimFrequency), 'Hz'],' ');

for i = 1:size(stimBipolarSites_nsp1,1) % both onset_sec and stimBipolarSites should be the same length/size
    part2 = join(["channels:", stimBipolarSites_nsp1{i}],' ');
    stimTrialType_nsp1{i,1} = join([part1,part2,part3,part4,part5],', ');    
end
for i = 1:size(stimBipolarSites_nsp2,1) % both onset_sec and stimBipolarSites should be the same length/size
    part2 = join(["channels:", stimBipolarSites_nsp2{i}],' ');
    stimTrialType_nsp2{i,1} = join([part1,part2,part3,part4,part5],', ');    
end



%% get stim times
fileNameNSxPerNSP{1} = filenameNSx_nsp1;
fileNameNSxPerNSP{2} = filenameNSx_nsp2;
stimChNumber = unique(stimLogChannels,'rows','stable')'; 

% STIMULATION CHANNELS
nStim = size(stimChNumber,2);        
channInfo.pName = sub_XXXX;
channInfo.stimChNumber = stimChNumber;  % the Cerestim number (1) - from the mat file if exists
channInfo.useBipolar =1;    
channInfo.chNamesToExcludeInput = {}; % from Notes:  if any

% Time - Usually fill this after Checking alignment!
timeInfo.startNSxSec= 0; % should already be trimmed
timeInfo.endNSxSec = []; 

%Results 
dirResults = 'E:\BIDStesting\testResultsDirectory';
if ~exist(dirResults,'dir'), mkdir(dirResults); end

%AINP STIM Channel
stimAINPChNames = {'SYNC'}; % 'SYNC','ainp6', 'ainp7'}; % all stim, random stim, detected stim
 
% Find channel names
channInfo = findChannelNamesInNSX(channInfo, [], fileNameNSxPerNSP); 
titName = 'bids';
% returns the index for stim at each nsp
[~,~,~,indTimeSTIMPerFile] = scriptCheckSyncStimInNSX(fileNameNSxPerNSP, fileNameStimSites, dirResults, stimAINPChNames, channInfo,titName, timeInfo.startNSxSec, timeInfo.endNSxSec);

%%
% moving through the stim ch log, determine which nsp each stim event was 
% at and add that time to either of the new nsp stim time arrays

% new stim arrays
stimTime_nsp1 = [];
stimTime_nsp2 = [];
stim1_counter = 1;
stim2_counter = 1;

for i = 1:size(stimLogNSPs,1)
    if stimLogNSPs(i,1) == 1
        stimTime_nsp1(stim1_counter,1) = indTimeSTIMPerFile{1,1}(i);
        stim1_counter = stim1_counter+1;
    elseif stimLogNSPs(i,1) == 2
        stimTime_nsp2(stim2_counter,1) = indTimeSTIMPerFile{1,2}(i);
        stim2_counter = stim2_counter+1;
    end
    
end

stimTime_nsp1 = stimTime_nsp1/hdrNS3_nsp1.hdr.Fs{1};
stimTime_nsp2 = stimTime_nsp2/hdrNS3_nsp2.hdr.Fs{1};
    
%% set up table vars    
% creating cells for table()
% nsp1
stimPulseDuration_nsp1 = cell(size(stimTime_nsp1));
responseTime_nsp1 = cell(size(stimTime_nsp1));
stimFile_nsp1 = cell(size(stimTime_nsp1));
hed_nsp1 = cell(size(stimTime_nsp1));
stimFrequency_nsp1 = cell(size(stimTime_nsp1));
stimCurrent_nsp1 = cell(size(stimTime_nsp1));
stim_type_nsp1 = cell(size(stimTime_nsp1)); 

stimPulseDuration_nsp1(:) = {stimParameters.stimPulseDuration};
responseTime_nsp1(:) = {response_time};
stimFile_nsp1(:) = {stim_file};
hed_nsp1(:) = {HED};
stimFrequency_nsp1(:) = {stimParameters.stimFrequency};
stimCurrent_nsp1(:) = {stimParameters.stimCurrent};
stim_type_nsp1(:) = {stimParameters.stim_type{2}}; 

% nsp2
stimPulseDuration_nsp2 = cell(size(stimTime_nsp2));
responseTime_nsp2 = cell(size(stimTime_nsp2));
stimFile_nsp2 = cell(size(stimTime_nsp2));
hed_nsp2 = cell(size(stimTime_nsp2));
stimFrequency_nsp2 = cell(size(stimTime_nsp2));
stimCurrent_nsp2 = cell(size(stimTime_nsp2));
stim_type_nsp2 = cell(size(stimTime_nsp2)); 

stimPulseDuration_nsp2(:) = {stimParameters.stimPulseDuration};
responseTime_nsp2(:) = {response_time};
stimFile_nsp2(:) = {stim_file};
hed_nsp2(:) = {HED};
stimFrequency_nsp2(:) = {stimParameters.stimFrequency};
stimCurrent_nsp2(:) = {stimParameters.stimCurrent};
stim_type_nsp2(:) = {stimParameters.stim_type{2}}; 

%% done, just save tsv file! :)  
varNames = {'onset','duration','electrical_stimulation_trial_type','response_time','stim_file','HED',...
    'electrical_stimulation_StimOnset_sec','electrical_stimulation_StimOffset_sec','electrical_stimulation_Frequency_Hz',...
    'electrical_stimulation_Current_mA','electrical_stimulation_site','electrical_stimulation_type',...
    'electrical_stimulation_Channel1Stim','electrical_stimulation_Channel1StimNSP',...
    'electrical_stimulation_Channel2Stim','electrical_stimulation_Channel2StimNSP'};
    
table_eventsTSV_nsp1 = table(stimTime_nsp1,stimPulseDuration_nsp1,stimTrialType_nsp1,responseTime_nsp1,stimFile_nsp1,hed_nsp1,...
    stimTime_nsp1,stimTime_nsp1,stimFrequency_nsp1,stimCurrent_nsp1,stimBipolarSites_nsp1(:,1),stim_type_nsp1,...
    stimBipolarSites_nsp1(:,2),stimBipolarSites_nsp1(:,3),stimBipolarSites_nsp1(:,4),stimBipolarSites_nsp1(:,5),...
    'VariableNames', varNames);   

writetable(table_eventsTSV_nsp1, filename_eventsTSV_nsp1, 'FileType', 'text', 'Delimiter', '\t');

if ~isempty(stimTime_nsp2)
    table_eventsTSV_nsp2 = table(stimTime_nsp2,stimPulseDuration_nsp2,stimTrialType_nsp2,responseTime_nsp2,stimFile_nsp2,hed_nsp2,...
    stimTime_nsp2,stimTime_nsp2,stimFrequency_nsp2,stimCurrent_nsp2,stimBipolarSites_nsp2(:,1),stim_type_nsp2,...
    stimBipolarSites_nsp2(:,2),stimBipolarSites_nsp2(:,3),stimBipolarSites_nsp2(:,4),stimBipolarSites_nsp2(:,5),...
    'VariableNames', varNames); 

    writetable(table_eventsTSV_nsp2, filename_eventsTSV_nsp2, 'FileType', 'text', 'Delimiter', '\t');
end



end