% Setting up raw nsx file path and result path
pName = 'MG90b'; % patient
resultsPath =  ['E:\BIDStesting\nsx_results',filesep,pName]; % the results path to save the new clipped nsx files in

% ns3 files (nsp1 and nsp2) to be clipped clip
file_being_split = '12-135843-002';  % the file that will be clipped, just to create a results path for this specific file split
fileNameNSxPerNSP{1} = 'Z:\Original Data\MG\MG90b\MG90b_Tasks\STIMULATION\NetworkWake2\NSP1\12-135843-002.ns3';
fileNameNSxPerNSP{2} = 'Z:\Original Data\MG\MG90b\MG90b_Tasks\STIMULATION\NetworkWake2\NSP2\12-135844-002.ns3';

fileNameNEVPerNSP{1} = 'Z:\Original Data\MG\MG90b\MG90b_Tasks\STIMULATION\NetworkWake2\NSP1\12-135843-002.nev'; %'E:\BIDStesting\local_data\MG169\StimulationDay3\NSP1\10-083607-003.nev';
fileNameNEVPerNSP{2} = 'Z:\Original Data\MG\MG90b\MG90b_Tasks\STIMULATION\NetworkWake2\NSP2\12-135844-002.nev'; %'E:\BIDStesting\local_data\MG169\StimulationDay3\NSP2\10-083608-003.nev';

selChName1 = [35,36,82,83];%  % bipolar ch numbers to visualize in clipping plot
buffer_time_minutes = 5; % time buffer (in minutes) before and after each session

gettingClipTimes(pName,resultsPath,fileNameNSxPerNSP,fileNameNEVPerNSP,file_being_split,selChName1,buffer_time_minutes);







