%% set up BIDS directories
directoryBIDS = 'E:\BIDStesting\BIDS_data'; % directoryBIDS/sub_XXXX/ses-postimp/ieeg
sub_XXXX = 'sub-7u9e'; % the deidentified patient ID


%% images PLACEHOLDER
% % figure out whether scans will already be de-IDed. could actually probably start by assuming the de-IDed scans already exist, then create a new function to do that if they don't actually already exist
% % filename_MRI = perParticipantImageNII(sub_XXXX, filename_MRI, directoryBIDS) 


%% tsv,csv,json files
%% _coordsystem,json
% create directoryBIDS/sub_XXXX/ses-postimp/ieeg/sub-XXXX_ses-postimp_coordsystem.json
% post MRI file name: directoryBIDS/sub_XXXX/ses-postimp/anat/sub-XXXX_ses-postimp_acq-CT_run-01_T1w.nii
filename_MRI = 'sub-XXXX_ses-postimp_acq-CT_run-01_T1w.nii'; % will not be used to open a file, just as a value in the json file (should prob get this from previous function)
perParticipantCoordsystemJSON(sub_XXXX, filename_MRI, directoryBIDS)


%% _T1w.json
% create directoryBIDS/sub_XXXX/ses-preimp/anat/sub-XXXX_ses-preimp_acq-CT_run-01_T1w.json 
% and directoryBIDS/sub_XXXX/ses-postimp/anat/sub-XXXX_ses-postimp_acq-T1w_run-01_T1w.json 
preImplantScan = 'CT';
postImplantScan = 'MRI';
perParticipantImageJSON(sub_XXXX, preImplantScan, postImplantScan, directoryBIDS)


%% _electrodes.tsv
% create directoryBIDS/sub_XXXX/ses-postimp/ieeg/sub-XXXX_ses-postimp_electrodes.tsv
filename_RAS = 'Z:\Original Data\MG\MG151revised\MG151revised_Notes_and_Images\MG151revised_ElectrodeInfo_RAS.xlsx';
perParticipantElectrodesTSV(sub_XXXX, filename_RAS, directoryBIDS)


%% _channels.tsv
% create directoryBIDS\sub_XXXX\ses-postimp\ieeg\sub-XXXX_ses-postimp_task-NetworkWake1RAWNSP1_run-01_channels.tsv
taskName = 'NetworkWake1';
ieeg_run = '01';
badChannels_nsp1 = ''; % assuming empty for now, can write a script to make this mat file later
badChannels_nsp2 = '';
filenameNSx_nsp1 = 'Z:\Original Data\MG\MG151revised\MG151revised_Tasks\STIMULATION\NetworkWake1\NSP1\10-193513-001.ns3';
filenameNSx_nsp2 = 'Z:\Original Data\MG\MG151revised\MG151revised_Tasks\STIMULATION\NetworkWake1\NSP2\10-193514-001.ns3';
[hdrNS3_nsp1, hdrNS3_nsp2] = perSessionChannelsTSV(directoryBIDS,sub_XXXX,taskName,ieeg_run,filenameNSx_nsp1,filenameNSx_nsp2,badChannels_nsp1,badChannels_nsp2);


%% _ieeg (edf, brainvision)
% create postimp / ... _ieeg.eeg, _ieeg.edf, _ieeg.vmrk, _ieeg.vhdr 
% directoryBIDS\sub_XXXX\ses-postimp\ieeg\sub-XXXX_ses-postimp_task-NetworkWake1RAWNSP1_run-01_ieeg.eeg
perSessionIEEG(directoryBIDS,sub_XXXX,taskName,ieeg_run,filenameNSx_nsp1,filenameNSx_nsp2, hdrNS3_nsp1, hdrNS3_nsp2)


%% _events.tsv
% create sub_XXXX\ses-postimp\ieeg\sub-XXXX_ses-postimp_task-NetworkWake1RAWNSP1_run-01_events.tsv
stimParameters.stimPulseDuration = 0.233; % manual input for now, can be integrated with new cerelab updates
stimParameters.stimFrequency = 0; % in Hz
stimParameters.stimCurrent = 7; % in mA;
stimParameters.stim_type = {'Bipolar','biphasic'};

channInfo.bankInfo.bankA = 1:32;% Which NSX channels correspond to each bank 
channInfo.bankInfo.bankB = 65:96;
channInfo.bankInfo.bankC = 97:128; 
channInfo.bankInfo.bankANSP = 1;% Which NSP (1 or 2) correspond to each bank 
channInfo.bankInfo.bankBNSP = 1;
channInfo.bankInfo.bankCNSP = 1;
fileNameStimSites = 'Z:\Original Data\MG\MG151revised\MG151revised_Tasks\STIMULATION\NetworkWake1\NetworkSweepChans-10_19-48-15.mat';
perSessionEventsTSV(directoryBIDS,sub_XXXX,taskName,ieeg_run,filenameNSx_nsp1,filenameNSx_nsp2,stimParameters,...
    channInfo,fileNameStimSites,hdrNS3_nsp1,hdrNS3_nsp2)


%% _events.json
% create sub_XXXX\ses-postimp\ieeg\sub-XXXX_ses-postimp_task-NetworkWake1RAWNSP1_run-01_events.json
OperatingSystem = "Windows 10";
perSessionEventsJSON(directoryBIDS,sub_XXXX,taskName,ieeg_run,OperatingSystem)


