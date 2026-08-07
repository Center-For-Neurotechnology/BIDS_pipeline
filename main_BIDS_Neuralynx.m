%% set up BIDS directory
% files will be saved in: directoryBIDS/sub_XXXX/
% pName = MG95c
directoryBIDS = 'K:\BIDsified_StimData_EMU'; 
sub_XXXX = 'sub-2v8e'; % MG225

subjDir = fullfile(directoryBIDS, sub_XXXX);
if ~isfolder(subjDir)
    % create the full subfolder structure
    mkdir(fullfile(subjDir, 'ses-postimp', 'ieeg'));
    mkdir(fullfile(subjDir, 'ses-postimp', 'anat'));
    mkdir(fullfile(subjDir, 'ses-preimp',  'anat'));
end

%% images (PLACEHOLDER, waiting for new MRI pipeline)
% filename_MRI = perParticipantImageNII(sub_XXXX, filename_MRI, directoryBIDS) 


% %% per participant files
% %% _coordsystem.json
% % create a json file with a coordinate system in which electrode positions are expressed
% % saved as: directoryBIDS/sub_XXXX/ses-postimp/ieeg/sub-XXXX_ses-postimp_coordsystem.json
% % post MRI file should already be in the BIDS directory: directoryBIDS/sub_XXXX/ses-postimp/anat/sub-XXXX_ses-postimp_acq-CT_run-01_T1w.nii
% filename_MRI = 'sub-9o9u_ses-postimp_acq-CT_T1w.nii'; % will not be used to open a file, just as a string in the json file
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
filename_RAS = 'K:\StimDataBackup\Data_Stimulation\MG225\preprocessed_results\MG225_RAS_Electrode_Parc.csv';
perParticipantElectrodesTSV(sub_XXXX, filename_RAS, directoryBIDS)


%% per session files
%% _channels.tsv
% create a tsv file containing additional descriptions of the channels
% saved as: directoryBIDS\sub_XXXX\ses-postimp\ieeg\sub-XXXX_ses-postimp_task-NetworkWake1RAWNSP1_run-01_channels.tsv
taskName = 'ThalamicNetwork';
ieeg_run = '01'; % BIDS stim session number for this participant
posFixNCS = ''; % string after channel name in nsc file name (e.g. for file 'LTMb-Pul9_0017.ncs', posFixNCS = '_0017')
badChannels = ''; % assuming empty for now, can write a script to make this mat file later if needed
foldername_neuralynx = 'K:\StimDataBackup\Data_Stimulation\MG225\ThalamicNet\rawData\C3.ncs'; 
[hdrn] = perSessionChannelsTSVn(directoryBIDS,sub_XXXX,taskName,ieeg_run,foldername_neuralynx,badChannels,posFixNCS);


%% _ieeg (edf)
% create edf and brainvision files containg raw iEEG data
% saved as: directoryBIDS\sub_XXXX\ses-postimp\ieeg\sub-XXXX_ses-postimp_task-NetworkWake1RAWNSP1_run-01_ieeg.eeg
% with extentions _ieeg.eeg, _ieeg.edf, _ieeg.vmrk, _ieeg.vhdr ]
startNSxSec = 0; % in seconds, 0 for the entire recording
endNSxSec = []; % in seconds, [] for the entire recording
perSessionIEEGn(directoryBIDS,sub_XXXX,taskName,ieeg_run,foldername_neuralynx,hdrn,posFixNCS,startNSxSec,endNSxSec);

%% _events.tsv
% % create a tsv file containing electrical stimulation events and parameters 
% % saved as: directoryBIDS\sub_XXXX\ses-postimp\ieeg\sub-XXXX_ses-postimp_task-NetworkWake1RAWNSP1_run-01_events.tsv
% Stimulation Parameters
stimParameters.stimPulseDuration = 0.233; % in mS
stimParameters.stimFrequency = 100; % in Hz
stimParameters.stimCurrent = 7; % in mA;
stimParameters.stim_type = {'Bipolar','biphasic'};
channInfo.bankInfo.bankA =   1:32;
channInfo.bankInfo.bankB =   97:128; 
channInfo.bankInfo.bankC =   129:160; 

filename_chanListEMU = 'K:\StimDataBackup\Data_Stimulation\MG225\preprocessed_results\MG225_Chan_List.xlsx'; % Channel list (Neuralynx CSC files are loaded alphabetically, different from the EMU channel list order)
fileNameStimSites = 'K:\StimDataBackup\Data_Stimulation\MG225\ThalamicNet\Logfiles\NetworkSweepBipolChans-16-Aug-2025_17-51-13.mat'; % updated cerestim logfile format
stimChNames = 'SYNC'; % SYNC channel at CSC289
startNSxSec= 1.22*10^6/2000; %if all file: 0 % 0.00*10^x/2000
endNSxSec = 4.93*10^6/2000; %if all file:[]
perSessionEventsTSVn(directoryBIDS,sub_XXXX,taskName,ieeg_run,foldername_neuralynx,stimParameters,...
    channInfo,fileNameStimSites,hdrn,stimChNames,posFixNCS,filename_chanListEMU,startNSxSec,endNSxSec)
% 
% % %% _events.json
% % % create sub_XXXX\ses-postimp\ieeg\sub-XXXX_ses-postimp_task-NetworkWake1RAWNSP1_run-01_events.json
% % OperatingSystem = 'Windows 11 Pro';
% % % perSessionEventsJSON(directoryBIDS,sub_XXXX,taskName,ieeg_run,OperatingSystem,stimParameters)
% % perSessionEventsJSON(directoryBIDS,sub_XXXX,taskName,ieeg_run,OperatingSystem)
% % 
% 
% 
% 
% 
% 
