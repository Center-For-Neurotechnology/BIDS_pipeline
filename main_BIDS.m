%% ****************************************** NSX CLIPPING: start ******************************************
%% Setting up raw nsx file path and result path
pName = 'MGxxx'; % patient
resultsPath =  ['E:\BIDStesting\nsx_results',filesep,pName]; % the results path to save the new clipped nsx files in

% ns3 files (nsp1 and nsp2) to be clipped clip
file_being_split = '10-083607-003';  % the file that will be clipped, just to create a results path for this specific file split
fileNameNSxPerNSP{1} = 'E:\BIDStesting\local_data\MGxxx\StimulationDay3\NSP1\10-083607-003.ns3';
fileNameNSxPerNSP{2} = 'E:\BIDStesting\local_data\MGxxx\StimulationDay3\NSP2\10-083608-003.ns3';

fileNameNEVPerNSP{1} = 'E:\BIDStesting\local_data\MGxxx\StimulationDay3\NSP1\10-083607-003.nev';
fileNameNEVPerNSP{2} = 'E:\BIDStesting\local_data\MGxxx\StimulationDay3\NSP2\10-083608-003.nev';

selChName1 = [35,36,82,83];%  % bipolar ch numbers to visualize in clipping plot
buffer_time_minutes = 5; % time buffer (in minutes) before and after each session

gettingClipTimes(pName,resultsPath,fileNameNSxPerNSP,fileNameNEVPerNSP,file_being_split,selChName1,buffer_time_minutes);
%% ****************************************** NSX CLIPPING: end ********************************************




%% **************************************** NEW BIDS PIPELINE: start ****************************************
%% set uo BIDS directories
directoryBIDS = 'E:\BIDStesting\BIDS_data'; % directoryBIDS/sub_XXXX/ses-postimp/ieeg
sub_XXXX = '1a2b'; % the deidentified patient ID

%%
% create directoryBIDS/sub_XXXX/ses-postimp/ieeg/sub-XXXX_ses-postimp_coordsystem.json
% post MRI file name: directoryBIDS/sub_XXXX/ses-postimp/anat/sub-XXXX_ses-postimp_acq-CT_run-01_T1w.nii
filename_MRI = 'sub-XXXX_ses-postimp_acq-CT_run-01_T1w.nii'; % will not be used to open a file, just as a value in the json file
perParticipantCoordsystemJSON(sub_XXXX, filename_MRI, directoryBIDS)

% placeholder 
% perParticipantImageNII(sub_XXXX, filename_MRI, directoryBIDS)

% create directoryBIDS/sub_XXXX/ses-preimp/anat/sub-XXXX_ses-preimp_acq-CT_run-01_T1w.json 
% and directoryBIDS/sub_XXXX/ses-postimp/anat/sub-XXXX_ses-postimp_acq-T1w_run-01_T1w.json 
preImplantScan = 'CT';
postImplantScan = 'MRI';
perParticipantImageJSON(sub_XXXX, preImplantScan, postImplantScan, directoryBIDS)

% create directoryBIDS/sub_XXXX/ses-postimp/ieeg/sub-XXXX_ses-postimp_electrodes.tsv
filename_RAS = 'Z:\Original Data\MG\MG151revised\MG151revised_Notes_and_Images\MG151revised_ElectrodeInfo_RAS.xlsx';
perParticipantElectrodesTSV(sub_XXXX, filename_RAS, directoryBIDS)

% create directoryBIDS\sub_XXXX\ses-postimp\ieeg\sub-XXXX_ses-postimp_task-NetworkWake1RAWNSP1_run-01_channels.tsv
perSessionChannelsTSV(filename_nsp1_ns3,filename_nsp2_ns3)


%% place holders:

% create sub_XXXX\ses-postimp\ieeg\sub-XXXX_ses-postimp_task-NetworkWake1RAWNSP1_run-01_events.tsv
% perSessionEventsTSV(filename_nsp1_ns3,filename_nsp2_ns3)

% create sub_XXXX\ses-postimp\ieeg\sub-XXXX_ses-postimp_task-NetworkWake1RAWNSP1_run-01_events.json
% perSessionEventsJSON(filename_nsp1_ns3,filename_nsp2_ns3)

% create postimp / ... _ieeg.eeg, _ieeg.edf, _ieeg.vmrk, _ieeg.vhdr 
% perSessionIEEG(filename_nsp1_ns3,filename_nsp2_ns3)


%% **************************************** NEW BIDS PIPELINE: end ****************************************
%%
