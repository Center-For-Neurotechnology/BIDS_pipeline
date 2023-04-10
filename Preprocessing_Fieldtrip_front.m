%% Preprocessing_in_fieldtrip
%assumes access to MAD3 and Tarzan1
MAD3_drive = 'Z';
Tarzan1_drive = 'W';
Save_drive = 'E'; % where FT_Analyzed\UpdatedFT_Analyzed will be saved

%Settig up the directory location and specifics on the patient, task and stim to be
%extracted
NameF='MG169';
TASK='none';
STIM='NetworkWake2';

% Setting up the file names to look for csv files (Presentation).
% from Tarzan1:\StimDataBackup\Data_Stimulation\
BlockOrderFiles={'Network-d06_11-56-30'}; % txt file
NSP1_ns3 = '06-111921-003.ns3'; 
NSP1_nev = '06-111921-003.nev';
NSP2_ns3 = '06-111922-003.ns3';
NSP2_nev = '06-111922-003.nev';

BlockStimChannels=[0 0 0]; % Bank 1
 
Preprocessing_Fieldtrip_MGxxx_SessionName(MAD3_drive,Tarzan1_drive,Save_drive,NameF,TASK,...
    STIM,BlockOrderFiles,NSP1_ns3, NSP1_nev,NSP2_ns3,NSP2_nev);