
clear;
addpath(genpath('X:\Projects\Lab_Materials\Analysis_Tools_and_Software\fieldtrip-20220202'))
addpath(genpath('F:\Dropbox (Personal)\ACPProjects\MechanismsUnderlyingStimulation\GreyWhiteMatter_StimPaper\code'))
addpath(genpath('F:\Dropbox (Personal)\ACPProjects\MechanismsUnderlyingStimulation\GreyWhiteMatter_StimPaper\code\JSONio-main'))

Bidsfolder='Y:\StimDataBackup\Data_Stimulation\DeIdentifiedDataSet\';
PtInfo=readtable(['F:\Dropbox (Personal)\ACPProjects\MechanismsUnderlyingStimulation\Data_Information_Spreadsheets\HPStimFileList_2.xlsx'],'Sheet','MasterList');
Patients=table2cell(PtInfo(1:end,1));
List=table2cell(PtInfo(1:end,3));

PtInfo2=readtable(['F:\Dropbox (Personal)\ACPProjects\MechanismsUnderlyingStimulation\Data_Information_Spreadsheets\HPStimFileList_2.xlsx'],'Sheet','Sheet1');
Patients2=table2cell(PtInfo2(1:end,1));
Identifiers=table2cell(PtInfo2(1:end,3));
Relabel=table2cell(PtInfo2(1:end,4));

Maindir='Y:\StimDataBackup\Data_Stimulation\';
NameTitle={'Network','Amplitude','Stimulation_Matrix','Anesth','Single'};


PtInfo=readtable(['C:\Users\ChromaticEEG\Desktop\DataSet_backupInfo.csv']);
Patients=table2cell(PtInfo(1:end,1));
IDfr=table2cell(PtInfo(1:end,3));

czv=1;
lsn=2;
SummaryArray=repmat({'NaN'},length(Patients),17);
MissingFile=[];MissingFileLabel={};MissingFileSubcort=[];MissingFileLabelSubcort={};NotMissingFileSubcort=[];NotMissingFileLabelSubcort={};
MatchedIDs={};
clow=1;
for DI=1:length(Patients)
    % for DI=3:45:3 %go back to 36 to fix 75
    if isempty(Identifiers{DI})==0
        czv=1;
        PatientName=Patients{DI};
        PatientNameList=List{DI};
        PatientNameParc=PatientName;
        %
        LoadDir=[Maindir,Patients{DI},'\'];
        
        FreesurferFolder=['X:\Original Data\',PatientName(1:2),'\',PatientName,'\',PatientName,'_Notes_and_Images\',PatientName,'_SurferOutput\mri\'];
        root_dir = ['Y:\StimDataBackup\Data_Stimulation\DeIdentifiedDataSet\derivatives\freesurfer\'];
        
        ieeg_sub = Relabel{DI};
        
        BIPOL=0;
        
        preimpMRI = fullfile(root_dir, ...
            ['sub-' ieeg_sub]);
        
        
        %         mkdir(preimpMRI)
        fold=dir([FreesurferFolder,'\*']);
        
        for fd=1:length(fold)
            if isempty(strmatch(fold(fd).name,'mri.ct'))==1
                %         copyfile([FreesurferFolder,'\',fold(fd).name],[preimpMRI,'\',fold(fd).name])
                
                Files=dir([root_dir,'\',fold(fd).name,'\*',]);
                for fs=1:length(Files)
                    if contains(Files(fs).name,'MG','IgnoreCase',true)==1 || contains(Files(fs).name,'BW','IgnoreCase',true)==1 ||...
                            contains(Files(fs).name,'EM','IgnoreCase',true)==1 || contains(Files(fs).name,'BI','IgnoreCase',true)==1 ||...
                            contains(Files(fs).name,'EB','IgnoreCase',true)==1 
                        Files(fs).name
                        preimpMRI
                        pause
                    end
                end
                fd
            end
        end
        czv=czv+1
        
        
        MatchedIDs(DI,1)=Patients(DI);
        MatchedIDs(DI,2)=Identifiers(DI);
        MatchedIDs(DI,3)=Relabel(DI);
    end
end



% writecell(SummaryArray,'Y:\StimDataBackup\Data_Stimulation\DeIdentifiedDataSet\test.xls','Sheet',1)

