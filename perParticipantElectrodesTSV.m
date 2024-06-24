function perParticipantElectrodesTSV(sub_XXXX, filename_RAS, directoryBIDS)
% This function is run once for each patient. It creates a tsv file
% containing the location, size and other properties of iEEG electrodes.
% The tsv file will be saved in directoryBIDS/sub_XXXX/ses-postimp/ieeg
% and have the name sub-XXXX_ses-postimp_electrodes.tsv
% INPUTS:
%   - sub_XXXX: string of the deidentified patient ID
%   - filename_RAS: string of the spreadsheet with the electrode info
%   - directoryBIDS: string of the main folder where the BIDS data is being saved
% OUTPUTS: 
%   - sub-XXXX_ses-postimp_electrodes.tsv


%% create tsv file name (sub-XXXX_ses-postimp_electrodes.tsv)
filename_electrodesTSV = [directoryBIDS,'/',sub_XXXX,'/ses-postimp/ieeg/',sub_XXXX,'_ses-postimp_electrodes.tsv'];


%% create tsv values
% % electrodeInfo_RAS = readtable(filename_RAS);
RASdata = importdata(filename_RAS);
name=RASdata.textdata(2:end,1);
x=RASdata.data(1:end,1);
y=RASdata.data(1:end,2);
z=RASdata.data(1:end,3);
% type=test_RAS(:,5);
manufacturer=RASdata.textdata(2:end,6);
size_var=RASdata.data(1:end,6);
group=RASdata.textdata(2:end,8);
hemisphere=RASdata.textdata(2:end,9);
% required columns
% % name = electrodeInfo_RAS(:,1); % Name of the electrode contact point (ie. RAMY1)
% The positions of the center of each electrode in xyz space. 
% Units are in millimeters or pixels and are specified in _*space-<label>_electrode.json.
% % x = electrodeInfo_RAS(:,2); % X position.
% % y = electrodeInfo_RAS(:,3); % Y position.
% % z = electrodeInfo_RAS(:,4); % Z position. (If electrodes are in 2D space this should be a column of n/a values.)
% % size = electrodeInfo_RAS(:,7); % Surface area in mm^2
% recommended columns
material = repmat({'n/a'},size(name));%height(electrodeInfo_RAS),1); % electrode material
% % manufacturer = electrodeInfo_RAS(:,6); % electrode manufacturer for each electrode
% % group = electrodeInfo_RAS(:,8); % group that the electrode is a part of (any group here should match a group in '_channels.tsv')
% % hemisphere = electrodeInfo_RAS(:,9); % specify the hemisphere in which the electrode is placed, one of ["L" or "R"] (use capital)
%optional columns
type = repmat({'n/a'},size(name));%height(electrodeInfo_RAS),1); % electrode type,for example:cup, ring, clip-on, wire, needle, ...
impedance = repmat({'n/a'},size(name));%height(electrodeInfo_RAS),1); % electrode impedance in kOhm.

%% saving as .tsv
varNames = {'name','x','y','z','size','material','manufacturer','group',...
    'hemisphere','type','impedance'};
table_electrodesTSV = table(name, x, y, z, size_var, material, manufacturer, group, hemisphere, type, impedance,'VariableNames',varNames);
% table_electrodesTSV.Properties.VariableNames = varNames;
% table_electrodesTSV = renamevars(table_electrodesTSV,1:width(table_electrodesTSV),varNames);
% writetable(splitvars(table_electrodesTSV), filename_electrodesTSV, 'FileType', 'text', 'Delimiter', '\t');

writetable(table_electrodesTSV, filename_electrodesTSV, 'FileType', 'text', 'Delimiter', '\t');

end