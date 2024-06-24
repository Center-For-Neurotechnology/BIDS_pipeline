%% set up BIDS directory
% files will be saved in: directoryBIDS/sub_XXXX/
directoryBIDS = 'E:\BIDS_Neuralynx'; 
sub_XXXX = 'sub-0000'; % the deidentified patient ID


%% images (PLACEHOLDER, waiting for new MRI pipeline)
% filename_MRI = perParticipantImageNII(sub_XXXX, filename_MRI, directoryBIDS) 


%% per participant files
%% _coordsystem.json
% create a json file with a coordinate system in which electrode positions are expressed
% saved as: directoryBIDS/sub_XXXX/ses-postimp/ieeg/sub-XXXX_ses-postimp_coordsystem.json
% post MRI file should already be in the BIDS directory: directoryBIDS/sub_XXXX/ses-postimp/anat/sub-XXXX_ses-postimp_acq-CT_run-01_T1w.nii
filename_MRI = 'sub-0000_ses-postimp_acq-CT_run-01_T1w.nii'; % will not be used to open a file, just as a string in the json file
perParticipantCoordsystemJSON(sub_XXXX, filename_MRI, directoryBIDS)

%% _T1w.json
% create a json file with information about the pre and post implant scans,
%       currently set to 'n/a' for our data 
% saved as: directoryBIDS/sub_XXXX/ses-preimp/anat/sub-XXXX_ses-preimp_acq-CT_run-01_T1w.json 
%       and directoryBIDS/sub_XXXX/ses-postimp/anat/sub-XXXX_ses-postimp_acq-T1w_run-01_T1w.json 
preImplantScan = 'MRI';
postImplantScan = 'CT'; % 'MRI' will be changed to 'T1w' in the file name
perParticipantImageJSON(sub_XXXX, preImplantScan, postImplantScan, directoryBIDS)

%% _electrodes.tsv
% create a file that gives the location, size and other properties of iEEG electrodes
% saved as: directoryBIDS/sub_XXXX/ses-postimp/ieeg/sub-XXXX_ses-postimp_electrodes.tsv
filename_RAS = 'E:\BIDStesting\local_data\MG197\MG197_ElectrodeInfo_RAS.xlsx';
perParticipantElectrodesTSV(sub_XXXX, filename_RAS, directoryBIDS)





%% per session files

%% _channels.tsv
% create a tsv file containing additional descriptions of the channels
% saved as: directoryBIDS\sub_XXXX\ses-postimp\ieeg\sub-XXXX_ses-postimp_task-NetworkWake1RAWNSP1_run-01_channels.tsv
taskName = 'NetworkWake1';
ieeg_run = '01'; % BIDS stim session number for this participant
posFixNCS = ''; % string after channel name in nsc file name (e.g. for file 'LTMb-Pul9_0017.ncs', posFixNCS = '_0017')
badChannels = ''; % assuming empty for now, can write a script to make this mat file later if needed
foldername_neuralynx = 'E:\BIDStesting\local_data\MG197\NetworkWake1\Data\C3.ncs'; % path to any .ncs file in the session's data folder IMPORTANT: include the .ncs file name!
[hdrn] = perSessionChannelsTSVn(directoryBIDS,sub_XXXX,taskName,ieeg_run,foldername_neuralynx,badChannels,posFixNCS);


%% _ieeg (edf, brainvision)
% create edf and brainvision files containg raw iEEG data
% saved as: directoryBIDS\sub_XXXX\ses-postimp\ieeg\sub-XXXX_ses-postimp_task-NetworkWake1RAWNSP1_run-01_ieeg.eeg
% with extentions _ieeg.eeg, _ieeg.edf, _ieeg.vmrk, _ieeg.vhdr 
perSessionIEEGn(directoryBIDS,sub_XXXX,taskName,ieeg_run,foldername_neuralynx,hdrn,posFixNCS);
%% _events.tsv
% create a tsv file containing electrical stimulation events and parameters 
% saved as: directoryBIDS\sub_XXXX\ses-postimp\ieeg\sub-XXXX_ses-postimp_task-NetworkWake1RAWNSP1_run-01_events.tsv
stimParameters.stimPulseDuration = 0.233; % in mS
stimParameters.stimFrequency = 0; % in Hz
stimParameters.stimCurrent = 7; % in mA;
stimParameters.stim_type = {'Bipolar','biphasic'};

channInfo.bankInfo.bankA = 1:32; % Which Neuralynx channels correspond to each Cerestim bank [cerestim bank->neuralynx channel]
channInfo.bankInfo.bankB = 65:96;
channInfo.bankInfo.bankC = 129:160;

fileNameStimSites = 'E:\BIDStesting\local_data\MG197\NetworkWake1\Logfiles\NetworkSweepBipolChans-04_10-16-03.mat'; % updated cerestim log file format
stimChNames = 'CSC289'; % SYNC channel at CSC289
perSessionEventsTSVn(directoryBIDS,sub_XXXX,taskName,ieeg_run,foldername_neuralynx,stimParameters,...
    channInfo,fileNameStimSites,hdrn,stimChNames,posFixNCS)

%% _events.json
% create sub_XXXX\ses-postimp\ieeg\sub-XXXX_ses-postimp_task-NetworkWake1RAWNSP1_run-01_events.json
OperatingSystem = 'Windows 10';
perSessionEventsJSON(directoryBIDS,sub_XXXX,taskName,ieeg_run,OperatingSystem,stimParameters)







