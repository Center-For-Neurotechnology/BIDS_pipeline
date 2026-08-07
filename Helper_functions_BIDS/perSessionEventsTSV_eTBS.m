function perSessionEventsTSV_eTBS(directoryBIDS,sub_XXXX,taskName,ieeg_run,filenameNSx_nsp1,filenameNSx_nsp2,stimParameters,channInfo,logFileDirectory,hdrNS3_nsp1,hdrNS3_nsp2)
% This function is run once for each session. It creates a tsv containing 
% electrical stimulation events and parameters. 
% The file will be saved in directoryBIDS\sub_XXXX\ses-postimp\ieeg\
% and have the name sub-XXXX_ses-postimp_task-NetworkWake1RAWNSP1_run-01_events.tsv
% INPUTS:
%   - directoryBIDS: string of the main folder where the BIDS data is being saved
%   - sub_XXXX: string of the deidentified patient ID
%   - taskName: string of the session task name
%   - ieeg_run: string of the session order
%   - filenameNS3_nsp1: string of the NSP1 .ns3 filename (full path)
%   - filenameNS3_nsp2: string of the NSP2 .ns3 filename (full path)
%   - stimParameters: structure containing pulse duration,
%       frequency, current, and stimulation type
%   - channInfo: structure containing information about cerestim-nsp
%       connection configuration
%   - fileNameStimSites: string of .mat file name (full path) containing
%       containing the stimulation channels for each event
%   - hdrNS3_nsp1: structure created by perSessionChannelsTSV() containing NSP1 .ns3 headers 
%   - hdrNS3_nsp2: structure created by perSessionChannelsTSV() containing NSP2 .ns3 headers 
% OUTPUTS: 
%   - sub-XXXX_ses-postimp_task-NetworkWake1RAWNSP1_run-01_events.tsv

%% file names of the saved .tsv files
% sub_XXXX\ses-postimp\ieeg\sub-XXXX_ses-postimp_task-NetworkWake1RAWNSP1_run-01_events.tsv
filename_eventsTSV_nsp1 = [directoryBIDS,'/',sub_XXXX,'/ses-postimp/ieeg/',sub_XXXX,'_ses-postimp_task-',...
    taskName,'RAWNSP1_run-',ieeg_run,'_events.tsv'];
if ~isempty(filenameNSx_nsp2)
    filename_eventsTSV_nsp2 = [directoryBIDS,'/',sub_XXXX,'/ses-postimp/ieeg/',sub_XXXX,'_ses-postimp_task-',...
        taskName,'RAWNSP2_run-',ieeg_run,'_events.tsv'];
end

%% n/a values
response_time = 'n/a';
stim_file = 'n/a';
HED = 'n/a';

%% map cerestim channels to nsp numbers and channel numbers
% setting up cerestim bank info
cerestimAllBanks = [channInfo.bankInfo.bankANSP; channInfo.bankInfo.bankBNSP; channInfo.bankInfo.bankCNSP];
dataDirectory = logFileDirectory;
stimLogFile = get_eTBSMatrix(dataDirectory);
stimLogStruct = struct();
stimLogStruct.data = stimLogFile;
save(fullfile(dataDirectory, 'stimLogFile.mat'), 'stimLogStruct', '-v7.3');
stimLogChannels = stimLogFile(:,2:3); % works for single site (2 channels) stim
stimLogNSPs = [];
stimLogChannelsNSP = [];

% accounting for cerestim and nsp channel offsets and nsp2 = nsp1 + 128
for i = 1:size(stimLogChannels,1)
    for j = 1:size(stimLogChannels,2)
        if stimLogChannels(i,j) <= 32 %channInfo.bankInfo.bankA(end) % smallest 32 cerestim channels are connected to Bank 1 
            stimLogNSPs(i,j) = cerestimAllBanks(1);
            stimLogChannelsNSP(i,j) = stimLogChannels(i,j)+128*(cerestimAllBanks(1)==2) + channInfo.bankInfo.bankA(1)-1; % if NSP2, channel number needs +128
        elseif stimLogChannels(i,j) <= 64 %channInfo.bankInfo.bankB(end) % next 32 smallest cerestim channels are connected to Bank 2 
            stimLogNSPs(i,j) = cerestimAllBanks(2);
            stimLogChannelsNSP(i,j) = stimLogChannels(i,j)+128*(cerestimAllBanks(2)==2) + channInfo.bankInfo.bankB(1)-1-32;
        else 
            stimLogNSPs(i,j) = cerestimAllBanks(3); % last 32 cerestim channels are connected to Bank 3 
            stimLogChannelsNSP(i,j) = stimLogChannels(i,j)+128*(cerestimAllBanks(3)==2) + channInfo.bankInfo.bankC(1)-1-64;
        end 
    end
end

%% TODO: ensure the stim channel names and numbers still align after removing scalp channels from hdrNS3_nsp1/2
% getting the stim site channels
stimBipolarSites = {}; % saving stim channel info: {chName1-chName2, chNumber1, ch1NSP, chNumber2 ch2NSP}
for i = 1:size(stimLogChannelsNSP,1)
    if stimLogChannelsNSP(i,1) <= 128 % have the stim channel numbers, sorting into nsp1 or nsp2 file
        stim_ch1 = hdrNS3_nsp1.hdr.label{stimLogChannelsNSP(i,1)};
        stimBipolarSites{i,3} = 1;
    else
        stim_ch1 = hdrNS3_nsp2.hdr.label{stimLogChannelsNSP(i,1)-128};
        stimBipolarSites{i,3} = 2;
    end
    if stimLogChannelsNSP(i,2) <= 128
        stim_ch2 = hdrNS3_nsp1.hdr.label{stimLogChannelsNSP(i,2)}; % stim channels can be in different nsps
        stimBipolarSites{i,5} = 1;
    else
        stim_ch2 = hdrNS3_nsp2.hdr.label{stimLogChannelsNSP(i,2)-128};
        stimBipolarSites{i,5} = 2;
    end
    stimBipolarSites{i,1} = sprintf('%s-%s', stim_ch1, stim_ch2); % sorting stim event into channel 1's nsp file
    stimBipolarSites{i,2} = stimLogChannelsNSP(i,1); % stim_ch1;
    stimBipolarSites{i,4} = stimLogChannelsNSP(i,2); % stim_ch2;
end

% % creating 'electrical_stimulation_trial_type' from existing variables
% % 'Bipolar Single Pulse stim, channels: LTB_10-LTB_11, current: 7 mA, stimulation duration: 0.233 ms, frequency: 0 Hz'
% stimTrialType = {};
% part1 = join([stimParameters.stim_type{1},"Single Pulse stim"],' ');
% part3 = join(["current:", string(stimParameters.stimCurrent), 'mA'],' ');
% part4 = join(["stimulation duration:", string(stimParameters.stimPulseDuration), 'ms'],' ');
% part5 = join(["frequency:", string(stimParameters.stimFrequency), 'Hz'],' ');
% 
% for i = 1:size(stimBipolarSites,1) % both onset_sec and stimBipolarSites should be the same length/size
%     part2 = join(["channels:", stimBipolarSites{i}],' ');
%     stimTrialType{i,1} = join([part1,part2,part3,part4,part5],', ');    
% end
% % Thalamic Matrix
% stimTrialType = {};
% part1 = join([stimParameters.stim_type{1},"Single Pulse stim"],' ');
% 
% 
% for i = 1:size(stimBipolarSites,1) % both onset_sec and stimBipolarSites should be the same length/size
%     part2 = join(["channels:", stimBipolarSites{i}],' ');
%     part3 = "current: " + string(stimMatrix(i,5)) + " mA";
%     part4 = "stimulation duration:" + string(stimMatrix(i,6)) + "ms";
%     part5 = "frequency:" + string(stimMatrix(i,6)) +  "Hz";
%     stimTrialType{i,1} = join([part1,part2,part3,part4,part5],', ');    
% end


%% get stim times
fileNameNSxPerNSP{1} = filenameNSx_nsp1;
if ~isempty(filenameNSx_nsp2)
    fileNameNSxPerNSP{2} = filenameNSx_nsp2;
end
stimChNumber = unique(stimLogChannels,'rows','stable')'; 

% STIMULATION CHANNELS
nStim = size(stimChNumber,2);        
channInfo.pName = sub_XXXX;
channInfo.stimChNumber = stimChNumber;  % the Cerestim number (1) - from the mat file
channInfo.useBipolar =1;    
channInfo.chNamesToExcludeInput = {};

% Time - % should already be trimmed with nsxFileClipping.m, using full ns3 files
timeInfo.startNSxSec= 0; 
timeInfo.endNSxSec = []; 

dirResults = '';
%AINP STIM Channel
stimAINPChNames = {'SYNC9'};%SEND STIM'}; % 'SYNC','ainp6', 'ainp7'}; % all stim, random stim (random stim is for CLoSES), detected stim
 
% Find channel names
channInfo = findChannelNamesInNSxBIDS(channInfo, [], fileNameNSxPerNSP); 
titName = 'bids';

% channInfo.isStimInAINP=0;
% returns the index for stim at each nsp
[~,~,~,indTimeSTIMPerFile] = scriptCheckStimInNSXBIDS_eTBS(fileNameNSxPerNSP,dataDirectory, stimLogFile, dirResults, stimAINPChNames, channInfo,titName, timeInfo.startNSxSec, timeInfo.endNSxSec);

%% Sort stim event times into nsp1 or nsp2 file
% new stim arrays
% new stim arrays
stimTimeON_nsp1 = [];
stimTimeON_nsp2 = [];

% how many stims did each NSP actually detect
nStimTXT   = size(stimLogNSPs,1);                 % log count
nStimNSP1  = numel(indTimeSTIMPerFile{1,1});
hasStimNsp1 = nStimNSP1 > 0;

if ~isempty(filenameNSx_nsp2)
    nStimNSP2   = numel(indTimeSTIMPerFile{1,2});
    hasStimNsp2 = nStimNSP2 > 0;
else
    nStimNSP2   = 0;
    hasStimNsp2 = false;
end

% cap the log count by whichever NSP(s) actually recorded stim (ignore a 0-pulse NSP)
detectedCounts = [];
if hasStimNsp1, detectedCounts(end+1) = nStimNSP1; end
if hasStimNsp2, detectedCounts(end+1) = nStimNSP2; end
nStim = min([nStimTXT, detectedCounts]);

% fill per-NSP onset index arrays (only for NSPs that have stim)
if hasStimNsp1, stimTimeON_nsp1 = zeros(nStim,1); end
if hasStimNsp2, stimTimeON_nsp2 = zeros(nStim,1); end
for i = 1:nStim
    if hasStimNsp1, stimTimeON_nsp1(i) = indTimeSTIMPerFile{1,1}(i); end
    if hasStimNsp2, stimTimeON_nsp2(i) = indTimeSTIMPerFile{1,2}(i); end
end

% convert index -> seconds, then compute OFF = ON + pulse duration
if hasStimNsp1
    stimTimeON_nsp1  = stimTimeON_nsp1 / hdrNS3_nsp1.hdr.Fs{1};
    stimTimeOFF_nsp1 = stimTimeON_nsp1 + stimParameters.stimPulseDuration;
end
if hasStimNsp2
    stimTimeON_nsp2  = stimTimeON_nsp2 / hdrNS3_nsp2.hdr.Fs{1};
    stimTimeOFF_nsp2 = stimTimeON_nsp2 + stimParameters.stimPulseDuration;
end

%% set up table vars    
% creating cells for table()
trainLength = cell(size(stimLogChannels,1),1);
responseTime = cell(size(stimLogChannels,1),1);
stimFile = cell(size(stimLogChannels,1),1);
hed = cell(size(stimLogChannels,1),1);
stimFrequency = cell(size(stimLogChannels,1),1);
stimCurrent = cell(size(stimLogChannels,1),1);
stim_type = {'Biphasic'}; 

electrical_stimulation_type = cell(size(stimLogChannels,1),1); 
trial_num = cell(size(stimLogChannels,1),1);
n_pulses = cell(size(stimLogChannels,1),1);
pulse_width_us = cell(size(stimLogChannels,1),1);
sampling_rate_Hz = cell(size(stimLogChannels,1),1);
n_bursts = cell(size(stimLogChannels,1),1);

% filling cells with existing variables
% responseTime(:) = {response_time};
% stimFile(:) = {stim_file};
% hed(:) = {HED};
stimFrequency = num2cell(stimLogFile(:,7)); %50Hz|200Hz|100Hz
stimCurrent = num2cell(stimLogFile(:,5)); %4mA|7mA|2mA
stim_type = repmat({'Biphasic'}, nStim, 1);
electrical_stimulation_type = repmat({'Biphasic'}, nStim, 1);
trial_num = num2cell(stimLogFile(:,1));
n_pulses = num2cell(stimLogFile(:,11));
pulse_width_us = num2cell(stimLogFile(:,6));
trainLength = num2cell(stimLogFile(:,10)/1000); % so in ms
n_bursts = num2cell(stimLogFile(:,13));
sampling_rate_Hz_1 = repmat({'2000'}, nStim, 1);
sampling_rate_Hz_2 = repmat({'2000'}, nStim, 1);


%% create tables and save tsv files
% varNames = {'onset_sec','duration_ms','electrical_stimulation_trial_type','response_time','stim_file','HED',...
%     'electrical_stimulation_StimOnset_sec','electrical_stimulation_StimOffset_sec','electrical_stimulation_Frequency_Hz',...
%     'electrical_stimulation_Current_mA','electrical_stimulation_site','electrical_stimulation_type',...
%     'electrical_stimulation_Channel1Stim','electrical_stimulation_Channel1StimNSP',...
%     'electrical_stimulation_Channel2Stim','electrical_stimulation_Channel2StimNSP'};

 varNames = {'StimOnset_sec','StimOffset_sec','trainLength_ms','electrical_stimulation_type',...
    'trial','n_pulses', 'pulse_width_us','electrical_stimulation_Frequency_Hz','electrical_stimulation_Current_mA','electrical_stimulation_site',...
    'electrical_stimulation_Channel1Stim','electrical_stimulation_Channel2Stim', 'n_bursts', 'sampling_rate_Hz'};


if ~isempty(stimTimeON_nsp1) % avoid saving an empty file if there were no stim events in that nsp
    table_eventsTSV_nsp1 = table(stimTimeON_nsp1,stimTimeOFF_nsp1,trainLength, stim_type, ...
    trial_num, n_pulses, pulse_width_us, stimFrequency, stimCurrent, stimBipolarSites(:,1), ...
    stimBipolarSites(:,2),stimBipolarSites(:,3), n_bursts, sampling_rate_Hz_1, 'VariableNames', varNames);
    writetable(table_eventsTSV_nsp1, filename_eventsTSV_nsp1, 'FileType', 'text', 'Delimiter', '\t');
end

if ~isempty(filenameNSx_nsp2)
    table_eventsTSV_nsp2 = table(stimTimeON_nsp2,stimTimeOFF_nsp2,trainLength, stim_type, ...
    trial_num, n_pulses, pulse_width_us, stimFrequency, stimCurrent, stimBipolarSites(:,1), ...
    stimBipolarSites(:,2),stimBipolarSites(:,3), n_bursts, sampling_rate_Hz_2, 'VariableNames', varNames);
    writetable(table_eventsTSV_nsp2, filename_eventsTSV_nsp2, 'FileType', 'text', 'Delimiter', '\t');
end

end