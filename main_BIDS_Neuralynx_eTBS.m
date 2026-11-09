%% set up BIDS directory
% files will be saved in: directoryBIDS/sub_XXXX/
directoryBIDS = '';  
sub_XXXX = ''; % the deidentified patient ID - MG258


%% add fieldtrip

addpath D:\krishma\GitHub\BIDS_pipeline\fieldtrip-master\fieldtrip-master
ft_defaults



%% images (PLACEHOLDER, waiting for new MRI pipeline)
% filename_MRI = perParticipantImageNII(sub_XXXX, filename_MRI, directoryBIDS) 


% %% per participant files
% %% _coordsystem.json
% % create a json file with a coordinate system in which electrode positions are expressed
% % saved as: directoryBIDS/sub_XXXX/ses-postimp/ieeg/sub-XXXX_ses-postimp_coordsystem.json
% % post MRI file should already be in the BIDS directory: directoryBIDS/sub_XXXX/ses-postimp/anat/sub-XXXX_ses-postimp_acq-CT_run-01_T1w.nii
% filename_MRI = 'sub-6j9a_ses-postimp_acq-CT_run-01_T1w.nii'; % will not be used to open a file, just as a string in the json file
% perParticipantCoordsystemJSON(sub_XXXX, filename_MRI, directoryBIDS)
% 
% %% _T1w.json
% % create a json file with information about the pre and post implant scans,
% %       currently set to 'n/a' for our data 
% % saved as: directoryBIDS/sub_XXXX/ses-preimp/anat/sub-XXXX_ses-preimp_acq-CT_run-01_T1w.json 
% %       and directoryBIDS/sub_XXXX/ses-postimp/anat/sub-XXXX_ses-postimp_acq-T1w_run-01_T1w.json 
% preImplantScan = 'MRI';
% postImplantScan = 'CT'; % 'MRI' will be changed to 'T1w' in the file name
% perParticipantImageJSON(sub_XXXX, preImplantScan, postImplantScan, directoryBIDS)

%% _electrodes.tsv
% create a file that gives the location, size and other properties of iEEG electrodes
% saved as: directoryBIDS/sub_XXXX/ses-postimp/ieeg/sub-XXXX_ses-postimp_electrodes.tsv
filename_RAS = '';
perParticipantElectrodesTSV(sub_XXXX, filename_RAS, directoryBIDS)


%% per session files
%% _channels.tsv
% create a tsv file containing additional descriptions of the channels
% saved as: directoryBIDS\sub_XXXX\ses-postimp\ieeg\sub-XXXX_ses-postimp_task-NetworkWake1RAWNSP1_run-01_channels.tsv
taskName = 'eTBS';
ieeg_run = '01'; % BIDS stim session number for this participant
posFixNCS = ''; % string after channel name in nsc file name (e.g. for file 'LTMb-Pul9_0017.ncs', posFixNCS = '_0017')
badChannels = ''; % assuming empty for now, can write a script to make this mat file later if needed
foldername_neuralynx = ''; % path to any .ncs file in the session's data folder IMPORTANT: include the .ncs file name!
[hdrn] = perSessionChannelsTSVn(directoryBIDS,sub_XXXX,taskName,ieeg_run,foldername_neuralynx,badChannels,posFixNCS);


%% _ieeg (edf, brainvision)
% create edf and brainvision files containg raw iEEG data
% saved as: directoryBIDS\sub_XXXX\ses-postimp\ieeg\sub-XXXX_ses-postimp_task-NetworkWake1RAWNSP1_run-01_ieeg.eeg
% with extentions _ieeg.eeg, _ieeg.edf, _ieeg.vmrk, _ieeg.vhdr ]
startNSxSec = 0; %5*10^5/2000; % in seconds, 0 for the entire recording
endNSxSec = []; % in seconds, [] for the entire recording
perSessionIEEGn(directoryBIDS,sub_XXXX,taskName,ieeg_run,foldername_neuralynx,hdrn,posFixNCS,startNSxSec,endNSxSec);
%% _events.tsv
% create a tsv file containing electrical stimulation events and parameters 
% saved as: directoryBIDS\sub_XXXX\ses-postimp\ieeg\sub-XXXX_ses-postimp_task-NetworkWake1RAWNSP1_run-01_events.tsv

stimParameters.stim_type = {'Bipolar','biphasic'};

channInfo.bankInfo.bankA = 129:160; % Which Neuralynx channels correspond to each Cerestim bank [cerestim bank->neuralynx channel]
channInfo.bankInfo.bankB = 161:192;
channInfo.bankInfo.bankC = 193:224;

filename_chanListEMU = ''; % Channel list (Neuralynx CSC files are loaded alphabetically, different from the EMU channel list order)
logFileDirectory = ''; % updated cerestim log file format
stimChNames = 'CSC289'; % SYNC channel at CSC289
perSessionEventsTSVn_eTBS(directoryBIDS,sub_XXXX,taskName,ieeg_run,foldername_neuralynx,stimParameters,...
    channInfo,logFileDirectory,hdrn,stimChNames,posFixNCS,filename_chanListEMU,startNSxSec,endNSxSec)

% %% _events.json
% % create sub_XXXX\ses-postimp\ieeg\sub-XXXX_ses-postimp_task-NetworkWake1RAWNSP1_run-01_events.json
% stimLogFile = get_eTBSMatrix(logFileDirectory);
% stimParameters.stimPulseDuration = stimLogFile(:,10)/1000; % ms
% stimParameters.stimCurrent = stimLogFile(:,5)/1000; % mA
% 
% OperatingSystem = 'Windows 10';
% perSessionEventsJSON_eTBS(directoryBIDS,sub_XXXX,taskName,ieeg_run,OperatingSystem,stimParameters)







