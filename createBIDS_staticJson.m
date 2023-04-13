electrodes_json_name = fullfile(root_dir, project_label,['sub-' ieeg_sub], ['ses-' ieeg_ses], 'ieeg', ...
                                ['sub-' ieeg_sub, '_ses-' ieeg_ses,'_coordsystem.json']);

%% Required fields
loc_json.iEEGCoordinateSystem = iEEGCoordinateSys; % Defines the coordinate system for the iEEG electrodes.
loc_json.iEEGCoordinateUnits = iEEGCoordinateUnits; % Units of the _electrodes.tsv, MUST be "m", "mm", "cm" or "pixels".

%% Recommended fields
loc_json.iEEGCoordinateProcessingDescripton = 'Coordinate system with the origin at anterior commissure (AC), negative y-axis going through the posterior commissure (PC), z-axis going to a mid-hemisperic point which lies superior to the AC-PC line, x-axis going to the right'; 
loc_json.IntendedFor = [postimpMRIName]; % This can be an MRI/CT or a file containing the operative photo, x-ray
% or drawing with path relative to the project folder
loc_json.iEEGCoordinateProcessingDescription = ['Following implant, the preoperative T1-weighted MRI was aligned with a postoperative CT or MRI using volumetric image coregistration procedures and FreeSurfer scripts (http://surfer.nmr.mgh.harvard.edu). ',...
    'Electrode coordinates were manually determined from the CT or postoperative MRI in the patients’ native space and mapped using an electrode labeling algorithm (ELA) that registered each contact to a standardized cortical map. ',...
    'Surface projection for grid and strip electrodes was done using the snapgrid code in iElvis (https://github.com/iELVis/iELVis)']; % Has any projection been done on the electrode positions
% (for example: "surface_projection", "none").
loc_json.iEEGCoordinateProcessingReference = ['Original reconstructions done using Dykstra AR, Chan AM, Quinn BT, Zepeda R, Keller CJ, Cormier J, Madsen JR, Eskandar EN, Cash SS (2012) Individualized localization and cortical surface-based registration of intracranial electrodes. Neuroimage 59:3563–3570. ',...
'code in iElvis (https://github.com/iELVis/iELVis) was used for projecting the grid or strip electrodes ',...
'Further mapping was done using MMVT (https://github.com/pelednoam/mmvt) and mapped using an electrode labeling algorithm (ELA; https://github.com/pelednoam/ieil)']; % A reference to a paper that defines in more detail'}
% the method used to project or localize the electrodes

json_helper(electrodes_json_name, loc_json)

%% General fields, shared with MRI BIDS and MEG BIDS:
 ieeg_json_name = fullfile(root_dir,project_label, ['sub-' ieeg_sub],['ses-' ieeg_ses], 'ieeg', ...
                        ['sub-' ieeg_sub,'_ses-' ieeg_ses,'_task-' ieeg_task,'_run-' ieeg_run '_ieeg.json']);
%% Required fields:
ieeg_json.TaskName = TaskName; % Name of the task (for resting state use the rest prefix)
ieeg_json.SamplingFrequency = FS1; % Sampling frequency (in Hz) of all the iEEG channels in the recording
ieeg_json.PowerLineFrequency = 60; % Frequency (Hz) of the power grid where the iEEG recording was done
ieeg_json.SoftwareFilters = 'n/a'; % key:value pairs of filters and their parameter values, (n/a if none)

%% Recommended fields:
HardwareFilters.HighpassFilter.CutoffFrequency = 0.3; % high pass hardware filter cut off frequency.
HardwareFilters.LowpassFilter.CutoffFrequency = 7500; % low pass hardware filter cut off frequency.
ieeg_json.HardwareFilters = HardwareFilters;
ieeg_json.Manufacturer = 'Blackrock Microsystems'; % Manufacturer of the amplifier system
ieeg_json.ManufacturersModelName = 'Neural Signal Processor (Cerebus), FrontEnd amplifiers, CereStim stimulator'; % Manufacturer's designation of the iEEG amplifier model
ieeg_json.TaskDescription = 'Stimulation was delivered with a CereStim stimulator (Blackrock Microsystems, Salt Lake City, UT) using single pulse electrical stimulation (SPES). Current injection and return paths used neighboring contacts in a bipolar configuration.'; % Longer description of the task.
ieeg_json.Instructions = 'A trained electroencephalographer examined ongoing recordings for epileptiform activity and asked participants if they experienced any sensations. The participants were awake and were aware that they were being stimulated but were blind to the stimulation timing and parameters.'; % Text of the instructions given to participants
% before the recording.
ieeg_json.CogAtlasID = 'https://www.sciencedirect.com/science/article/pii/S1935861X22000456'; % URL of the corresponding Cognitive Atlas Task term
ieeg_json.CogPOID = 'https://www.sciencedirect.com/science/article/pii/S1935861X22000456'; % URL of the corresponding CogPO term
ieeg_json.InstitutionName = 'Massachusetts General Hospital'; % The name of the institution in charge of the equipment that produced the composite instances.
ieeg_json.InstitutionAddress = '55 Fruit St., Boston, MA 02114, USA'; % The address of the institution
ieeg_json.DeviceSerialNumber = 'n/a'; % The serial number of the equipment, a pseudonym can also be used as long as each pseudonym is unique within the dataset.
ieeg_json.ECOGChannelCount = ECogChanNum; % Number of iEEG surface channels included in the recording
ieeg_json.SEEGChannelCount = sEEGChanNum; % Number of iEEG depth channels included in the recording
ieeg_json.EEGChannelCount = EEGChanNum; % Number of scalp EEG channels recorded simultaneously
ieeg_json.EOGChannelCount = EOGChanNum; % Number of EOG channels
ieeg_json.ECGChannelCount = ECGChanNum; % Number of ECG channels
ieeg_json.EMGChannelCount = EMGChanNum; % Number of EMG channels
ieeg_json.MiscChannelCount = MiscChannelCount; % Number of miscellaneous analog channels for auxiliary signals
ieeg_json.TriggerChannelCount = round(TriggerChannelCount); % Number of channels for digital (TTL bit level) triggers.
ieeg_json.RecordingDuration = (RecordingDuration)/FS1; % Length of the recording in seconds
ieeg_json.RecordingType = RecordingType; % Defines whether the recording is "continuous" or "epoched"
if strmatch(RecordingType,'epoched')==1
 ieeg_json.EpochLength = [num2str(EpochLength)]; % Duration of individual epochs in seconds if epoched
end
ieeg_json.SubjectArtefactDescription = 'n/a'; % Freeform description of subject artefact and cause

%% Specific iEEG fields:
%% Required fields:
ieeg_json.iEEGReference = iEEGReference; % General description of the reference scheme used

%% Recommended fields:
ieeg_json.ElectrodeManufacturer = ElectrodeManufacturer; % can be used if all electrodes are of the same manufacturer
ieeg_json.iEEGGround = iEEGGround; % Description of the location of the ground electrode
ieeg_json.iEEGPlacementScheme = iEEGPlacementScheme; % Freeform description of the placement of the iEEG electrodes
ieeg_json.iEEGElectrodeGroups = GroupList; % Field to describe the way electrodes are grouped

%% Optional fields:
ieeg_json.ElectricalStimulation = true; % Boolean to specify if electrical stimulation was done during the recording
ieeg_json.ElectricalStimulationParameters = ['Stimulation was controlled via a custom Cerestim API via MATLAB or a custom C++ code (https://github.com/Center-For-Neurotechnology/CereLAB).',... 
'Waveforms of two different durations were used: .',...
'233 µs duration: 90 µs charge-balanced biphasic symmetrical pulses with an interphase interval of 53 µsec with between 5 and 100 trials with a median of 20 trials per stimulation site across the data set .',...
'and 2) 1053 µs (~1 msec) duration: 500 µs charge-balanced biphasic symmetrical pulses with an interphase interval of 53 µsec with between 10 and 26 trials per stimulation site with a median of 10 trials per site. .',...
'The interval at 53 ms was required as a hardware-limited minimum interval between square pulses with the CereStim stimulator. .',...
'For varying Current Amplitude tests, multiple current amplitudes were applied with the short duration (233 µsec) bipolar stimulation at the following steps: 0.5 mA to 10 mA at 0.5 mA steps with a minimum of 10 trials per stimulation site. ']; % Free form description of stimulation parameters,

json_helper(ieeg_json_name, ieeg_json)
