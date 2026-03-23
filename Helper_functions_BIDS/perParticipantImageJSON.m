function perParticipantImageJSON(sub_XXXX, preImplantScan, postImplantScan, directoryBIDS)
% this function is run once for each patient. It creates two json files
% containing information about the preimplant and postimplant scan. The json files will be
% saved in directoryBIDS/sub_XXXX/ses-preimp/anat and directoryBIDS/sub_XXXX/ses-postimp/anat
% and have the name sub-XXXX_ses-preimp_acq-CT_run-01_T1w.json and sub-XXXX_ses-postimp_acq-T1w_run-01_T1w.json
% depending on if the scan was CT or MRI
% INPUTS:
%   - sub_XXXX: string of the deidentified patient ID
%   - preImplantScan: string of preimplant scan type
%   - postImplantScan: string of postimplant scan stype
%   - directoryBIDS: string of the main folder where the BIDS data is being saved
% OUTPUTS: 
%   - sub-XXXX_ses-preimp_acq-CT_run-01_T1w.json
%   - sub-XXXX_ses-postimp_acq-T1w_run-01_T1w.json
%% create json file names
if strcmp(preImplantScan, 'MRI')
    preImplantScan = 'T1w';
end
if strcmp(postImplantScan, 'MRI')
    postImplantScan = 'T1w';
end
filename_preImplantScan =  [directoryBIDS,'/',sub_XXXX,'/ses-preimp/anat/',sub_XXXX,'_ses-preimp_acq-',preImplantScan,'_run-01_T1w.json'];
filename_postImplantScan = [directoryBIDS,'/',sub_XXXX,'/ses-postimp/anat/',sub_XXXX,'_ses-postimp_acq-',postImplantScan,'_run-01_T1w.json'];

%% set json values
% REQUIRED if corresponding fieldmap data is present or when using multiple runs with different phase encoding directions 
struct_scanJson.PhaseEncodingDirection = 'n/a';
% REQUIRED if corresponding fieldmap data is present
struct_scanJson.EffectiveEchoSpacing = 'n/a';
% REQUIRED if corresponding field/distortion maps acquired with opposing phase encoding directions are present
struct_scanJson.TotalReadoutTime = 'n/a';
% REQUIRED if corresponding fieldmap data is present or the data comes from a multi echo sequence
struct_scanJson.EchoTime = 'n/a';
% REQUIRED for sparse sequences that do not have the DelayTime field set.
struct_scanJson.SliceTiming = 'n/a';

%% call json_helper() to save json files
json_helper(filename_preImplantScan, struct_scanJson)
json_helper(filename_postImplantScan, struct_scanJson)


end