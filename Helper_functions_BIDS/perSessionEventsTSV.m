function perSessionEventsTSV(directoryBIDS,sub_XXXX,taskName,ieeg_run,filenameNSx_nsp1,filenameNSx_nsp2,stimParameters,channInfo,fileNameStimSites,hdrNS3_nsp1,hdrNS3_nsp2, stimainp, startNSxSec, endNSxSec)
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
stStimSites = load(fileNameStimSites);
% stimLogChannels = stimLogChannels.stimchans(:,2:3); % works for single site (2 channels) stim
% stimCh1=unique(stStimSites.stimchans(:,2)); % in the new log files stimchans contains ALL the parameters information 
% stimCh2=unique(stStimSites.stimchans(:,3));
stimCh1=unique(stStimSites.stimchans(:,1)); % old log files stimchans contains only chan and trial information 
stimCh2=unique(stStimSites.stimchans(:,2));

% STIMULATION CHANNELS
nStim = length(stimCh1);
channInfo.stimChNumber(1,1:nStim) = stimCh1;    % the Cerestim number (1) - from the mat file if exists
channInfo.stimChNumber(2,1:nStim) = stimCh2;     % the Cerestim number (2)

stimLogNSPs = [];
stimLogChannelsNSP = [];


channInfo = findChannelNamesInNSX(channInfo, [], {filenameNSx_nsp1, filenameNSx_nsp2});
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
% 
% %% TODO: ensure the stim channel names and numbers still align after removing scalp channels from hdrNS3_nsp1/2
% % getting the stim site channels
% stimBipolarSites = {}; % saving stim channel info: {chName1-chName2, chNumber1, ch1NSP, chNumber2 ch2NSP}
% for i = 1:size(stimLogChannelsNSP,1)
%     if stimLogChannelsNSP(i,1) <= 128 % have the stim channel numbers, sorting into nsp1 or nsp2 file
%         stim_ch1 = hdrNS3_nsp1.hdr.label{stimLogChannelsNSP(i,1)};
%         stimBipolarSites{i,3} = 1;
%     else
%         stim_ch1 = hdrNS3_nsp2.hdr.label{stimLogChannelsNSP(i,1)-128};
%         stimBipolarSites{i,3} = 2;
%     end
%     if stimLogChannelsNSP(i,2) <= 128
%         stim_ch2 = hdrNS3_nsp1.hdr.label{stimLogChannelsNSP(i,2)}; % stim channels can be in different nsps
%         stimBipolarSites{i,5} = 1;
%     else
%         stim_ch2 = hdrNS3_nsp2.hdr.label{stimLogChannelsNSP(i,2)-128};
%         stimBipolarSites{i,5} = 2;
%     end
%     stimBipolarSites{i,1} = sprintf('%s-%s', stim_ch1, stim_ch2); % sorting stim event into channel 1's nsp file
%     stimBipolarSites{i,2} = stimLogChannelsNSP(i,1); % stim_ch1;
%     stimBipolarSites{i,4} = stimLogChannelsNSP(i,2); % stim_ch2;
% end

% % creating 'electrical_stimulation_trial_type' from existing variables
% % 'Bipolar Single Pulse stim, channels: LTB_10-LTB_11, current: 7 mA, stimulation duration: 0.233 ms, frequency: 0 Hz'
% stimTrialType = {};
% part1 = join([stimParameters.stim_type{1},"Single Pulse stim"],' ');
% part3 = join(["current:", string(stimParameters.stimCurrent), 'mA'],' ');
% part4 = join(["stimulation duration:", string(stimParameters.stimPulseDuration), 'ms'],' ');
% part5 = join(["frequency:", string(stimParameters.stimFrequency), 'Hz'],' ');
% 
% nStim = size(channInfo.stimChNames, 2);   % number of stim pairs (columns)
% for i = 1:nStim
%     pairName = sprintf('%s-%s', channInfo.stimChNames{1,i}, channInfo.stimChNames{2,i});
%     part2 = join(["channels:", pairName],' ');
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
% stimChNumber = unique(stimLogChannels,'rows','stable')'; 
% 
% % STIMULATION CHANNELS
% nStim = size(stimChNumber,2);        
channInfo.pName = sub_XXXX;
% channInfo.stimChNumber = stimChNumber;  % the Cerestim number (1) - from the mat file
% channInfo.useBipolar =1;    
channInfo.chNamesToExcludeInput = {};

% Time - % should already be trimmed with nsxFileClipping.m, using full ns3 files
timeInfo.startNSxSec= startNSxSec; 
timeInfo.endNSxSec = endNSxSec; 

dirResults = '';
%AINP STIM Channel
stimAINPChNames = stimainp;
%alignAINPChNames = stimAINPChNames;
%stimAINPChNames = {'SYNC9', 'ainp9'};%SEND STIM'}; % 'SYNC','ainp6', 'ainp7'}; % all stim, random stim (random stim is for CLoSES), detected stim
 
% Find channel names
% channInfo = findChannelNamesInNSxBIDS(channInfo, [], fileNameNSxPerNSP); 
titName = 'bids';

% channInfo.isStimInAINP=0;
% returns the index for stim at each nsp
% [~,~,~,indTimeSTIMPerFile] = scriptCheckStimInNSXBIDS(fileNameNSxPerNSP, fileNameStimSites, dirResults, stimAINPChNames, channInfo,titName, timeInfo.startNSxSec, timeInfo.endNSxSec);
[~,~,~,indTimeSTIMPerFile] = scriptCheckStimInNSX(fileNameNSxPerNSP, fileNameStimSites, dirResults, stimAINPChNames, channInfo,titName, timeInfo.startNSxSec, timeInfo.endNSxSec);

% % %% Align NSP1 since it does not have SYNC data - simlar to MG147
% channInfo.isStimInAINP = 0; %channInfo.isStimInAINP;
% [indTimeSTIMPerFile, startNSXSecPerNSP] = alignNSXFromSTIMartifactAINP(fileNameNSxPerNSP, alignAINPChNames, channInfo, timeInfo.startNSxSec, timeInfo.endNSxSec);

%% Sort stim event times into nsp1 or nsp2 file
% new stim arrays
stimTimeON_nsp1 = [];
if ~isempty(filenameNSx_nsp2)
    stimTimeON_nsp2 = [];
end

% % stimIndStart 
% % adding stim index to per nsp arrays
% for i = 1:size(stimLogNSPs,1)
%     stimTimeON_nsp1(i,1) = indTimeSTIMPerFile{1,1}(i);
%     if ~isempty(filenameNSx_nsp2)
%         stimTimeON_nsp2(i,1) = indTimeSTIMPerFile{1,2}(i);    
%     end
% end

% adding stim index to per nsp arrays

idxNsp1 = indTimeSTIMPerFile{1,1}(:);
if ~isempty(filenameNSx_nsp2) && any(channInfo.NSPnumber(:)==2) %% function doesnt break if only 1 nsp involved
    idxNsp2 = indTimeSTIMPerFile{1,2}(:);    
end

% reconcile detected onsets vs log: keep only as many as the log lists
nLog = size(stStimSites.stimchans, 1);        % events in the txt/OR file (460)
nDet = numel(idxNsp1);                          % detected onsets (465)

if nDet > nLog
    warning('Detected %d stim onsets but log has %d; dropping the final %d detected.', ...
            nDet, nLog, nDet - nLog);
    idxNsp1 = idxNsp1(1:nLog);
    if ~isempty(filenameNSx_nsp2) && any(channInfo.NSPnumber(:)==2)
        idxNsp2 = idxNsp2(1:nLog);
    end
elseif nDet < nLog
    error('Detected %d stim onsets but log has %d — fewer detections than expected, not safe to trim.', ...
          nDet, nLog);
end

nStimEvents = numel(idxNsp1);                      

stimTimeON_nsp1 = idxNsp1/hdrNS3_nsp1.hdr.Fs{1}; % converting time from index number to seconds (sec = index/sampling rate)
if ~isempty(filenameNSx_nsp2) && any(channInfo.NSPnumber(:)==2)
    stimTimeON_nsp2 = idxNsp2/hdrNS3_nsp2.hdr.Fs{1};
end

stimTimeOFF_nsp1 = stimTimeON_nsp1+stimParameters.stimPulseDuration;
if ~isempty(filenameNSx_nsp2) && any(channInfo.NSPnumber(:)==2)
    stimTimeOFF_nsp2 = stimTimeON_nsp2+stimParameters.stimPulseDuration;
end
% map each event to its unique pair (order-independent match, validated: no zeros)
%eventChans  = sort(stStimSites.stimchans(:, 2:3), 2); %new logfile config
eventChans  = sort(stStimSites.stimchans(:, 1:2), 2); %old logfile config
uniquePairs = sort(channInfo.stimChNumber', 2);
[~, pairIdxPerEvent] = ismember(eventChans, uniquePairs, 'rows');% map each event to its unique pair (order-independent match, validated: no zeros)

% build per-event site name + channel/NSP columns
stimBipolarSites = cell(nStimEvents, 5);
for k = 1:nStimEvents
    p = pairIdxPerEvent(k);
    stimBipolarSites{k,1} = sprintf('%s-%s', channInfo.stimChNames{1,p}, channInfo.stimChNames{2,p});
    stimBipolarSites{k,2} = channInfo.stimChNumberInNSX(1,p);
    stimBipolarSites{k,3} = channInfo.NSPnumber(p);
    stimBipolarSites{k,4} = channInfo.stimChNumberInNSX(2,p);
    stimBipolarSites{k,5} = channInfo.NSPnumber(p);
end

% trial-type strings, one per event
stimTrialType = cell(nStimEvents,1);
part1 = join([stimParameters.stim_type{1},"Single Pulse stim"],' ');
part3 = join(["current:", string(stimParameters.stimCurrent), 'mA'],' ');
part4 = join(["stimulation duration:", string(stimParameters.stimPulseDuration), 'ms'],' ');
part5 = join(["frequency:", string(stimParameters.stimFrequency), 'Hz'],' ');
for k = 1:nStimEvents
    part2 = join(["channels:", stimBipolarSites{k,1}],' ');
    stimTrialType{k,1} = join([part1,part2,part3,part4,part5],', ');
end
%% set up table vars    
% creating cells for table()
stimPulseDuration = cell(nStimEvents,1);
responseTime = cell(nStimEvents,1);
stimFile = cell(nStimEvents,1);
hed = cell(nStimEvents,1);
stimFrequency = cell(nStimEvents,1);
stimCurrent = cell(nStimEvents,1);
stim_type = cell(nStimEvents,1);

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
    'electrical_stimulation_Channel1Stim','electrical_stimulation_Channel1StimNSP',...
    'electrical_stimulation_Channel2Stim','electrical_stimulation_Channel2StimNSP'};

if ~isempty(stimTimeON_nsp1) % avoid saving an empty file if there were no stim events in that nsp
    table_eventsTSV_nsp1 = table(stimTimeON_nsp1,stimPulseDuration,stimTrialType,responseTime,stimFile,hed,...
        stimTimeON_nsp1,stimTimeOFF_nsp1,stimFrequency,stimCurrent,stimBipolarSites(:,1),stim_type,...
        stimBipolarSites(:,2),stimBipolarSites(:,3),stimBipolarSites(:,4),stimBipolarSites(:,5),...
        'VariableNames', varNames); 
    writetable(table_eventsTSV_nsp1, filename_eventsTSV_nsp1, 'FileType', 'text', 'Delimiter', '\t');
end

if ~isempty(filenameNSx_nsp2) && any(channInfo.NSPnumber(:)==2) %% function doesnt break if only 1 nsp involved
    table_eventsTSV_nsp2 = table(stimTimeON_nsp2,stimPulseDuration,stimTrialType,responseTime,stimFile,hed,...
        stimTimeON_nsp2,stimTimeOFF_nsp2,stimFrequency,stimCurrent,stimBipolarSites(:,1),stim_type,...
        stimBipolarSites(:,2),stimBipolarSites(:,3),stimBipolarSites(:,4),stimBipolarSites(:,5),...
        'VariableNames', varNames); 
    writetable(table_eventsTSV_nsp2, filename_eventsTSV_nsp2, 'FileType', 'text', 'Delimiter', '\t');
end

end