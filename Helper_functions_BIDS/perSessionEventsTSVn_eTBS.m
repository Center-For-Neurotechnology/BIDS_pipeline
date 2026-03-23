function perSessionEventsTSVn_eTBS(directoryBIDS,sub_XXXX,taskName,ieeg_run,foldername_neuralynx,stimParameters,channInfo,logFileDirectory,hdrn,stimChNames,posFixNCS,filename_chanListEMU,startNSxSec,endNSxSec)
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

%% for eTBS
dataDirectory = logFileDirectory;
stimLogFile = get_eTBSMatrix(dataDirectory);

stimLogChannels = stimLogFile(:,2:3); % works for single site (2 channels) stim, would need labels to differentiate between single and multi-site stim?
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

% cerstim to neuralynx transform
% % below lines were addded for debugging
% channInfo.bankInfo.bankA = 33:64; % Which Neuralynx channels correspond to each Cerestim bank [cerestim bank->neuralynx channel]
% channInfo.bankInfo.bankB = 65:96;
% channInfo.bankInfo.bankC = 129:160;

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
for i = 1:size(cerestimChsInNeuralynxChs,1)
%     if stimLogChannelsNSP(i,1) <= 128 % have the stim channel numbers, sorting into nsp1 or nsp2 file % nsp doesn't matter anymore
        stim_ch1 = chanListEMU(cerestimChsInNeuralynxChs(i,1)); % ch name string % instead of hdrn.label, use the xcel ch list
%         stimBipolarSites{i,3} = 1;
%     else
%         stim_ch1 = hdrNS3_nsp2.hdr.label(stimLogChannelsNSP(i,1)-128);
%         stimBipolarSites{i,3} = 2;
%     end
%     if stimLogChannelsNSP(i,2) <= 128
        stim_ch2 = chanListEMU(cerestimChsInNeuralynxChs(i,2)); % stim channels can be in different nsps
%         stimBipolarSites{i,5} = 1;
%     else
%         stim_ch2 = hdrNS3_nsp2.hdr.label(stimLogChannelsNSP(i,2)-128);
%         stimBipolarSites{i,5} = 2;
%     end
    stimBipolarSites{i,1} = join([stim_ch1 stim_ch2],'-');
    stimBipolarSites{i,2} = cerestimChsInNeuralynxChs(i,1); % stim_ch1 number;
    stimBipolarSites{i,3} = cerestimChsInNeuralynxChs(i,2); % stim_ch2 number;
end

% creating 'electrical_stimulation_trial_type' from existing variables
% 'Bipolar Single Pulse stim, channels: LTB_10-LTB_11, current: 7 mA, stimulation duration: 0.233 ms, frequency: 0 Hz'
% stimTrialType = {};
% part1 = join(string([stimParameters.stim_type{1},'Single Pulse stim']),' ');
% part3 = join(string(['current:', string(stimParameters.stimCurrent), 'mA']),' ');
% part4 = join(string(['stimulation duration:', string(stimParameters.stimPulseDuration), 'ms']),' ');
% part5 = join(string(['frequency:', string(stimParameters.stimFrequency), 'Hz']),' ');
% 
% for i = 1:size(stimBipolarSites,1) % both onset_sec and stimBipolarSites should be the same length/size
%     part2 = join(['channels:', stimBipolarSites{i}],' ');
%     stimTrialType{i,1} = join([part1,part2,part3,part4,part5],', ');    
% end


%% Get stim info

% read stim AINP data to create epochs
[filepath,~,~] = fileparts(foldername_neuralynx);
ncsFileName = filepath; %,'\',stimChNames{i},posFixNCS,'.ncs'];
[stimData,chNumberSTIM, chNamesSTIM, hdrStim] =  readCSCfiles(ncsFileName, stimChNames, posFixNCS, 0); % it is NEGATIVE!
% we might need to accomodate differnt sampling rates!
if hdrStim.Fs ~= hdrn.Fs 
    stimData = downsample(stimData, round(hdrStim.Fs / hdrn.Fs)); % assuming multiples! - no need for LP filtering because this is only to get stim timing
end


if isempty(startNSxSec), startNSxSec=0; end
if isempty(endNSxSec), endNSxSec=size(stimData,1)/hdrn.Fs; end
indSamplesOfInterest = round(startNSxSec*hdrn.Fs+1): min(round(endNSxSec*hdrn.Fs),size(stimData,1));
indSamplesOfInterestStim = intersect(indSamplesOfInterest, 1:length(stimData));
dataStim{1} = abs(stimData(indSamplesOfInterestStim))';
%dataStim{1} = abs(stimData)';

thPulse = min(10, max([dataStim{1}])/3); % 1/3 of the max or 300mV DIFF

indTimeAllSTIMPulses = find(abs(diff([mean([dataStim{1}]) dataStim{1}])) >= thPulse); % Find all STIM pulses

% Detect pulses on analog inputs from NSP data
minDistSTIMPulses = 1000; % 25ms minimum distance between pulse - to aviod several hits
if length(minDistSTIMPulses)>=1 && minDistSTIMPulses(1)>0
    indRepeatedPulses = find(diff([ 0 indTimeAllSTIMPulses])< minDistSTIMPulses(1));
    indTimeAllSTIMPulses(indRepeatedPulses) = [];% Get only first point of the pulse or train - remove subsequent points
end

% indTimeAllSTIMPulses = indTimeAllSTIMPulses(1:size(stimLogChannels,1));

indTimeAllSTIM = indTimeAllSTIMPulses;
hdrn.hdrStim = hdrStim;
hdrn.stimFs = hdrStim.Fs;
hdrn.stimChNumber = chNumberSTIM;
hdrn.stimChName = chNamesSTIM;
% % 
% % dirNeuraLynxData = [ncsFileName,filesep,stimChNames,'.nsc'];
% % selChNames = hdrn.label{1:4}
% % selBipolar = '';
% % minDistSTIMPulses = 50; 
% % [~, ~, dataStim, indTimeAllSTIM, ~, ~, ~, hdr] = GetBipolarEEGFromNeuralynx(ncsFileName, posFixNCS, selChNames, selBipolar, stimChNames, 0, [], minDistSTIMPulses);



%% Get stim pulse start and end time
% new stim arrays
stimTimeON = indTimeAllSTIM;

% stimIndStart 

% adding stim index to per nsp arrays
% for i = 1:size(stimLogNSPs,1)
%     stimTimeON_nsp1(i,1) = indTimeSTIMPerFile{1,1}(i);
% end

stimTimeON = stimTimeON'/hdrn.Fs; % converting time from index number to seconds (sec = index/sampling rate)

nStim = min(length(stimTimeON), size(stimLogFile,1));
stimTimeON  = stimTimeON(1:nStim);
stimDuration = stimLogFile(1:nStim,10) / 1e6;   % convert µs → s
stimTimeOFF = stimTimeON + stimDuration;
% stimTimeOFF = stimTimeON+(stimLogFile(:,10)/10^6);  % so units are in s


%% set up table vars    
% creating cells for table()
trainLength = cell(size(stimLogChannels,1),1);
responseTime = cell(size(stimLogChannels,1),1);
stimFile = cell(size(stimLogChannels,1),1);
hed = cell(size(stimLogChannels,1),1);
stimFrequency = cell(size(stimLogChannels,1),1);
stimCurrent = cell(size(stimLogChannels,1),1);
stim_type = cell(size(stimLogChannels,1),1); 

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
stimFrequency = num2cell(stimLogFile(:,7));
stimCurrent = num2cell(stimLogFile(:,5));
stim_type(:) = {'Biphasic'}; 

electrical_stimulation_type(:) = {'Biphasic'}; 
trial_num = num2cell(stimLogFile(:,1));
n_pulses = num2cell(stimLogFile(:,11));
pulse_width_us = num2cell(stimLogFile(:,6));
trainLength = num2cell(stimLogFile(:,10)/1000); % so in ms
n_bursts = num2cell(stimLogFile(:,13));
sampling_rate_Hz(:) = {hdrn.Fs};


%% create tables and save tsv files
% varNames = {'onset_sec','duration_ms','electrical_stimulation_trial_type','response_time','stim_file','HED',...
%     'electrical_stimulation_StimOnset_sec','electrical_stimulation_StimOffset_sec','electrical_stimulation_Frequency_Hz',...
%     'electrical_stimulation_Current_mA','electrical_stimulation_site','electrical_stimulation_type',...
%     'electrical_stimulation_Channel1Stim','electrical_stimulation_Channel2Stim'};


 varNames = {'StimOnset_sec','StimOffset_sec','trainLength_ms','electrical_stimulation_type',...
    'trial','n_pulses', 'pulse_width_us','electrical_stimulation_Frequency_Hz','electrical_stimulation_Current_mA','electrical_stimulation_site',...
    'electrical_stimulation_Channel1Stim','electrical_stimulation_Channel2Stim', 'n_bursts', 'sampling_rate_Hz'};

table_eventsTSV = table(stimTimeON,stimTimeOFF,trainLength, stim_type, ...
    trial_num, n_pulses, pulse_width_us, stimFrequency, stimCurrent, stimBipolarSites(:,1), ...
    stimBipolarSites(:,2),stimBipolarSites(:,3), n_bursts, sampling_rate_Hz, 'VariableNames', varNames);
   
%  table_eventsTSV = table(stimTimeON,stimPulseDuration,stimTrialType,responseTime,stimFile,hed,...
%     stimTimeON,stimTimeOFF,stimFrequency,stimCurrent,stimBipolarSites(:,1),stim_type,...
%     stimBipolarSites(:,2),stimBipolarSites(:,3),'VariableNames', varNames); 
writetable(table_eventsTSV, filename_eventsTSV, 'FileType', 'text', 'Delimiter', '\t');



end