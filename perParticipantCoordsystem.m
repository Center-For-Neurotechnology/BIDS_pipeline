function perParticipantCoordsystem(sub_XXXX, filename_MRI, directoryBIDS)
% this function is run once for each patient. It creates a json file
% containing a description of the coordinate system. The json file will be
% saved in directoryBIDS/sub_XXXX/ses-postimp/ieeg and have the name
% sub-XXXX_ses-postimp_coordsystem.json
% INPUTS:
%   - sub_XXXX: string of the deidentified patient ID
%   - filenameMRI: string of MRI .nii file name in BIDS format
%   - directoryBIDS: string of the main folder where the BIDS data is being saved
% OUTPUTS: 
%   - sub-XXXX_ses-postimp_coordsystem.json


%% create json file name (sub-XXXX_ses-postimp_coordsystem.json)
filename_coordJson = [directoryBIDS,'/',sub_XXXX,'/ses-postimp/ieeg/',sub_XXXX,'_ses-postimp_coordsystem.json'];

%% create json structure
% Required values::
% Defines the coordinate system for the iEEG electrodes.
struct_coordJson.iEEGCoordinateSystem = 'ACPC'; 
% Units of the _electrodes.tsv, MUST be "m", "mm", "cm" or "pixels".
struct_coordJson.iEEGCoordinateUnits = 'mm'; 
% Recommended values:
struct_coordJson.iEEGCoordinateProcessingDescripton = ['Coordinate system with the origin at anterior commissure (AC)',...
          ' negative y-axis going through the posterior commissure (PC), z-axis going to a mid-hemisperic point which',...
          ' lies superior to the AC-PC line, x-axis going to the right']; 
% MRI/CT or a file containing the operative photo
struct_coordJson.IntendedFor = filename_MRI; 
% Has any projection been done on the electrode positions (for example: "surface_projection", "none").
struct_coordJson.iEEGCoordinateProcessingDescription = ['Following implant, the preoperative T1-weighted MRI was aligned',...
          ' with a postoperative CT or MRI using volumetric image coregistration procedures and FreeSurfer scripts',...
          ' (http://surfer.nmr.mgh.harvard.edu). Electrode coordinates were manually determined from the CT or postoperative',...
          ' MRI in the patients’ native space and mapped using an electrode labeling algorithm (ELA) that registered each',...
          ' contact to a standardized cortical map. Surface projection for grid and strip electrodes was done using the ',...
          ' snapgrid code in iElvis (https://github.com/iELVis/iELVis)']; 
% paper that the defines the method used to project/localize the electrodes
struct_coordJson.iEEGCoordinateProcessingReference = ['Original reconstructions done using Dykstra AR, Chan AM, Quinn BT,',...
          ' Zepeda R, Keller CJ, Cormier J, Madsen JR, Eskandar EN, Cash SS (2012) Individualized localization and cortical',...
          ' surface-based registration of intracranial electrodes. Neuroimage 59:3563–3570. code in iElvis',...
          ' (https://github.com/iELVis/iELVis) was used for projecting the grid or strip electrodes Further mapping was done',...
          ' using MMVT (https://github.com/pelednoam/mmvt) and mapped using an electrode labeling algorithm',...
          ' (ELA; https://github.com/pelednoam/ieil)'];

%% call json_helper() to save json file
json_helper(filename_coordJson, struct_coordJson)

end