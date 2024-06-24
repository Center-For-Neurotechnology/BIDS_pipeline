% Setting up raw nsx file path and result path
pName = 'MG144'; % patient
resultsPath =  ['E:\CNN\new\testingCanDelete',filesep,pName]; % the results path to save the new clipped nsx files in

% ns3 files (nsp1 and nsp2) to be clipped clip
file_being_split = 'MG184revised_NW2_NSP1';  % the file that will be clipped, just to create a results path for this specific file split
% fileNameNSxPerNSP{1} = 'E:\Neuron2023\OriginalData\MG147\OR\NSP1\15-081505-002.ns3';
% fileNameNSxPerNSP{2} = 'E:\Neuron2023\OriginalData\MG147\OR\NSP2\15-081506-002.ns3';




fileNameNSxPerNSP{1} = 'E:\CNN\new\dataRaw\MG184revised\NetworkWake2\NSP1\05-142322-002.ns3';
% fileNameNSxPerNSP{1} = 'E:\Neuron2023\OriginalData\MG144\OR\NSP2\10-080444-001-combined.ns3';
% 

% fileNameNSxPerNSP{1} = 'E:\Neuron2023\ClippedData\MG150\WakeOR\NSP1\WakeOR.ns3';

nspNum = 1;

% fileNameNEVPerNSP{1} = 'E:\Neuron2023\OriginalData\MG108\Propofol\NSP1\13-143719-001.nev'; %'E:\BIDStesting\local_data\MG169\StimulationDay3\NSP1\10-083607-003.nev';
% fileNameNEVPerNSP{2} = 'E:\Neuron2023\OriginalData\MG108\Propofol\NSP2\13-144045-001.nev'; %'E:\BIDStesting\local_data\MG169\StimulationDay3\NSP2\10-083608-003.nev';

selChName1 = [1,2];%  % bipolar ch numbers to visualize in clipping plot
buffer_time_minutes = []; % time buffer (in minutes) before and after each session


% 6*10^50, 780, 585
start_time = [];%[3*10^5];%/2000;
end_time = [];%  [(615-30)*2000];


gettingClipTimes(pName,resultsPath,fileNameNSxPerNSP,file_being_split,selChName1,buffer_time_minutes,start_time,end_time,nspNum);


    




