%% set up BIDS directory
% files will be saved in: directoryBIDS/sub_XXXX/
directoryBIDS = 'J:\BIDsified_StimData_EMU'; 
sub_XXXX = 'sub-8u1w'; % the deidentified patient ID

subjDir = fullfile(directoryBIDS, sub_XXXX);
if ~isfolder(subjDir)
    % create the full subfolder structure
    mkdir(fullfile(subjDir, 'ses-postimp', 'ieeg'));
    mkdir(fullfile(subjDir, 'ses-postimp', 'anat'));
    mkdir(fullfile(subjDir, 'ses-preimp',  'anat'));
end

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
% filename_MRI = 'sub-1n5b_ses-postimp_acq-CT_run-01_T1w.nii'; % will not be used to open a file, just as a string in the json file
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
filename_RAS = 'J:\StimDataBackup\Data_Stimulation\MG249\preprocessed_results\MG249_RAS_Electrode_Parc.csv';
perParticipantElectrodesTSV(sub_XXXX, filename_RAS, directoryBIDS)


%% per session files - Blackrock
%% _channels.tsv
% create a tsv file containing additional descriptions of the channels
% saved as: directoryBIDS\sub_XXXX\ses-postimp\ieeg\sub-XXXX_ses-postimp_task-NetworkWake1RAWNSP1_run-01_channels.tsv
taskName = 'eTBS';
ieeg_run = '01';
badChannels_nsp1 = ''; % assuming empty for now, can write a script to make this mat file later
badChannels_nsp2 = '';
filenameNS3_nsp1 = 'J:\StimDataBackup\Data_Stimulation\MG249\eTBS\NSP1\20260729-111940-011-combined.ns3'; % path to nsp1 ns3 
filenameNS3_nsp2 = 'J:\StimDataBackup\Data_Stimulation\MG249\eTBS\NSP2\20260729-111941-011-combined.ns3';  % path to nsp2 ns3, leave empty if just using nsp1
[hdrNS3_nsp1, hdrNS3_nsp2] = perSessionChannelsTSV(directoryBIDS,sub_XXXX,taskName,ieeg_run,...
    filenameNS3_nsp1,filenameNS3_nsp2,badChannels_nsp1,badChannels_nsp2);

%% _ieeg (edf, brainvision)
% create edf and brainvision files containg raw iEEG data
% saved as: directoryBIDS\sub_XXXX\ses-postimp\ieeg\sub-XXXX_ses-postimp_task-NetworkWake1RAWNSP1_run-01_ieeg.eeg
% with extentions _ieeg.eeg, _ieeg.edf, _ieeg.vmrk, _ieeg.vhdr ]
startNSxSec = 0; % in seconds, 0 for the entire recording
endNSxSec = []; % in seconds, [] for the entire recording
% perSessionIEEGn(directoryBIDS,sub_XXXX,taskName,ieeg_run,foldername_neuralynx,hdrn,posFixNCS,startNSxSec,endNSxSec);
% perSessionIEEG(directoryBIDS,sub_XXXX,taskName,ieeg_run,filenameNS3_nsp1,filenameNS3_nsp2, hdrNS3_nsp1, hdrNS3_nsp2)
filename_IEEG_nsp1 = [directoryBIDS,'/',sub_XXXX,'/ses-postimp/ieeg/',sub_XXXX,'_ses-postimp_task-',taskName,'RAWNSP1_run-',ieeg_run,'_ieeg.edf'];
filename_IEEG_nsp2 = [directoryBIDS,'/',sub_XXXX,'/ses-postimp/ieeg/',sub_XXXX,'_ses-postimp_task-',taskName,'RAWNSP2_run-',ieeg_run,'_ieeg.edf'];
blackrock_ns3_to_edf(filenameNS3_nsp1, filename_IEEG_nsp1);
blackrock_ns3_to_edf(filenameNS3_nsp2, filename_IEEG_nsp2);
%% _events.tsv
% create a tsv file containing electrical stimulation events and parameters 
% saved as: directoryBIDS\sub_XXXX\ses-postimp\ieeg\sub-XXXX_ses-postimp_task-NetworkWake1RAWNSP1_run-01_events.tsv
% pulsewidth(100); interphase(53) (pulsewidth*2+interphase)/1000 ~0.253
stimParameters.stimPulseDuration = 0.253; % in mS
stimParameters.stim_type = {'Bipolar','biphasic'};

channInfo.bankInfo.bankA = 65:96;% Which NSX channels correspond to each bank 
channInfo.bankInfo.bankB = 97:128;
channInfo.bankInfo.bankC = 33:64;
channInfo.bankInfo.bankANSP = 1;% Which NSP (1 or 2) correspond to each bank 
channInfo.bankInfo.bankBNSP = 1;
channInfo.bankInfo.bankCNSP = 2;

% filename_chanListEMU = 'G:\BIDScodeTest\MG209\MG209revised_Chan_List.xlsx'; % Channel list (Neuralynx CSC files are loaded alphabetically, different from the EMU channel list order)
logFileDirectory = 'J:\StimDataBackup\Data_Stimulation\MG249\eTBS\Logfiles\'; % updated cerestim log file format
stimChNames = 'SYNC9'; 
perSessionEventsTSV_eTBS(directoryBIDS,sub_XXXX,taskName,ieeg_run,filenameNS3_nsp1,filenameNS3_nsp2,stimParameters,...
    channInfo,logFileDirectory,hdrNS3_nsp1,hdrNS3_nsp2)

% %% _events.json
% % create sub_XXXX\ses-postimp\ieeg\sub-XXXX_ses-postimp_task-NetworkWake1RAWNSP1_run-01_events.json
% stimLogFile = get_eTBSMatrix(logFileDirectory);
% stimParameters.stimPulseDuration = stimLogFile(:,10)/1000; % ms
% stimParameters.stimCurrent = stimLogFile(:,5)/1000; % mA
% 
% OperatingSystem = 'Windows 10';
% perSessionEventsJSON_eTBS(directoryBIDS,sub_XXXX,taskName,ieeg_run,OperatingSystem,stimParameters)







