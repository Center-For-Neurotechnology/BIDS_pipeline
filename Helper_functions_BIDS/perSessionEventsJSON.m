function perSessionEventsJSON(directoryBIDS,sub_XXXX,taskName,ieeg_run,OperatingSystem,stimParameters)
% {

% }

%% created filename
% sub_XXXX\ses-postimp\ieeg\sub-XXXX_ses-postimp_task-NetworkWake1RAWNSP1_run-01_events.json
filename_eventsJSON = [directoryBIDS,'/',sub_XXXX,'/ses-postimp/ieeg/',sub_XXXX,'_ses-postimp_task-',...
    taskName,'RAW_run-',ieeg_run,'_events.json'];



%% obj 1
struct_eventsJson.trial_type.LongName = taskName;
struct_eventsJson.trial_type.Description = 'Stimulation';


% set stim waveform from stimParameters
struct_eventsJson.trial_type.Levels.SinglePulseshort = [num2str(stimParameters.stimPulseDuration), 'ms duration single pulse stim, ', num2str(stimParameters.stimCurrent),...
    'mA current amplitude, multiple locations.'];

struct_eventsJson.trial_type.Units = 'n/a';
struct_eventsJson.trial_type.TermURL = 'https://github.com/Center-For-Neurotechnology/CereLAB';


%% obj 2
struct_eventsJson.identifier.LongName = 'Intracranial direct electrical stimulation';
% TODO: make the stim description dynamic
struct_eventsJson.identifier.Description = ['Stimulation was controlled via a custom Cerestim API via MATLAB or a',...
    ' custom C++ code (https://github.com/Center-For-Neurotechnology/CereLAB).',...
    ' The stimulation waveform had a duration of .233 us: 90 us charge-balanced biphasic symmetrical pulses with an interphase',...
    ' interval of 53 us. The 53 us interval was required as a hardware-limited minimum interval between square pulses',...
    ' with the CereStim stimulator.'];


%% obj 3
struct_eventsJson.StimulusPresentation.OperatingSystem = OperatingSystem;
struct_eventsJson.StimulusPresentation.SoftwareName = 'CereStim API and CereLAB';
struct_eventsJson.StimulusPresentation.SoftwareRRID = 'xxx_xxx';
struct_eventsJson.StimulusPresentation.SoftwareVersion = 'n/a';
struct_eventsJson.StimulusPresentation.Code = 'https://github.com/Center-For-Neurotechnology/CereLAB';


%% create json files
json_helper(filename_eventsJSON, struct_eventsJson)

end

