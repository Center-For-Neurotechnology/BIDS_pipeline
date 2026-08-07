% Setting up raw nsx file path and result path
pName = 'MG246'; % patient
resultsPath =  ['K:\StimDataBackup\Data_Stimulation\MG246\NetworkSleep1',filesep,pName]; % the results path to save the new clipped nsx files in

% ns3 files (nsp1 and nsp2) to be clipped clip
file_being_split = 'MG246_NetworkSleep_NSP1';  % the file that will be clipped, just to create a results path for this specific file split
% fileNameNSxPerNSP{1} = 'E:\Neuron2023\OriginalData\MG147\OR\NSP1\15-081505-002.ns3';
% fileNameNSxPerNSP{2} = 'E:\Neuron2023\OriginalData\MG147\OR\NSP2\15-081506-002.ns3';




fileNameNSxPerNSP{1} = 'K:\StimDataBackup\Data_Stimulation\MG246\NetworkSleep1\NSP1\20260530-005506-001.ns3';
% fileNameNSxPerNSP{1} = 'E:\Neuron2023\OriginalData\MG144\OR\NSP2\10-080444-001-combined.ns3';
% 

% fileNameNSxPerNSP{1} = 'E:\Neuron2023\ClippedData\MG150\WakeOR\NSP1\WakeOR.ns3';

nspNum = 1;

% fileNameNEVPerNSP{1} = 'E:\Neuron2023\OriginalData\MG108\Propofol\NSP1\13-143719-001.nev'; %'E:\BIDStesting\local_data\MG169\StimulationDay3\NSP1\10-083607-003.nev';
% fileNameNEVPerNSP{2} = 'E:\Neuron2023\OriginalData\MG108\Propofol\NSP2\13-144045-001.nev'; %'E:\BIDStesting\local_data\MG169\StimulationDay3\NSP2\10-083608-003.nev';

selChName1 = [1,2];%  % bipolar ch numbers to visualize in clipping plot
buffer_time_minutes = []; % time buffer (in minutes) before and after each session


% 6*10^50, 780, 585
start_time = [4.5*10^4/2000];%[3*10^5];%/2000;
end_time = [(140*10^4-1.4*10^4)/2000];%  [(615-30)*2000];


gettingClipTimes(pName,resultsPath,fileNameNSxPerNSP,file_being_split,selChName1,buffer_time_minutes,start_time,end_time,nspNum);


    




