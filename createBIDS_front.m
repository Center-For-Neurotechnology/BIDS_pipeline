Tarzan1_drive = 'W'; % assumes access to tarzan1
Maindir=[Tarzan1_drive,':\StimDataBackup\Data_Stimulation\']; % where your FT_Analyzed data is
Bidsfolder='W:\StimDataBackup\Data_Stimulation\jackie_pipeline_testing'; % full path where your new bids files will be saved
HPStimFileList_2 = 'E:\BIDStesting\dependencies\HPStimFileList_2.xlsx'; % excel file with sheets (MasterList and Sheet1)
DI=76; % patient number 

% channel type ranges:
sEEG_channels = 1:124;
scalp_channels = [];
triggers_channels = [];

iEEGCoordinateSys = 'ACPC'; % Defines the coordinate system for the iEEG electrodes.
iEEGCoordinateUnits = 'mm'; % Units of the _electrodes.tsv, MUST be "m", "mm", "cm" or "pixels".

create_edf = 1; % writes brainvision data by default, indicate if you'd like edf data as well

createBIDS_back

