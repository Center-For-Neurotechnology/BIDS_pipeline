Maindir = 'W:\StimDataBackup\Data_Stimulation\'; % where your FT_Analyzed data is
Bidsfolder = 'W:\StimDataBackup\Data_Stimulation\DeIdentifiedDataSet'; % full path where your new bids files will be saved

patient_id_map = 'E:\BIDStesting\local_data\MGxxx\MGxxx_name_id.xlsx'; % sheet containing patient ID info
create_edf = 1; % writes brainvision data by default, indicate if you'd like edf data as well

% Text of the instructions given to participants before the recording.
notes_on_instructions = ['A trained electroencephalographer examined ongoing recordings for epileptiform activity and ',...
    'asked participants if they experienced any sensations. The participants were awake and were aware that they were ',...
    'being stimulated but were blind to the stimulation timing and parameters.']; 

post_imp_scan = 'MRI'; % Postimplant scan which can be CT or MRI, typically CT for DI < 72 and MRI for DI => 72

% channel type ranges
sEEG_channels = 1:124;
scalp_channels = [];
triggers_channels = [];

iEEGCoordinateSys = 'ACPC'; % Defines the coordinate system for the iEEG electrodes.
iEEGCoordinateUnits = 'mm'; % Units of the _electrodes.tsv, MUST be "m", "mm", "cm" or "pixels".

createBIDS_back

