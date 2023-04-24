
PtInfo=readtable(patient_id_map,'Sheet','Sheet1');

PatientName = string(table2cell(PtInfo(1,1))); % mg/bw name
PatientNameList = string(table2cell(PtInfo(1,2)));  % "paper"
Relabel = string(table2cell(PtInfo(1,3))); % de-ID name

NameTitle={'Network','Amplitude','Stimulation_Matrix','Anesth','Single'};

czv=1;
lsn=2;
SummaryArray=repmat({'NaN'},78,17);
MissingFile=[];MissingFileLabel={};MissingFileSubcort=[];MissingFileLabelSubcort={};NotMissingFileSubcort=[];NotMissingFileLabelSubcort={};
MatchedIDs={};
clow=1;
if isempty(PatientName) || isempty(PatientNameList) || isempty(Relabel) 
    fprintf('Sheet ''Participant/Paper/Identifier'' values for are/is empty. Exiting.\n\n')
    return
end

for NT=1:5
    PatientNameParc=PatientName;
    LoadDir=[Maindir,PatientName,'\']; 
    taskDir=dir([LoadDir,NameTitle{NT},'*']);
    for Tsk=1:length(taskDir)
        TASK=taskDir(Tsk).name;
        Taskload=dir([Maindir,PatientName,'\',TASK,'*']);
        for session=1:length(Taskload)
            SessFolder=[Maindir,'\',PatientName,'\',Taskload(session).name,'\'];
            if isempty(dir([SessFolder,'Cleaned*']))==0
                MRIDir=dir([Maindir,PatientName,'\participantHP*','_anon.nii*']); % Preop MRI
                PostopMRIDir=dir([Maindir,PatientName,'\participantHP*','_anonPostOPScan.nii*']); %PostOp MRI
                FileLoad=dir([SessFolder,'\FT_Analyzed\UpdatedFT_Analyzed\*AlignedToTrialsall','*']); % Raw data saved in Matlab, could be replaced by looking for the .nsp files to open
                TrialLoad=dir([SessFolder,'\Cleaned','*']); % this had my organized trial information
                ChannelBank1=dir([SessFolder,'\FT_Analyzed\UpdatedFT_Analyzed\Channel_Selection*','Bank1*']);  % this had my bad channel information, NSP1
                ChannelBank2=dir([SessFolder,'\FT_Analyzed\UpdatedFT_Analyzed\Channel_Selection*','Bank2*']); % this had my bad channel information, NSP2
                ParcellationsMapping=dir([SessFolder,'\FT_Analyzed\UpdatedFT_Analyzed\Parcell*','SingleChannel*']); % This is the single channel RAS mapping with the channel information saved from the '' files
                if isempty(FileLoad)==0 &&  isempty(TrialLoad)==0 &&  isempty(ParcellationsMapping)==0
                    %StimInfo=TASK;
                    RawBipolar='RAW';
                    load([SessFolder,'\FT_Analyzed\UpdatedFT_Analyzed\',FileLoad(1).name]) %Loading needed files
                    load([SessFolder,'\FT_Analyzed\UpdatedFT_Analyzed\',ParcellationsMapping(1).name])%Loading needed files
                    load([SessFolder,'\',TrialLoad(1).name],'TrialAlignedMat1','TrialAlignedMat2')%Loading trial information
                    %% This section was to fix some few files with weird trials or the wrong column order.
                    %  I can fix those specific examples later once this needs to be run 'for real'
                    %  J: assuming this is kept for all DI but 75
                    if NT==3 || NT==5
                        TrialAlignedMat1=TrialAlignedMat1(:,[1:5 7 6 8:12]);
                        TrialAlignedMat1(TrialAlignedMat1(:,6)==1)=0;
                        if isempty(TrialAlignedMat2)==0
                            TrialAlignedMat2=TrialAlignedMat2(:,[1:5 7 6 8:12]);
                            TrialAlignedMat2(TrialAlignedMat2(:,6)==1)=0;
                        end
                    end
                    %% This section generates the new BIDS file format organization including the imaging folders
                    TaskName=(Taskload(session).name);
                    root_dir = [Bidsfolder,'\'];
                    ieeg_project = 'SinglePulseStimulation';
                    ieeg_sub = Relabel;
                    ieeg_ses = 'postimp';
                    taskName=[TaskName,RawBipolar];
                    taskName(taskName=='-' | taskName=='_')=[]; %underscores and dashes will break the BIDS system so all task names must have those removed.
                    ieeg_task = taskName;
                    if length(num2str(czv))==1
                        ieeg_run = ['0',num2str(czv)];
                    else
                        ieeg_run = num2str(czv);
                    end
                    project_label='';
                    %% The variables below are important for different .json coordinate files, etc. 
                    FS1=2000; %Sample rate, change if this depends on the recording
                    chType1=(ChannelInformation(:,12));
                    grouptype1=(ChannelInformation(:,17));
                    ECogChanNum=sum(count(chType1,'ECOG'));
                    sEEGChanNum=sum(count(chType1,'SEEG'));
                    eegonly=count(chType1,'EEG');
                    EEGChanNum=sum(count(chType1,'SEEG')==0 & eegonly==1);
                    EOGChanNum=sum(count(chType1,'EOG'));
                    ECGChanNum=sum(count(chType1,'EKG'));
                    EMGChanNum=sum(count(chType1,'EMG'));
                    MiscChannelCount=sum(count(chType1,'MISC'));
                    TriggerChannelCount=sum(count(chType1,'TRIG'));
                    RecordingDuration=size(DATAlfp1,2);
                    RecordingType='continuous';
                    EpochLength=[];
                    iEEGGround='chest';
                    iEEGPlacementScheme='clinical indication';
                    iEEGReference=ChannelInformation{5,16};  % J: manual?
                    ElectrodeManufacturer=ChannelInformation{1,6};
                    GroupList='multiple sEEG depths, see electrode locations in electrodes.tsv file';
                    MRIDataAlignedTo='defacedMRI';
                    BIPOL=0;
                    
                    createBIDS_preAndPostImpScans % J: simplified
                                    
                    %% This is where the ieeg data per task/session data along with the channel information is organized and saved:
%                   MainDirBIDS = fullfile(root_dir, project_label,['sub-' ieeg_sub],['ses-' ieeg_ses]);
                    postimpFolder = fullfile(root_dir, project_label,['sub-' ieeg_sub], ['ses-' 'postimp']);
                    mkdir([postimpFolder,'\ieeg']);

                    createBIDS_all_bank_loops % J: simplified
                    createBIDS_electrodes_tsvStandardization  % J: simplified
                    createBIDS_staticJson   % J: simplified
                    createBIDS_BrainVision_and_EDF_WithFieldtrip % J: simplified with both brainvision and edf version
                 
                    % J: is this even needed? even if so, can remove DI
                    % dependency
                    SummaryArray(1,1:3)= [{PatientName}, {Relabel}, {PatientNameList}]; 
                    if NT==1 || NT==4 || NT==5
                        SummaryArray(1,czv+3)={'Single Pulse, Multiple stimulation sites'};
                    elseif NT==2
                        SummaryArray(1,czv+3)={'Single Pulse, Multiple stimulation current amplitudes'};
                    elseif NT==3
                        SummaryArray(1,czv+3)={'Trains, Multiple frequencies and Current Amplitudes, Single pulse'};
                    end

                    czv=czv+1;
                end
            end
        end
    end
end

MatchedIDs(1,1:3)=[{PatientName},{PatientNameList},{Relabel}]; % J: not used?
