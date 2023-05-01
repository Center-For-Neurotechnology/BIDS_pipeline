%% Preprocessing_in_fieldtrip
%assumes access to MAD3 and Tarzan1
MAD3_drive = 'Z';
Tarzan1_drive = 'W';
Save_drive = 'E'; % where FT_Analyzed\UpdatedFT_Analyzed will be saved

%Settig up the directory location and specifics on the patient, task and stim to be
%extracted
NameF='MG1xxx';
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
 
Preprocessing_preAlign

%% Align the NEV to the CSV files.

TrialAlignedMatNEV= TrialAlignedMatNEVPerBank{1};
TrialAlignedMatNEV(:,3)=TrialAlignedMatNEV(:,2);
TrialRangeNEV=[1:320];  

 % commennt out these values if not using bank 2
diffcheck=TrialAlignedMatNEVPerBank{1}(:,2)-TrialAlignedMatNEVPerBank{2}(:,2);
TrialAlignedMatNEV= TrialAlignedMatNEVPerBank{2}; 
TrialAlignedMatNEV([find(diffcheck<4 | diffcheck>4.2)],2:3)=TrialAlignedMatNEV1([find(diffcheck<4 | diffcheck>4.2)],2:3)-difference/2000;
TrialAlignedMatNEV(:,2)=TrialAlignedMatNEV(:,3);
TrialRangeNEV=[1:320];  
%%
Preprocessing_postAlign

    
    
    
    
    
    
