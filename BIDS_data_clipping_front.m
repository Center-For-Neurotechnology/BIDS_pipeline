%% Setting up raw nsx file path and result path
pName = 'MGxxx'; % patient
resultsPath =  ['E:\BIDStesting\nsx_results',filesep,pName]; % the results path to save the new clipped nsx files in

% ns3 files (nsp1 and nsp2) to be clipped clip
file_being_split = '10-083607-003';  % the file that will be clipped, just to create a results path for this specific file split
fileNameNSxPerNSP{1} = 'E:\BIDStesting\local_data\MGxxx\StimulationDay3\NSP1\10-083607-003.ns3';
fileNameNSxPerNSP{2} = 'E:\BIDStesting\local_data\MGxxx\StimulationDay3\NSP2\10-083608-003.ns3';

fileNameNEVPerNSP{1} = 'E:\BIDStesting\local_data\MGxxx\StimulationDay3\NSP1\10-083607-003.nev';
fileNameNEVPerNSP{2} = 'E:\BIDStesting\local_data\MGxxx\StimulationDay3\NSP2\10-083608-003.nev';

selChName1 = [35,36,82,83];%  % bipolar ch numbers to visualize in clipping plot
buffer_time_minutes = 5; % time buffer (in minutes) before and after each session



%% set uo BIDS directories
directoryBIDS = 'E:\BIDStesting\BIDS_data'; % directoryBIDS/sub_XXXX/ses-postimp/ieeg
%% 0. Config files
% create directoryBIDS/sub_XXXX/ses-postimp/ieeg/sub-XXXX_ses-postimp_coordsystem.json
perParticipantCoordsystem(sub_XXXX, filename_MRI, directoryBIDS) 

%% 1. calling function that does the clipping
nsxFileWithclippedData = gettingClipTimes(pName,resultsPath,fileNameNSxPerNSP,fileNameNEVPerNSP,file_being_split,selChName1,buffer_time_minutes);


%% 2. Remove bad channels
badChannelsList = functionToRemoveBadChannels(matFileWithclippedData)


%% 3. Create the BIDS format 
createBIDS(nsxFileWithclippedData, badChannelsList, json_filename )

%% 4. BIDS to Fieldtrip w/trial based 

%% 


