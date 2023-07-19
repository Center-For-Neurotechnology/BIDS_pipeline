function perSessionEventsTSV(directoryBIDS,sub_XXXX,taskName,ieeg_run,filenameNSx_nsp1,filenameNSx_nsp2,stimParameters,channInfo,fileNameStimSites,hdrNS3_nsp1,hdrNS3_nsp2)
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
filename_eventsTSV_nsp2 = [directoryBIDS,'/',sub_XXXX,'/ses-postimp/ieeg/',sub_XXXX,'_ses-postimp_task-',...
    taskName,'RAWNSP2_run-',ieeg_run,'_events.tsv'];

%% n/a values
response_time = 'n/a';
stim_file = 'n/a';
HED = 'n/a';

%% map cerestim channels to nsp numbers and channel numbers
% setting up cerestim bank info
cerestimAllBanks = [channInfo.bankInfo.bankANSP; channInfo.bankInfo.bankBNSP; channInfo.bankInfo.bankCNSP];
stimLogChannels = load(fileNameStimSites);
stimLogChannels = stimLogChannels.stimchans(:,1:2); % works for single site (2 channels) stim
stimLogNSPs = [];
stimLogChannelsNSP = [];

% accounting for cerestim and nsp channel offsets and nsp2 = nsp1 + 128
for i = 1:size(stimLogChannels,1)
    for j = 1:size(stimLogChannels,2)
        if stimLogChannels(i,j) <= channInfo.bankInfo.bankA(end) % smallest 32 cerestim channels are connected to Bank 1 
            stimLogNSPs(i,j) = cerestimAllBanks(1);
            stimLogChannelsNSP(i,j) = stimLogChannels(i,j)+128*(cerestimAllBanks(1)==2) + channInfo.bankInfo.bankA(1)-1; % if NSP2, channel number needs +128
        elseif stimLogChannels(i,j) <= channInfo.bankInfo.bankB(end) % next 32 smallest cerestim channels are connected to Bank 2 
            stimLogNSPs(i,j) = cerestimAllBanks(2);
            stimLogChannelsNSP(i,j) = stimLogChannels(i,j)+128*(cerestimAllBanks(2)==2) + channInfo.bankInfo.bankB(1)-1-32;
        else 
            stimLogNSPs(i,j) = cerestimAllBanks(3); % last 32 cerestim channels are connected to Bank 3 
            stimLogChannelsNSP(i,j) = stimLogChannels(i,j)+128*(cerestimAllBanks(3)==2) + channInfo.bankInfo.bankC(1)-1-64;
        end 
    end
end

%%
% getting the stim site channels
stimBipolarSites = {}; % saving stim channel info: {chName1-chName2, chNumber1, ch1NSP, chNumber2 ch2NSP}
for i = 1:size(stimLogChannelsNSP,1)
    if stimLogChannelsNSP(i,1) <= 128 % have the stim channel numbers, sorting into nsp1 or nsp2 file
        stim_ch1 = hdrNS3_nsp1.hdr.label(stimLogChannelsNSP(i,1));
        stimBipolarSites{i,3} = 1;
    else
        stim_ch1 = hdrNS3_nsp2.hdr.label(stimLogChannelsNSP(i,1)-128);
        stimBipolarSites{i,3} = 2;
    end
    if stimLogChannelsNSP(i,2) <= 128
        stim_ch2 = hdrNS3_nsp1.hdr.label(stimLogChannelsNSP(i,2)); % stim channels can be in different nsps
        stimBipolarSites{i,5} = 1;
    else
        stim_ch2 = hdrNS3_nsp2.hdr.label(stimLogChannelsNSP(i,2)-128);
        stimBipolarSites{i,5} = 2;
    end
    stimBipolarSites{i,1} = join([stim_ch1 stim_ch2],'-'); % sorting stim event into channel 1's nsp file
    stimBipolarSites{i,2} = stimLogChannelsNSP(i,1); % stim_ch1;
    stimBipolarSites{i,4} = stimLogChannelsNSP(i,2); % stim_ch2;
end

% creating 'electrical_stimulation_trial_type' from existing variables
% 'Bipolar Single Pulse stim, channels: LTB_10-LTB_11, current: 7 mA, stimulation duration: 0.233 ms, frequency: 0 Hz'
stimTrialType = {};
part1 = join([stimParameters.stim_type{1},"Single Pulse stim"],' ');
part3 = join(["current:", string(stimParameters.stimCurrent), 'mA'],' ');
part4 = join(["stimulation duration:", string(stimParameters.stimPulseDuration), 'ms'],' ');
part5 = join(["frequency:", string(stimParameters.stimFrequency), 'Hz'],' ');

for i = 1:size(stimBipolarSites,1) % both onset_sec and stimBipolarSites should be the same length/size
    part2 = join(["channels:", stimBipolarSites{i}],' ');
    stimTrialType{i,1} = join([part1,part2,part3,part4,part5],', ');    
end


%% get stim times
fileNameNSxPerNSP{1} = filenameNSx_nsp1;
fileNameNSxPerNSP{2} = filenameNSx_nsp2;
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
stimAINPChNames = {'SYNC'}; % 'SYNC','ainp6', 'ainp7'}; % all stim, random stim (random stim is for CLoSES), detected stim
 
% Find channel names
channInfo = findChannelNamesInNSX(channInfo, [], fileNameNSxPerNSP); 
titName = 'bids';

% returns the index for stim at each nsp
[~,~,~,indTimeSTIMPerFile] = scriptCheckStimInNSXBIDS(fileNameNSxPerNSP, fileNameStimSites, dirResults, stimAINPChNames, channInfo,titName, timeInfo.startNSxSec, timeInfo.endNSxSec);

%% Sort stim event times into nsp1 or nsp2 file
% new stim arrays
stimTime_nsp1 = [];
stimTime_nsp2 = [];

% adding stim index to per nsp arrays
for i = 1:size(stimLogNSPs,1)
    stimTime_nsp1(i,1) = indTimeSTIMPerFile{1,1}(i);
    stimTime_nsp2(i,1) = indTimeSTIMPerFile{1,2}(i);    
end

stimTime_nsp1 = stimTime_nsp1/hdrNS3_nsp1.hdr.Fs{1}; % converting time from index number to seconds (sec = index/sampling rate)
stimTime_nsp2 = stimTime_nsp2/hdrNS3_nsp2.hdr.Fs{1};

%% set up table vars    
% creating cells for table()
stimPulseDuration = cell(size(stimLogNSPs,1),1);
responseTime = cell(size(stimLogNSPs,1),1);
stimFile = cell(size(stimLogNSPs,1),1);
hed = cell(size(stimLogNSPs,1),1);
stimFrequency = cell(size(stimLogNSPs,1),1);
stimCurrent = cell(size(stimLogNSPs,1),1);
stim_type = cell(size(stimLogNSPs,1),1); 

% filling cells with existing variables
stimPulseDuration(:) = {stimParameters.stimPulseDuration};
responseTime(:) = {response_time};
stimFile(:) = {stim_file};
hed(:) = {HED};
stimFrequency(:) = {stimParameters.stimFrequency};
stimCurrent(:) = {stimParameters.stimCurrent};
stim_type(:) = {stimParameters.stim_type{2}}; 


%% create tables and save tsv files
varNames = {'onset','duration','electrical_stimulation_trial_type','response_time','stim_file','HED',...
    'electrical_stimulation_StimOnset_sec','electrical_stimulation_StimOffset_sec','electrical_stimulation_Frequency_Hz',...
    'electrical_stimulation_Current_mA','electrical_stimulation_site','electrical_stimulation_type',...
    'electrical_stimulation_Channel1Stim','electrical_stimulation_Channel1StimNSP',...
    'electrical_stimulation_Channel2Stim','electrical_stimulation_Channel2StimNSP'};

if ~isempty(stimTime_nsp1) % avoid saving an empty file if there were no stim events in that nsp
    table_eventsTSV_nsp1 = table(stimTime_nsp1,stimPulseDuration,stimTrialType,responseTime,stimFile,hed,...
        stimTime_nsp1,stimTime_nsp1,stimFrequency,stimCurrent,stimBipolarSites(:,1),stim_type,...
        stimBipolarSites(:,2),stimBipolarSites(:,3),stimBipolarSites(:,4),stimBipolarSites(:,5),...
        'VariableNames', varNames); 
    writetable(table_eventsTSV_nsp1, filename_eventsTSV_nsp1, 'FileType', 'text', 'Delimiter', '\t');
end

if ~isempty(stimTime_nsp2)
    table_eventsTSV_nsp2 = table(stimTime_nsp2,stimPulseDuration,stimTrialType,responseTime,stimFile,hed,...
        stimTime_nsp2,stimTime_nsp2,stimFrequency,stimCurrent,stimBipolarSites(:,1),stim_type,...
        stimBipolarSites(:,2),stimBipolarSites(:,3),stimBipolarSites(:,4),stimBipolarSites(:,5),...
        'VariableNames', varNames); 
    writetable(table_eventsTSV_nsp2, filename_eventsTSV_nsp2, 'FileType', 'text', 'Delimiter', '\t');
end

end