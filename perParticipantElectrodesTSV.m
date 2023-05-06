function perParticipantElectrodesTSV(sub_XXXX, filename_RAS, directoryBIDS)
% this function is run once for each patient. It creates a tsv file
% containing information about the electrodes. The tsv file will be
% saved in directoryBIDS/sub_XXXX/ses-postimp/ieeg and have the name
% sub-XXXX_ses-postimp_electrodes.tsv
% INPUTS:
%   - sub_XXXX: string of the deidentified patient ID
%   - filename_RAS: string of the spreadsheet with the electrode info
%   - directoryBIDS: string of the main folder where the BIDS data is being saved
% OUTPUTS: 
%   - sub-XXXX_ses-postimp_electrodes.tsv


%% create tsv file name (sub-XXXX_ses-postimp_electrodes.tsv)
filename_electrodesTsv = [directoryBIDS,'/',sub_XXXX,'/ses-postimp/ieeg/',sub_XXXX,'_ses-postimp_electrodes.tsv'];

%% create tsv values
electrodeInfo_RAS = readtable(filename_RAS);
% required columns
name = electrodeInfo_RAS(:,1); % Name of the electrode contact point
x = electrodeInfo_RAS(:,2); % X position. The positions of the center of each electrode in xyz space.% Units are in millimeters or pixels and are specified in _*space-<label>_electrode.json.
y = electrodeInfo_RAS(:,3); % Y position.
z = electrodeInfo_RAS(:,4); % Z position. If electrodes are in 2D space this should be a column of n/a values.
size = electrodeInfo_RAS(:,7); % Surface area in mm^2 A=2πrh+2πr2
% recommended columns
material = repmat({'n/a'},size(electrodeInfo_RAS,1),1); % J: NEED TO FIND THIS INFO % Material of the electrodes
manufacturer = electrodeInfo_RAS(:,6);  % Optional field to specify the electrode manufacturer for each electrode. Can be used if electrodes were manufactured by more than one company.
group = electrodeInfo_RAS(:,8); % Optional field to specify the group that the electrode is a part of.  Note that any group specified here should match a group specified in `_channels.tsv`
hemisphere = electrodeInfo_RAS(:,9); % Optional field to specify the hemisphere in which the electrode is placed, one of ["L" or "R"] (use capital).
%optional columns
type = repmat({'n/a'},size(electrodeInfo_RAS,1),1); % Optional type of the electrode,for example:cup, ring, clip-on, wire, needle, ...
impedance = repmat({'n/a'},size(electrodeInfo_RAS,1),1); % Impedance of the electrode in kOhm.

%% saving as .tsv
tsv_values = table(name, x, y, z, size, material, manufacturer, group, hemisphere, type, impedance);
writetable(tsv_values, filename_electrodesTsv, 'FileType', 'text', 'Delimiter', '\t');


end