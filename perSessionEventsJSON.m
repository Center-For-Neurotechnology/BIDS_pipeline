function perSessionEventsJSON(directoryBIDS,sub_XXXX,taskName,ieeg_run,OperatingSystem)

% {
%  "trial_type": { % obj 1
%   "LongName": "NetworkWake1",
%   "Description": "Stimulation",
%   "Levels": { % obj 1.a
%    "SinglePulseshort": "0.233ms duration single pulse stim, multiple current amplitudes, multiple locations",
%    "SinglePulselong": "1.053ms duration single pulse stim, 7mA current amplitudes, multiple locations",
%    "Train": "400ms duration, multiple frequencies from 10Hz to 200Hz, multiple locations"
%   }, % /obj 1.a
%   "Units": "n/a",
%   "TermURL": "https://github.com/Center-For-Neurotechnology/CereLAB"
%  }, % /obj 1
%  "identifier": { % obj 2
%   "LongName": "Intracranial direct electrical stimulation",
%   "Description": "Stimulation was controlled via a custom Cerestim API via MATLAB or a custom C++ code (https://github.com/Center-For-Neurotechnology/CereLAB).Waveforms of two different durations were used: .233 탎 duration: 90 탎 charge-balanced biphasic symmetrical pulses with an interphase interval of 53 탎ec with between 5 and 100 trials with a median of 20 trials per stimulation site across the data set .and 2) 1053 탎 (~1 msec) duration: 500 탎 charge-balanced biphasic symmetrical pulses with an interphase interval of 53 탎ec with between 10 and 26 trials per stimulation site with a median of 10 trials per site. .The interval at 53 ms was required as a hardware-limited minimum interval between square pulses with the CereStim stimulator. .For varying Current Amplitude tests, multiple current amplitudes were applied with the short duration (233 탎ec) bipolar stimulation at the following steps: 0.5 mA to 10 mA at 0.5 mA steps with a minimum of 10 trials per stimulation site. For train stimuli, each trial delivered a 400 ms train (90 ms charge-balanced biphasic symmetrical pulses with an interphase interval of 53 msec) with varying pulse frequencies (10-200 Hz) and amplitudes (0.5-10 mA)."
%  }, % /obj 2
%  "StimulusPresentation": {  % obj 3
%   "OperatingSystem": "Windows 10",
%   "SoftwareName": "CereStim API and CereLAB",
%   "SoftwareRRID": "xxx_xxx",
%   "SoftwareVersion": "n/a",
%   "Code": "https://github.com/Center-For-Neurotechnology/CereLAB"
%  } % /obj 3
% }

%% created filename


% sub_XXXX\ses-postimp\ieeg\sub-XXXX_ses-postimp_task-NetworkWake1RAWNSP1_run-01_events.json
filename_eventsJSON_nsp1 = [directoryBIDS,'/',sub_XXXX,'/ses-postimp/ieeg/',sub_XXXX,'_ses-postimp_task-',...
    taskName,'RAWNSP1_run-',ieeg_run,'_events.json'];
filename_eventsJSON_nsp2 = [directoryBIDS,'/',sub_XXXX,'/ses-postimp/ieeg/',sub_XXXX,'_ses-postimp_task-',...
    taskName,'RAWNSP2_run-',ieeg_run,'_events.json'];


%% obj 1
% obj 1.a

% struct_eventsJson.Levels = { 
%    "SinglePulseshort": "0.233ms duration single pulse stim, multiple current amplitudes, multiple locations",
%    "SinglePulselong": "1.053ms duration single pulse stim, 7mA current amplitudes, multiple locations",
%    "Train": "400ms duration, multiple frequencies from 10Hz to 200Hz, multiple locations"
%   };

%  "trial_type": { % obj 1
%   "LongName": "NetworkWake1",
%   "Description": "Stimulation",
%   
%   "Levels": { % obj 1.a
%    "SinglePulseshort": "0.233ms duration single pulse stim, multiple current amplitudes, multiple locations",
%    "SinglePulselong": "1.053ms duration single pulse stim, 7mA current amplitudes, multiple locations",
%    "Train": "400ms duration, multiple frequencies from 10Hz to 200Hz, multiple locations"
%   }, % /obj 1.a
%   
%   "Units": "n/a",
%   "TermURL": "https://github.com/Center-For-Neurotechnology/CereLAB"
%  }, % /obj 1


struct_eventsJson.trial_type.LongName = taskName;
struct_eventsJson.trial_type.Description = "Stimulation";

struct_eventsJson.trial_type.Levels.SinglePulseshort = "0.233ms duration single pulse stim, multiple current amplitudes, multiple locations";
struct_eventsJson.trial_type.Levels.SinglePulselong = "1.053ms duration single pulse stim, 7mA current amplitudes, multiple locations";
struct_eventsJson.trial_type.Levels.Train = "400ms duration, multiple frequencies from 10Hz to 200Hz, multiple locations";

struct_eventsJson.trial_type.Units = "n/a";
struct_eventsJson.trial_type.TermURL = "https://github.com/Center-For-Neurotechnology/CereLAB";


%% obj 2
%  "identifier": { % obj 2
%   "LongName": "Intracranial direct electrical stimulation",
%   "Description": "Stimulation was controlled via a custom Cerestim API via MATLAB or a custom C++ code (https://github.com/Center-For-Neurotechnology/CereLAB).Waveforms of two different durations were used: .233 탎 duration: 90 탎 charge-balanced biphasic symmetrical pulses with an interphase interval of 53 탎ec with between 5 and 100 trials with a median of 20 trials per stimulation site across the data set .and 2) 1053 탎 (~1 msec) duration: 500 탎 charge-balanced biphasic symmetrical pulses with an interphase interval of 53 탎ec with between 10 and 26 trials per stimulation site with a median of 10 trials per site. .The interval at 53 ms was required as a hardware-limited minimum interval between square pulses with the CereStim stimulator. .For varying Current Amplitude tests, multiple current amplitudes were applied with the short duration (233 탎ec) bipolar stimulation at the following steps: 0.5 mA to 10 mA at 0.5 mA steps with a minimum of 10 trials per stimulation site. For train stimuli, each trial delivered a 400 ms train (90 ms charge-balanced biphasic symmetrical pulses with an interphase interval of 53 msec) with varying pulse frequencies (10-200 Hz) and amplitudes (0.5-10 mA)."
%  }, % /obj 2

struct_eventsJson.identifier.LongName = "Intracranial direct electrical stimulation";
struct_eventsJson.identifier.Description = ['Stimulation was controlled via a custom Cerestim API via MATLAB or a',...
    ' custom C++ code (https://github.com/Center-For-Neurotechnology/CereLAB).Waveforms of two different',...
    ' durations were used: .233 탎 duration: 90 탎 charge-balanced biphasic symmetrical pulses with an interphase',...
    ' interval of 53 탎ec with between 5 and 100 trials with a median of 20 trials per stimulation site across the',...
    ' data set .and 2) 1053 탎 (~1 msec) duration: 500 탎 charge-balanced biphasic symmetrical pulses with an',...
    ' interphase interval of 53 탎ec with between 10 and 26 trials per stimulation site with a median of 10 trials',...
    ' per site. .The interval at 53 ms was required as a hardware-limited minimum interval between square pulses',...
    ' with the CereStim stimulator. .For varying Current Amplitude tests, multiple current amplitudes were applied',...
    ' with the short duration (233 탎ec) bipolar stimulation at the following steps: 0.5 mA to 10 mA at 0.5 mA steps',...
    ' with a minimum of 10 trials per stimulation site. For train stimuli, each trial delivered a 400 ms train',...
    ' (90 ms charge-balanced biphasic symmetrical pulses with an interphase interval of 53 msec) with varying',...
    ' pulse frequencies (10-200 Hz) and amplitudes (0.5-10 mA).'];


%% obj 3
%  "StimulusPresentation": {  % obj 3
%   "OperatingSystem": "Windows 10",
%   "SoftwareName": "CereStim API and CereLAB",
%   "SoftwareRRID": "xxx_xxx",
%   "SoftwareVersion": "n/a",
%   "Code": "https://github.com/Center-For-Neurotechnology/CereLAB"
%  } % /obj 3

struct_eventsJson.StimulusPresentation.OperatingSystem = OperatingSystem;
struct_eventsJson.StimulusPresentation.SoftwareName = "CereStim API and CereLAB";
struct_eventsJson.StimulusPresentation.SoftwareRRID = "xxx_xxx";
struct_eventsJson.StimulusPresentation.SoftwareVersion = "n/a";
struct_eventsJson.StimulusPresentation.Code = "https://github.com/Center-For-Neurotechnology/CereLAB";


%% create json files
json_helper(filename_eventsJSON_nsp1, struct_eventsJson)
json_helper(filename_eventsJSON_nsp2, struct_eventsJson)

end

