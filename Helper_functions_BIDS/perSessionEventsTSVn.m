function perSessionEventsTSVn(directoryBIDS,sub_XXXX,taskName,ieeg_run,foldername_neuralynx,stimParameters,channInfo,fileNameStimSites,hdrn,stimChNames,posFixNCS,filename_chanListEMU,startNSxSec,endNSxSec)
% This function is run once for each session. It creates a tsv containing 
% electrical stimulation events and parameters. 
% The file will be saved in directoryBIDS\sub_XXXX\ses-postimp\ieeg\
% and have the name sub-XXXX_ses-postimp_task-NetworkWake1RAWNSP1_run-01_events.tsv
% INPUTS:
%   - directoryBIDS: string of the main folder where the BIDS data is being saved
%   - sub_XXXX: string of the deidentified patient ID
%   - taskName: string of the session task name
%   - ieeg_run: string of the session order
%   - foldername_neuralynx: string of any .nsc filename in the wanted session folder(full path)
%   - stimParameters: structure containing pulse duration,
%       frequency, current, and stimulation type
%   - channInfo: structure containing information about cerestim-nsp
%       connection configuration
%   - fileNameStimSites: string of .mat file name (full path) containing
%       containing the stimulation channels for each event
%   - hdrn: structure created by perSessionChannelsTSVn() with .nsc headers 
%   - posFixNCS: string after channel name in nsc file name (e.g. for file 'LTMb-Pul9_0017.ncs', posFixNCS = '_0017')
%
% OUTPUTS: 
%   - sub-XXXX_ses-postimp_task-NetworkWake1RAWNSP1_run-01_events.tsv

%% file names of the saved .tsv files
% sub_XXXX\ses-postimp\ieeg\sub-XXXX_ses-postimp_task-NetworkWake1RAWNSP1_run-01_events.tsv
filename_eventsTSV = [directoryBIDS,'/',sub_XXXX,'/ses-postimp/ieeg/',sub_XXXX,'_ses-postimp_task-',...
    taskName,'RAW_run-',ieeg_run,'_events.tsv'];

%% n/a values
response_time = 'n/a';
stim_file = 'n/a';
HED = 'n/a';

%% map cerestim channels to nsp numbers and channel numbers
% setting up cerestim bank info
% cerestimAllBanks = [channInfo.bankInfo.bankA_to_headbox; channInfo.bankInfo.bankBNSP; channInfo.bankInfo.bankCNSP];
stimLogChannels = load(fileNameStimSites);
stimLogChannels = stimLogChannels.stimchans(:,2:3); % works for single site (2 channels) stim, would need labels to differentiate between single and multi-site stim?
% stimLogNSPs = [];
% stimLogChannelsNSP = [];

% % accounting for cerestim and nsp channel offsets and nsp2 = nsp1 + 128
% for i = 1:size(stimLogChannels,1)
%     for j = 1:size(stimLogChannels,2)
%         if stimLogChannels(i,j) <= 32 %channInfo.bankInfo.bankA(end) % smallest 32 cerestim channels are connected to Bank 1 
%             stimLogNSPs(i,j) = cerestimAllBanks(1);
%             stimLogChannelsNSP(i,j) = stimLogChannels(i,j)+128*(cerestimAllBanks(1)==2) + channInfo.bankInfo.bankA(1)-1; % if NSP2, channel number needs +128
%         elseif stimLogChannels(i,j) <= 64 %channInfo.bankInfo.bankB(end) % next 32 smallest cerestim channels are connected to Bank 2 
%             stimLogNSPs(i,j) = cerestimAllBanks(2);
%             stimLogChannelsNSP(i,j) = stimLogChannels(i,j)+128*(cerestimAllBanks(2)==2) + channInfo.bankInfo.bankB(1)-1-32;
%         else 
%             stimLogNSPs(i,j) = cerestimAllBanks(3); % last 32 cerestim channels are connected to Bank 3 
%             stimLogChannelsNSP(i,j) = stimLogChannels(i,j)+128*(cerestimAllBanks(3)==2) + channInfo.bankInfo.bankC(1)-1-64;
%         end 
%     end
% end

% map cerestim stim channnels (from log files) to neuralynx recording channel numbers
cerestimChsInNeuralynxChs = zeros(size(stimLogChannels));


for i = 1:size(stimLogChannels,1)
    for j = 1:size(stimLogChannels,2)
        if stimLogChannels(i,j) <= 32
            cerestimChsInNeuralynxChs(i,j) = stimLogChannels(i,j) + channInfo.bankInfo.bankA(1)-1;
        elseif stimLogChannels(i,j) <= 64
            cerestimChsInNeuralynxChs(i,j) = stimLogChannels(i,j) + channInfo.bankInfo.bankB(1)-1-32;
        else
            cerestimChsInNeuralynxChs(i,j) = stimLogChannels(i,j) + channInfo.bankInfo.bankC(1)-1-64;
        end
    end
end

%% get EMU channel list (this is the order used for Cerestim channel numbers)
chanListEMU = importdata(filename_chanListEMU);
chanListEMU = chanListEMU.textdata.x2;
chanListEMU = chanListEMU(3:size(chanListEMU,1),[2,5,8,11,13,16,19,22]);
chanListEMU = reshape(chanListEMU,[],1);

%% getting the stim site channel labels
stimBipolarSites = cell(size(cerestimChsInNeuralynxChs)); % saving stim channel info: {chName1-chName2, chNumber1, ch1NSP, chNumber2 ch2NSP} don't need ind=3,5
%% build per-event bipolar site names + channel numbers
for i = 1:size(cerestimChsInNeuralynxChs,1)
    % NSP no longer matters — look up names directly from the Excel channel list
    stim_ch1 = chanListEMU{cerestimChsInNeuralynxChs(i,1)};   % braces -> the name string
    stim_ch2 = chanListEMU{cerestimChsInNeuralynxChs(i,2)};

    stimBipolarSites{i,1} = sprintf('%s-%s', stim_ch1, stim_ch2);   % 'ch1-ch2'
    stimBipolarSites{i,2} = cerestimChsInNeuralynxChs(i,1);         % stim_ch1 number
    stimBipolarSites{i,3} = cerestimChsInNeuralynxChs(i,2);         % stim_ch2 number
end

%% creating 'electrical_stimulation_trial_type'
% e.g. 'Bipolar Single Pulse stim, channels: LTB_10-LTB_11, current: 7 mA, stimulation duration: 0.233 ms, frequency: 0 Hz'
stimTrialType = {};
part1 = sprintf('%s Single Pulse stim', stimParameters.stim_type{1});
part3 = sprintf('current: %s mA', string(stimParameters.stimCurrent));
part4 = sprintf('stimulation duration: %s ms', string(stimParameters.stimPulseDuration));
part5 = sprintf('frequency: %s Hz', string(stimParameters.stimFrequency));
for i = 1:size(stimBipolarSites,1) % both onset_sec and stimBipolarSites should be the same length/size
    part2 = sprintf('channels: %s', stimBipolarSites{i,1});
    stimTrialType{i,1} = strjoin({part1,part2,part3,part4,part5}, ', ');
end

%% Get stim info


[filepath,~,~] = fileparts(foldername_neuralynx);
dirData = filepath;
minDistSTIMPulses = 50;
[~, ~, dataStim, indTimeAllSTIM, ~, ~, allChNames, hdrn] = GetBipolarEEGFromNeuralynx32(posFixNCS, '', dirData, filename_chanListEMU, [], [], stimChNames, startNSxSec, endNSxSec, minDistSTIMPulses);
% [~, ~, ~, indTimeAllSTIM,  allChNames,hdr,~] = scriptCheckStimInNeuralynx(posFixNCS, '', dirRawData, filename_chanListEMU, [], [], stimChNames, channInfo,[], startNSxSec, endNSxSec);
indTimeAllSTIM = indTimeAllSTIM{1};   % unwrap to match your old variable shape

%Cute alignment prompt
nStimLog = size(stimBipolarSites,1);       % number of stim sites/events from the logfile
nStimNSX = numel(indTimeAllSTIM);          % number of stim pulses detected in the NSX
fprintf('Number of stim from logfile: %d, Number of stim from NSX: %d\n', nStimLog, nStimNSX);
if nStimLog ~= nStimNSX
    warning('Stim count mismatch: logfile has %d, NSX detected %d (difference of %d).', ...
            nStimLog, nStimNSX, abs(nStimLog - nStimNSX));
end

%% Get stim pulse start and end time
% new stim arrays
stimTimeON = indTimeAllSTIM;

% stimIndStart 

% adding stim index to per nsp arrays
% for i = 1:size(stimLogNSPs,1)
%     stimTimeON_nsp1(i,1) = indTimeSTIMPerFile{1,1}(i);
% end

stimTimeON = stimTimeON'/hdrn.Fs; % converting time from index number to seconds (sec = index/sampling rate)
stimTimeOFF = stimTimeON+stimParameters.stimPulseDuration;


%% set up table vars    
% creating cells for table()
stimPulseDuration = cell(size(stimLogChannels,1),1);
responseTime = cell(size(stimLogChannels,1),1);
stimFile = cell(size(stimLogChannels,1),1);
hed = cell(size(stimLogChannels,1),1);
stimFrequency = cell(size(stimLogChannels,1),1);
stimCurrent = cell(size(stimLogChannels,1),1);
stim_type = cell(size(stimLogChannels,1),1); 

% filling cells with existing variables
stimPulseDuration(:) = {stimParameters.stimPulseDuration};
responseTime(:) = {response_time};
stimFile(:) = {stim_file};
hed(:) = {HED};
stimFrequency(:) = {stimParameters.stimFrequency};
stimCurrent(:) = {stimParameters.stimCurrent};
stim_type(:) = {stimParameters.stim_type{2}}; 



%% create tables and save tsv files
varNames = {'onset_sec','duration_ms','electrical_stimulation_trial_type','response_time','stim_file','HED',...
    'electrical_stimulation_StimOnset_sec','electrical_stimulation_StimOffset_sec','electrical_stimulation_Frequency_Hz',...
    'electrical_stimulation_Current_mA','electrical_stimulation_site','electrical_stimulation_type',...
    'electrical_stimulation_Channel1Stim','electrical_stimulation_Channel2Stim'};


table_eventsTSV = table(stimTimeON,stimPulseDuration,stimTrialType,responseTime,stimFile,hed,...
    stimTimeON,stimTimeOFF,stimFrequency,stimCurrent,stimBipolarSites(:,1),stim_type,...
    stimBipolarSites(:,2),stimBipolarSites(:,3),'VariableNames', varNames); 
writetable(table_eventsTSV, filename_eventsTSV, 'FileType', 'text', 'Delimiter', '\t');



end