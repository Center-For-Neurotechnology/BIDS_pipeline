function perSessionEventsJSONSeizure(directoryBIDS,sub_XXXX,taskName,ieeg_run,OperatingSystem)
% {

% }

%% created filename
% sub_XXXX\ses-postimp\ieeg\sub-XXXX_ses-postimp_task-NetworkWake1RAWNSP1_run-01_events.json

filename_eventsJSON_edf = [directoryBIDS,'/',sub_XXXX,'/ses-postimp/ieeg/',sub_XXXX,'_ses-postimp_task-',...
    taskName,'RAWEDF_run-',ieeg_run,'_events.json'];



%% obj 1
struct_eventsJson.trial_type.LongName = taskName;
struct_eventsJson.trial_type.Description = "Seizure";

struct_eventsJson.trial_type.Levels.SinglePulseshort = "n/a";
struct_eventsJson.trial_type.Levels.SinglePulselong = "n/a";
struct_eventsJson.trial_type.Levels.Train = "n/a";

struct_eventsJson.trial_type.Units = "n/a";
struct_eventsJson.trial_type.TermURL = "n/a";


%% obj 2
struct_eventsJson.identifier.LongName = "Seizure";
struct_eventsJson.identifier.Description = ['Seizure data were clipped from ongoing recordings ',...
    ' from intracranial leads during the course of clinical care of patients with intractable epilepsy ',...
    ' The timing onset and offset as well as channel onset of the seizures per recording are indicated in the .tsv file. '];


%% obj 3
struct_eventsJson.StimulusPresentation.OperatingSystem = OperatingSystem;
struct_eventsJson.StimulusPresentation.SoftwareName = "n/a";
struct_eventsJson.StimulusPresentation.SoftwareRRID = "xxx_xxx";
struct_eventsJson.StimulusPresentation.SoftwareVersion = "n/a";
struct_eventsJson.StimulusPresentation.Code = "n/a";


%% create json files
json_helper(filename_eventsJSON_edf, struct_eventsJson)

end

