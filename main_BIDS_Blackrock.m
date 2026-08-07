%% set up BIDS directory
% files will be saved in: directoryBIDS/sub_XXXX/
directoryBIDS = 'J:\BIDsified_StimData_EMU'; 
sub_XXXX = 'sub-9d4z'; % MG176

subjDir = fullfile(directoryBIDS, sub_XXXX);
if ~isfolder(subjDir)
    % create the full subfolder structure
    mkdir(fullfile(subjDir, 'ses-postimp', 'ieeg'));
    mkdir(fullfile(subjDir, 'ses-postimp', 'anat'));
    mkdir(fullfile(subjDir, 'ses-preimp',  'anat'));
end

% % images (PLACEHOLDER, waiting for new MRI pipeline)
% filename_MRI = perParticipantImageNII(sub_XXXX, filename_MRI, directoryBIDS) 


%% per participant files
% %% _coordsystem.json
% % create a json file with a coordinate system in which electrode positions are expressed
% % saved as: directoryBIDS/sub_XXXX/ses-postimp/ieeg/sub-XXXX_ses-postimp_coordsystem.json
% % post MRI file should already be in the BIDS directory: directoryBIDS/sub_XXXX/ses-postimp/anat/sub-XXXX_ses-postimp_acq-CT_run-01_T1w.nii
% filename_MRI = 'sub-0000_ses-postimp_acq-CT_run-01_T1w.nii'; % will not be used to open a file, just as a string in the json file
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
filename_RAS = 'O:\ElectrodeLocalizations\thalamicMapping\MG176\MG176_SurferOutput\MG176_RAS_Electrode_Parc.csv'; %Jane2
perParticipantElectrodesTSV(sub_XXXX, filename_RAS, directoryBIDS)

%% per session files
%% _channels.tsv
% create a tsv file containing additional descriptions of the channels
% saved as: directoryBIDS\sub_XXXX\ses-postimp\ieeg\sub-XXXX_ses-postimp_task-NetworkWake1RAWNSP1_run-01_channels.tsv
taskName = 'NetworkWake1';
ieeg_run = '01';
badChannels_nsp1 = ''; % assuming empty for now, can write a script to make this mat file later
badChannels_nsp2 = '';
filenameNS3_nsp1 = 'J:\StimDataBackup\Data_Stimulation\MG176\NetworkWake1\NSP1\05-194100-002.ns3'; % path to nsp1 ns3 
filenameNS3_nsp2 = 'J:\StimDataBackup\Data_Stimulation\MG176\NetworkWake1\NSP2\05-194058-002.ns3';  % path to nsp2 ns3, leave empty if just using nsp1
[hdrNS3_nsp1, hdrNS3_nsp2] = perSessionChannelsTSV(directoryBIDS,sub_XXXX,taskName,ieeg_run,...
    filenameNS3_nsp1,filenameNS3_nsp2,badChannels_nsp1,badChannels_nsp2);

%% _ieeg (edf, brainvision)
% create edf and brainvision files containg raw iEEG data
% saved as: directoryBIDS\sub_XXXX\ses-postimp\ieeg\sub-XXXX_ses-postimp_task-NetworkWake1RAWNSP1_run-01_ieeg.eeg
% with extentions _ieeg.eeg, _ieeg.edf, _ieeg.vmrk, _ieeg.vhdr 
% perSessionIEEG(directoryBIDS,sub_XXXX,taskName,ieeg_run,filenameNS3_nsp1,filenameNS3_nsp2, hdrNS3_nsp1, hdrNS3_nsp2);
filename_IEEG_nsp1 = [directoryBIDS,'/',sub_XXXX,'/ses-postimp/ieeg/',sub_XXXX,'_ses-postimp_task-',taskName,'RAWNSP1_run-',ieeg_run,'_ieeg.edf'];
filename_IEEG_nsp2 = [directoryBIDS,'/',sub_XXXX,'/ses-postimp/ieeg/',sub_XXXX,'_ses-postimp_task-',taskName,'RAWNSP2_run-',ieeg_run,'_ieeg.edf'];
blackrock_ns3_to_edf(filenameNS3_nsp1, filename_IEEG_nsp1);
blackrock_ns3_to_edf(filenameNS3_nsp2, filename_IEEG_nsp2);
%% _events.tsv
% create a tsv file containing electrical stimulation events and parameters 
% saved as: directoryBIDS\sub_XXXX\ses-postimp\ieeg\sub-XXXX_ses-postimp_task-NetworkWake1RAWNSP1_run-01_events.tsv
% pulsewidth(90); interphase(53) (pulsewidth*2+interphase)/1000 ~0.233
stimParameters.stimPulseDuration = 0.233; % in mS 
stimParameters.stimFrequency = 0; % in Hz
stimParameters.stimCurrent = 7; % in mA;
stimParameters.stim_type = {'Bipolar','biphasic'};

channInfo.bankInfo.bankA = 1:32;% Which NSX channels correspond to each bank 
channInfo.bankInfo.bankB = 65:96; % 
channInfo.bankInfo.bankC = 97:128; % from NSP 1
channInfo.bankInfo.bankANSP = 1;% Which NSP (1 or 2) correspond to each bank 
channInfo.bankInfo.bankBNSP = 1;
channInfo.bankInfo.bankCNSP = 1;
timeInfo.startNSxSec= 0; 
timeInfo.endNSxSec = []; 
fileNameStimSites = 'J:\StimDataBackup\Data_Stimulation\MG176\NetworkWake1\NetworkSweepReverseBipolChans-05_19-54-54.mat';
stimainp = {'SYNC'};
perSessionEventsTSV(directoryBIDS,sub_XXXX,taskName,ieeg_run,filenameNS3_nsp1,filenameNS3_nsp2,stimParameters,...
    channInfo,fileNameStimSites,hdrNS3_nsp1,hdrNS3_nsp2, stimainp, timeInfo.startNSxSec, timeInfo.endNSxSec);
% % 
% %% _events.json - do we need this?
% % create sub_XXXX\ses-postimp\ieeg\sub-XXXX_ses-postimp_task-NetworkWake1RAWNSP1_run-01_events.json
% OperatingSystem = 'Windows 10';
% perSessionEventsJSON(directoryBIDS,sub_XXXX,taskName,ieeg_run,OperatingSystem,stimParameters)







