
anat_json.PhaseEncodingDirection = 'n/a';
anat_json.EffectiveEchoSpacing = 'n/a';
anat_json.TotalReadoutTime = 'n/a';
anat_json.EchoTime = 'n/a';
anat_json.SliceTiming = 'n/a';

acquisition = 'anat';
% Preimplant scan folder and copy file. These data should be defaced.
preimpMRI = fullfile(root_dir, project_label,['sub-' ieeg_sub], ['ses-' 'preimp'], ['anat']);
if ~exist(preimpMRI,'dir')
    mkdir(preimpMRI);    % J: create directory before call to avoid error message confusion
end 
acq_id = 'T1w';
ieeg_sesanat='preimp'; 

anat_json_name = fullfile(root_dir, project_label,['sub-' ieeg_sub],['ses-' ieeg_sesanat], acquisition, ...
                          ['sub-' ieeg_sub, '_ses-' ieeg_sesanat, '_acq-' acq_id, '_run-' '01' '_T1w.json']);
json_helper(anat_json_name, anat_json)
preimpMRIName = fullfile(['sub-' ieeg_sub,'_ses-' ieeg_sesanat,'_acq-' acq_id, '_run-' '01' '_T1w.nii']);
copyfile([Maindir,PatientName,'\',MRIDir(1).name],[preimpMRI,'\',preimpMRIName])

% Postimplant scan which can be CT or MRI. Requires the same steps as the preimplant scan. These data should be defaced.
postimpscan = fullfile(root_dir, project_label,['sub-' ieeg_sub], ['ses-' 'postimp'], ['anat']);
if ~exist(postimpscan,'dir')
    mkdir(postimpscan);  
end 
if DI<72 
    acq_id = 'CT';  
end
ieeg_sesanat='postimp';  % J: was previously named 'preimp'

anat_json_name = fullfile(root_dir, project_label,['sub-' ieeg_sub],['ses-' ieeg_sesanat], acquisition, ...
                          ['sub-' ieeg_sub, '_ses-' ieeg_sesanat, '_acq-' acq_id, '_run-' '01' '_T1w.json']);
json_helper(anat_json_name, anat_json)
postimpMRIName = fullfile(['sub-' ieeg_sub,'_ses-' ieeg_sesanat, '_acq-' acq_id,'_run-' '01' '_T1w.nii']);
copyfile([Maindir,PatientName,'\',PostopMRIDir(1).name],[postimpscan,'\',postimpMRIName])
