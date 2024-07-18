%% set up BIDS directory
% files will be saved in: directoryBIDS/sub_XXXX/
directoryBIDS = 'E:/BIDStesting/active_bids_pipeline/BIDS_pipeline/results'; 
sub_XXXX = 'sub-0169_BR'; % the deidentified patient ID


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
filename_RAS = 'E:\Neuron2023\OriginalData\MG144\MG144_ElectrodeInfo_RAS.xlsx';
perParticipantElectrodesTSV(sub_XXXX, filename_RAS, directoryBIDS)






%% per session files
%% _channels.tsv
% create a tsv file containing additional descriptions of the channels
% saved as: directoryBIDS\sub_XXXX\ses-postimp\ieeg\sub-XXXX_ses-postimp_task-NetworkWake1RAWNSP1_run-01_channels.tsv
taskName = 'Anesthesia';
ieeg_run = '03';
badChannels_nsp1 = ''; % assuming empty for now, can write a script to make this mat file later
badChannels_nsp2 = '';
filenameNS3_nsp1 = 'E:\BIDStesting\local_data\MG169\StimulationDay3\NSP1\10-083607-003.ns3'; % path to nsp1 ns3 
filenameNS3_nsp2 = 'E:\BIDStesting\local_data\MG169\StimulationDay3\NSP2\10-083608-003.ns3';  % path to nsp2 ns3, leave empty if just using nsp1
[hdrNS3_nsp1, hdrNS3_nsp2] = perSessionChannelsTSV(directoryBIDS,sub_XXXX,taskName,ieeg_run,...
    filenameNS3_nsp1,filenameNS3_nsp2,badChannels_nsp1,badChannels_nsp2);

%% _ieeg (edf, brainvision)
% create edf and brainvision files containg raw iEEG data
% saved as: directoryBIDS\sub_XXXX\ses-postimp\ieeg\sub-XXXX_ses-postimp_task-NetworkWake1RAWNSP1_run-01_ieeg.eeg
% with extentions _ieeg.eeg, _ieeg.edf, _ieeg.vmrk, _ieeg.vhdr 
perSessionIEEG(directoryBIDS,sub_XXXX,taskName,ieeg_run,filenameNS3_nsp1,filenameNS3_nsp2, hdrNS3_nsp1, hdrNS3_nsp2)
%% _events.tsv
% create a tsv file containing electrical stimulation events and parameters 
% saved as: directoryBIDS\sub_XXXX\ses-postimp\ieeg\sub-XXXX_ses-postimp_task-NetworkWake1RAWNSP1_run-01_events.tsv
stimParameters.stimPulseDuration = 0.233; % in mS
stimParameters.stimFrequency = 0; % in Hz
stimParameters.stimCurrent = 7; % in mA;
stimParameters.stim_type = {'Bipolar','biphasic'};

channInfo.bankInfo.bankA = 1:32;% Which NSX channels correspond to each bank 
channInfo.bankInfo.bankB = 1:32;
channInfo.bankInfo.bankC = 33:64;
channInfo.bankInfo.bankANSP = 1;% Which NSP (1 or 2) correspond to each bank 
channInfo.bankInfo.bankBNSP = 2;
channInfo.bankInfo.bankCNSP = 2;
fileNameStimSites = 'E:\Neuron2023\OriginalData\MG144\OR\stimchansA.mat';
perSessionEventsTSV(directoryBIDS,sub_XXXX,taskName,ieeg_run,filenameNS3_nsp1,filenameNS3_nsp2,stimParameters,...
    channInfo,fileNameStimSites,hdrNS3_nsp1,hdrNS3_nsp2)

%% _events.json
% create sub_XXXX\ses-postimp\ieeg\sub-XXXX_ses-postimp_task-NetworkWake1RAWNSP1_run-01_events.json
OperatingSystem = 'Windows 10';
perSessionEventsJSON(directoryBIDS,sub_XXXX,taskName,ieeg_run,OperatingSystem,stimParameters)







