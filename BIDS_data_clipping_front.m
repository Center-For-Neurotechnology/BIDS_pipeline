%% Setting up raw nsx file path and result path
pName = 'MG169'; % patient
resultsPath =  ['E:\BIDStesting\nsx_results',filesep,pName]; % the results path to save the new clipped nsx files in

% ns3 files (nsp1 and nsp2) to be clipped clip
file_being_split = '10-083607-003';  % the file that will be clipped, just to create a results path for this specific file split
fileNameNSxPerNSP{1} = 'E:\BIDStesting\local_data\MG169\StimulationDay3\NSP1\10-083607-003.ns3';
fileNameNSxPerNSP{2} = 'E:\BIDStesting\local_data\MG169\StimulationDay3\NSP2\10-083608-003.ns3';

fileNameNEVPerNSP{1} = 'E:\BIDStesting\local_data\MG169\StimulationDay3\NSP1\10-083607-003.nev';
fileNameNEVPerNSP{2} = 'E:\BIDStesting\local_data\MG169\StimulationDay3\NSP2\10-083608-003.nev';

selChName1 = [35,36,82,83];%  % bipolar ch numbers to visualize in clipping plot
buffer_time_minutes = 1; % time buffer (in minutes) before and after each session

%% calling function that does the clipping
gettingClipTimes(p Name,resultsPath,fileNameNSxPerNSP,fileNameNEVPerNSP,file_being_split,selChName1,buffer_time_minutes);


