function Preprocessing_Fieldtrip_MGxxx_SessionName(MAD3_drive,Tarzan1_drive,Save_drive,NameF,TASK,...
    STIM,BlockOrderFiles,NSP1_ns3, NSP1_nev,NSP2_ns3,NSP2_nev)    
%% Preprocessing_in_fieldtrip
    addpath(genpath([MAD3_drive,':\Projects\Lab_Materials\Analysis_Tools_and_Software\fieldtrip-20180410']))
    addpath(genpath([MAD3_drive,':\Projects\Lab_Materials\Analysis_Tools_and_Software\NPMK']))
    addpath(genpath([Tarzan1_drive,':\StimDataBackup\GreyWhiteMatter_StimPaper\code']))

    BlockTag='all';
    %Change this to get the right directocry
    DataDirectory=[Tarzan1_drive,'\StimDataBackup\Data_Stimulation\',NameF,filesep,STIM,filesep];
    BehaviorDirectory=[Tarzan1_drive,'\StimDataBackup\Data_Stimulation\',NameF,filesep,STIM,filesep];
    SaveDirectory=[Save_drive,':\BIDStesting\preprocessing_FT_analyzed','\StimDataBackup\Data_Stimulation\',NameF,filesep,STIM,filesep,'FT_Analyzed\UpdatedFT_Analyzed\'];

    % Setting up the file names to look for csv files (Presentation).
    CSVfileLead='\none';

    nsxfileBank1=[DataDirectory,'\NSP1\',NSP1_ns3];
    NEVfileBank1=[DataDirectory,'\NSP1\',NSP1_nev];
    nsxfileBank2=[DataDirectory,'\NSP2\',NSP2_ns3];
    NEVfileBank2=[DataDirectory,'\NSP2\',NSP2_nev];

    BlockStimFrequency=NaN;
    BlockStimLocation=BlockStimChannels;

    Monitor1Files={nsxfileBank1};
    Monitor2Files={nsxfileBank2};

    %This gets the data out of the nsx file into a structure called EEG. You
    %need openNSx and openNEV from the Blackrock website.
    EEGBank1= openNSx(nsxfileBank1);
    NEVBank1= openNEV(NEVfileBank1,'overwrite');
    FS1=EEGBank1.MetaTags.SamplingFreq;%Original sampling rate bank 1

    EEGBank2= openNSx(nsxfileBank2);
    NEVBank2= openNEV(NEVfileBank2,'overwrite');
    FS2=EEGBank2.MetaTags.SamplingFreq;%Original sampling rate bank 2

    dt=1/FS1;
    mkdir(SaveDirectory)
    %Getting the channel labels:
    % From the excel:
    % [data,txt]=xlsread([Tarzan1_drive,'\Cashlab\',NameF,'\MG79_LABELS.xlsx'],'Sheet1');
    %This is in case the labels were saved in with the nsx file.
    % pause
    %%
    ChanLabelBankBase={};
    ChanLabelBank1={};ChanCategoriesBank1=[];
    for II=1:length(EEGBank1.ElectrodesInfo)
        CL=char(EEGBank1.ElectrodesInfo(II).Label);
        NumOn=[];
       for si=1:length(CL)
           if isempty(str2num(CL(si)))==0
               if isreal(str2num(CL(si)))==1
               NumOn=[NumOn;si];
               end
           end
       end

       if length(NumOn)==2 && min(NumOn)==4
            AddedText='_';
        elseif length(NumOn)==1 && min(NumOn)==4
            AddedText='_0';
        elseif length(NumOn)==1 && min(NumOn)==3
            AddedText='__0';
        elseif length(NumOn)==2 && min(NumOn)==3
            AddedText='__';
        elseif length(NumOn)==1 && min(NumOn)==5
            AddedText='0';
        else
            AddedText='';
        end
       if isempty(NumOn)==0
       ChanLabelBank1{II}=[CL([1:min(NumOn)-1]),AddedText,CL([NumOn])];
       else
           ChanLabelBank1{II}=[CL];
       end
    end

    ChanLabelBankBase={};
    ChanLabelBank2={};ChanCategoriesBank2=[];
    for II=1:length(EEGBank2.ElectrodesInfo)
        CL=char(EEGBank2.ElectrodesInfo(II).Label);
        NumOn=[];
       for si=1:length(CL)
           if isempty(str2num(CL(si)))==0
               if isreal(str2num(CL(si)))==1
               NumOn=[NumOn;si];
               end
           end
       end

       if length(NumOn)==2 && min(NumOn)==4
            AddedText='_';
        elseif length(NumOn)==1 && min(NumOn)==4
            AddedText='_0';
        elseif length(NumOn)==1 && min(NumOn)==3
            AddedText='__0';
        elseif length(NumOn)==2 && min(NumOn)==3
            AddedText='__';
        elseif length(NumOn)==1 && min(NumOn)==5
            AddedText='0';
        else
            AddedText='';
        end
       if isempty(NumOn)==0
       ChanLabelBank2{II}=[CL([1:min(NumOn)-1]),AddedText,CL([NumOn])];
       else
           ChanLabelBank2{II}=[CL];
       end
    end

    ElectrodeLabelsBank1=ChanLabelBank1';
    ElectrodeLabelsBank2=ChanLabelBank2';
    %%
    % This gets the continuous data out of the EEG structure into a  matrix,
    % dataRAWBank1, which is converted to microvolts below
    % which then has line noise removal and is decimated 
    % from the original sampling rate to 1000 Hz below after identifying the bad channels.

    dataRAWBank1a=[];
    for elec=1:length(EEGBank1.ElectrodesInfo)
        elecinfo      = EEGBank1.ElectrodesInfo(elec);
        coef          = (double(elecinfo.MaxAnalogValue) - double(elecinfo.MinAnalogValue)) / ...
            (double(elecinfo.MaxDigiValue) - double(elecinfo.MinDigiValue));
        dataRAWBank1a(elec,:)=double(EEGBank1.Data(elec,:))*coef-nanmean(double(EEGBank1.Data(elec,:))*coef);
        %elec
    end
    dataRAWBank2a=[];
    for elec=1:length(EEGBank2.ElectrodesInfo)
        elecinfo      = EEGBank2.ElectrodesInfo(elec);
        coef          = (double(elecinfo.MaxAnalogValue) - double(elecinfo.MinAnalogValue)) / ...
            (double(elecinfo.MaxDigiValue) - double(elecinfo.MinDigiValue));
        dataRAWBank2a(elec,:)=double(EEGBank2.Data(elec,:))*coef-nanmean(double(EEGBank2.Data(elec,:))*coef);
        %elec
    end

    dataRAWBank1b=[];
    dataRAWBank2b=[];

    dataRAWBank1=[dataRAWBank1a dataRAWBank1b];
    dataRAWBank2=[dataRAWBank2a dataRAWBank2b];

    %% Visually checking for bad channels before decimating the data
    ChannVal1=[];

    ChannVal1=1:size(dataRAWBank1,1);
    clf
    imagesc(dataRAWBank1(ChannVal1,1:2000))
    caxis([-50 50])

    ChannVal1=1:size(dataRAWBank1,1);
    % ********** change bad channels in row below
    % BadChan1 = [7, 51:64, 109:143];
    BadChan1 = input('Bad Channels for Bank 1 in an array (eg. [7, 51:64, 109:143]): \n');
    ChannVal1(BadChan1)=[];
    imagesc(dataRAWBank1(ChannVal1,10000:15000))
    caxis([-50 50])

    %%
    save([SaveDirectory,'Channel_Selection',NameF,TASK,STIM,'_LFP_Block1_',BlockTag,'Bank1'],'ChannVal1','BadChan1')

    %% Bank 2 bad channel selection
    ChannVal2=[];

    ChannVal2=1:size(dataRAWBank2,1);
    clf
    imagesc(dataRAWBank2(ChannVal2,1:2000))
    caxis([-100 100])

    ChannVal2=1:size(dataRAWBank2,1);
    % ************ again, change bad channels in row below
    % BadChan2=[];
    BadChan2 = input('Bad Channels for Bank 2 in an array (eg. [7, 51:64, 109:143]): \n');
    ChannVal2(BadChan2)=[];
    imagesc(dataRAWBank2(ChannVal2,10000:15000))
    caxis([-50 50])

    %%
    save([SaveDirectory,'Channel_Selection',NameF,TASK,STIM,'_LFP_Block1_',BlockTag,'Bank2'],'ChannVal2','BadChan2')

    %% Removing line noise then decimating 
    OriginalSamplingRate=EEGBank1.MetaTags.SamplingFreq/(FS1/2000);
    StandardSamplingRate=2000;
    fs=StandardSamplingRate;
    % [dataBank1,dataBank2,DataFiltBank1,DataFiltBank2]=LineNoiseDecimateData(dataRAWBank1,dataRAWBank2,OriginalSamplingRate,StandardSamplingRate);
    % if isnan(dataBank1)==1
    %     'so many NaNs in the data! Check the filters/sampling rates'
    %     pause
    % end

    dataBank1=dataRAWBank1;
    dataBank2=dataRAWBank2;





    %% Saving and specifying information.
    % This cell is to analyze the data and rename the ephys data
    % (MG88ECR_NoStimLFP) and saves the log files and what blocks are associated
    % with each log file.
    %
    % *********** don't want to manually change
    % MG169Network_stimLFPBank1=dataBank1;
    % MG169Network_stimLFPBank2=dataBank2;

    % fix STIM to just network?
    session_name = STIM;
    eval([NameF,session_name,'_stimLFPBank1 = dataBank1']);
    eval([NameF,session_name,'_stimLFPBank2 = dataBank2']);

    % ****************************
    %Save log files associated with this recording.
    %What log files are associated with what blocks:
    BlockNumbersLogFile=1;
    %Downsampled rate
    fs=2000;


    save([SaveDirectory,NameF,TASK,STIM,'LFP',BlockTag],'CSVfileLead',...
        [NameF,session_name,'_stimLFPBank1'],[NameF,session_name,'_stimLFPBank2'],...
        'fs','EEGBank1','EEGBank2','ElectrodeLabelsBank1','ElectrodeLabelsBank2',...
        'BlockNumbersLogFile','Monitor1Files','Monitor2Files','BlockOrderFiles')
       clear DataFiltBank1 DataFiltBank2 dataRAWBank1 dataRAWBank2        

    %%
    clf
    subplot(2,1,1)
    imagesc(dataBank1(:,1:2:end))
    hold on
    plot(dataBank1(129,1:2:end),'k')
    caxis([-500 500])
    subplot(2,1,2)
    imagesc(dataBank2(:,1:2:end))
    hold on
    plot((abs(dataBank2(129,1:2:end))),'k') %72,1:2:end))),'k')      % changed 72 to 129, but why?
    caxis([-500 500])      
    axis xy    
    %  pause
    %% Synchronize log file to electrophysiology
    % This bit requires importing the information in the log (or csv) file,
    % running to get the trial specifics from the log file, and putting
    % everything into a matrix called 'MatrixBeh', which has a header variable,
    % 'MatrixBehHeaders'. 'MatrixBeh is modeled off of the CSV files created
    % for Psychtoolbox for MSIT or ECR, depending on the output.  The variables
    % below should be semi-self explanatory.
    Amplitudes=[7 7 7];
    HeadersOrderMSIT={'Trial','Frequency','delay','Amplitude'}
    StimMatrix=[];

    load([BehaviorDirectory,BlockOrderFiles{1}])
    % A=importdata([BehaviorDirectory,BlockOrderFiles{1},'_Read.txt']);
    % stimchans=A(:,2:4);
    stimchans1=stimchans;
    stimchans1(stimchans(:,1)>0 & stimchans(:,2)<33,1:2)=stimchans(stimchans(:,1)>0 & stimchans(:,2)<33,1:2)+32; %used to be +0
    stimchans1(stimchans(:,1)>32 & stimchans(:,2)<65,1:2)=stimchans(stimchans(:,1)>32 & stimchans(:,2)<65,1:2)+32;
    stimchans1(stimchans(:,1)>64 & stimchans(:,2)<97,1:2)=stimchans(stimchans(:,1)>64 & stimchans(:,2)<97,1:2)+32;
    Matrix1=[stimchans1 zeros(size(stimchans1,1),1) 7*ones(size(stimchans1,1),1) stimchans1(:,1) ones(size(stimchans1(:,1))) stimchans1(:,2) ones(size(stimchans1(:,2))) NaN*ones(size(stimchans1(:,2)))];
    %  Matrix1(stimchans(:,1)>64 & stimchans(:,2)<97,[6 8])=2;
    ChanStim=Matrix1(stimchans(:,1)>0 & stimchans(:,1)<129,5);
    % A=importdata([BehaviorDirectory,BlockOrderFiles{2},'_Read.txt']);
    % stimchans=A(:,2:4);
    % stimchans1=stimchans;
    % stimchans1(stimchans(:,1)>0 & stimchans(:,2)<33,1:2)=stimchans(stimchans(:,1)>0 & stimchans(:,2)<33,1:2)+0;
    % stimchans1(stimchans(:,1)>32 & stimchans(:,2)<65,1:2)=stimchans(stimchans(:,1)>32 & stimchans(:,2)<65,1:2)-32;
    % stimchans1(stimchans(:,1)>64 & stimchans(:,2)<97,1:2)=stimchans(stimchans(:,1)>64 & stimchans(:,2)<97,1:2)-32;
    % Matrix2=[stimchans1 zeros(size(stimchans1,1),1) 7*ones(size(stimchans1,1),1) stimchans1(:,1) ones(size(stimchans1(:,1))) stimchans1(:,2) ones(size(stimchans1(:,2))) NaN*ones(size(stimchans1(:,2)))];
    % Matrix2(stimchans(:,1)>32 & stimchans(:,1)<129,[7 9])=2;
    % 
    % 
    % A=importdata([BehaviorDirectory,BlockOrderFiles{3},'_Read.txt']);
    % stimchans=A(:,2:4);
    % stimchans1=stimchans;
    % stimchans1(stimchans(:,1)>0 & stimchans(:,2)<33,1:2)=stimchans(stimchans(:,1)>0 & stimchans(:,2)<33,1:2)+0;
    % stimchans1(stimchans(:,1)>32 & stimchans(:,2)<65,1:2)=stimchans(stimchans(:,1)>32 & stimchans(:,2)<65,1:2)-32;
    % stimchans1(stimchans(:,1)>64 & stimchans(:,2)<97,1:2)=stimchans(stimchans(:,1)>64 & stimchans(:,2)<97,1:2)-32;
    % Matrix3=[stimchans1 zeros(size(stimchans1,1),1) 7*ones(size(stimchans1,1),1) stimchans1(:,1) ones(size(stimchans1(:,1))) stimchans1(:,2) ones(size(stimchans1(:,2))) NaN*ones(size(stimchans1(:,2)))];
    % Matrix3(stimchans(:,1)>32 & stimchans(:,1)<129,[7 9])=2;

    Matrix=[Matrix1;];
    MatrixHeaders=HeadersOrderMSIT;
    %%
    % for msn=1:size(ID)
    % stimchans1(stimchans==ChanEq(msn,1),:)=repmat(ChanEq(msn,2:3),length(find(stimchans==ChanEq(msn,1))),1);
    % stimchans2(stimchans==ChanEq(msn,1),:)=repmat([ChanEq(msn,2)+1 ChanEq(msn,3)],length(find(stimchans==ChanEq(msn,1))),1);
    % end
    % 
    % 
    % Matrix=[stimchans1(:,1) stimchans2(:,1) zeros(size(stimchans,1),1) 7*ones(size(stimchans,1),1) stimchans1 stimchans2 times];
    % Matrix(Matrix(:,1)>32 & Matrix(:,2)<65,5:6)=Matrix(Matrix(:,1)>32 & Matrix(:,2)<65,5:6)+96-32;
    % Matrix(Matrix(:,1)>64 & Matrix(:,2)<97,5:6)=Matrix(Matrix(:,1)>64 & Matrix(:,2)<97,5:6)+128-64;
    clf
    MatrixHeaders=HeadersOrderMSIT;

    [b,a] = butter(5,[4]/(2000/2),'high');
    MeanFilt=filtfilt(b,a,nanmean((dataBank1([unique(129)],:)),1));
    % plot((1:length(MeanFilt))/2000,MeanFilt)
    hold on
    % plot(dataBank1([ChanEq(1,1:2)],:)')
    [pks,locs] = findpeaks(MeanFilt,'MinPeakDistance',2000*2,'MinPeakHeight',1000);
    % plot(locs/2000,ones(size(locs)),'o')
    % plot((1:length(MeanFilt))/2000,dataBank1([unique(129)],:))

    chanv=unique(ChanStim);
    clf
     [b,a] = butter(5,[4]/(2000/2),'high');
    %         MeanFilt=filtfilt(b,a,((dataBank2([72],:))));
            dataalign=MeanFilt;   
    %         plot((1:length(MeanFilt))/2000,MeanFilt)
            [pks,locs] = findpeaks(abs(MeanFilt),'MinPeakDistance',2000*2,'MinPeakHeight',1000);
         plot(locs/2000,ones(size(locs)),'o')
         hold on
    plot((1:length(MeanFilt))/2000,abs(MeanFilt))


    % for owm=1:length(chanv)

    %%
    clf
    ThreshTrain=50;
    ThreshAll=50;
    FS=2000;
    TrialAlignedMatNEVPerBank={};
    tmp_eventPerBank={};
    for Bank=1:2 % J: used to be 1:1 (when there was no nsp2 files

        ReactionOnTime1=[];
        %Getting the information from the digital markers in the NEV file. If there
        %are two banks, this has to be done twice, once per bank (monitor)
         if Bank ==1
            NEV=NEVBank1;
            [b,a] = butter(5,[4]/(2000/2),'high');
            MeanFilt=dataBank1([129],:);
            dataalign=MeanFilt;
            [pks,locs] = findpeaks(MeanFilt,'MinPeakDistance',2000*2,'MinPeakHeight',1000);
            locs=find(diff(MeanFilt)<-100);
            locs(diff(locs)<2000)=[];

            locsOn=find(diff(MeanFilt)>100);
            locsOn(find(diff(locsOn)<2000)+1)=[];

            chansel=129;
            timelim1=0;
            timelim2=700000;
            locs([find(locs>timelim2*FS) find(locs<timelim1*FS)])=[];
            locsOn([find(locsOn>timelim2*FS) find(locsOn<timelim1*FS)])=[];
        else
            NEV=NEVBank2;
            [b,a] = butter(5,[4]/(2000/2),'high');
            MeanFilt=dataBank2([129],:); % J: used to be [72],:);
             dataalign=MeanFilt;
            [pks,locs] = findpeaks(MeanFilt,'MinPeakDistance',2000*2,'MinPeakHeight',1000);
            locs=find(diff(MeanFilt)<-100);
            locs(diff(locs)<2000)=[];

            locsOn=find(diff(MeanFilt)>100);
            locsOn(find(diff(locsOn)<2000)+1)=[];

            chansel=129; % J: used to be chansel=72;
            timelim1=0;
            timelim2=700000;
            locs([find(locs>timelim2*FS) find(locs<timelim1*FS)])=[];
            locsOn([find(locsOn>timelim2*FS) find(locsOn<timelim1*FS)])=[];
        end

        r_event_time=NEV.Data.SerialDigitalIO.TimeStampSec;
        r_event_index_all=round(r_event_time/(1/FS));
        if Bank==1
            locs1=locs;
            r_event_indval=NEV.Data.SerialDigitalIO.UnparsedData-65280;
        else
            r_event_indval=NEV.Data.SerialDigitalIO.UnparsedData-65280;
        end
         response_event_idx= find((NEV.Data.SerialDigitalIO.UnparsedData-0)>-1);

        r_event_indval(r_event_time<timelim1 | r_event_time>timelim2)=[];
        r_event_index_all(r_event_time<timelim1 | r_event_time>timelim2)=[];
        response_event_idx(r_event_time<timelim1 | r_event_time>timelim2)=[];
        r_event_time(r_event_time<timelim1 | r_event_time>timelim2)=[];

        TimingMatrix=zeros(size(r_event_indval,1),10);

        % For All the stim:
        StimOnsetOffset=zeros(size(dataalign(1,:)));
        for LO=1:length(locs)
        StimOnsetOffset(locsOn(LO):locs(LO))=1;
        end

        DiffStimOn=find(diff(StimOnsetOffset)==1)+1;
        DiffStimOff=find(diff(StimOnsetOffset)==-1)+1;
        DiffStimOnAll=find(diff(StimOnsetOffset)==1)+1;

        FIM=find(diff(DiffStimOnAll)<2000)+1;
        DiffStimOnAll(FIM(diff(FIM)==1))=[];
        DiffStimOnAll(diff(DiffStimOnAll)<2000)=[];

        DiffStimOffAll=find(diff(StimOnsetOffset)==-1)+1;
        FIM=find(diff(DiffStimOffAll)<2000)+1;
        DiffStimOffAll(FIM(diff(FIM)==1))=[];

        DiffStimOffAll(diff(DiffStimOffAll)<2000)=[];

        if length(DiffStimOnAll)> length(DiffStimOffAll)
            DiffStimOnAll=DiffStimOnAll(1:length(DiffStimOffAll));
        elseif length(DiffStimOnAll)< length(DiffStimOffAll)
            DiffStimOffAll=DiffStimOffAll(1:length(DiffStimOnAll));
        end

    %     % For the Trains only:
    %     StimOnsetOffset=zeros(size(dataalign(chansel,:)));
    %     StimOnsetOffset(locs)=1;

        TenHzTrainOnset=[find(diff(DiffStimOnAll)>5000)];

        if length(DiffStimOn)> length(DiffStimOff)
            DiffStimOn=DiffStimOn(1:length(DiffStimOff));
        elseif length(DiffStimOn)< length(DiffStimOff)
            DiffStimOff=DiffStimOff(1:length(DiffStimOn));
        end
        DiffStimOn(find(diff(DiffStimOn/FS)<3)+1)=[];
        DiffStimOff(find(diff(DiffStimOff/FS)<3)+1)=[];

        DiffStimOn=DiffStimOnAll(TenHzTrainOnset);
        DiffStimOff(find(diff(DiffStimOff/FS)<3)+1)=[];


        TrialAlignedMatNEV=[];
        for TRI=1:length(DiffStimOffAll)
            Pulse=DiffStimOffAll(DiffStimOffAll>DiffStimOffAll(TRI)-50 & DiffStimOffAll<DiffStimOffAll(TRI)+50);
            PulseOn=DiffStimOnAll(DiffStimOnAll>DiffStimOffAll(TRI)-2000 & DiffStimOnAll<DiffStimOffAll(TRI)+50);
            if isempty(Pulse)==1; Pulse=NaN; end
            if isempty(PulseOn)==1; PulseOn=NaN; end
            TrialAlignedMatNEV=[TrialAlignedMatNEV;TRI PulseOn(1)/FS Pulse(1)/FS  ];
        end

        TrialAlignedMatNEV=[TrialAlignedMatNEV(:,1)+1 TrialAlignedMatNEV(:,[2])...
            [TrialAlignedMatNEV(1:end,[3])]];


        TrialAlignedMatNEVPerBank{Bank}=TrialAlignedMatNEV;
        %         tmp_eventPerBank{Bank}=tmp_event;
    end

    %%

    Locs1= TrialAlignedMatNEVPerBank{1}(:,2)*FS;
    Locs2= TrialAlignedMatNEVPerBank{2}(:,2)*FS; % J: was commented
    clf
    subplot(2,1,1)
    %  MeanFilt=filtfilt(b,a,nanmean(abs(dataBank1([unique(stimchans1)],:))));
    % [pks,locs] = findpeaks(MeanFilt,'MinPeakDistance',2000*3,'MinPeakHeight',50);
    imagesc(dataBank1)
    hold on
    stem(Locs1,100*ones(size(Locs1)),'wo')
    % plot(dataBank1(129,:),'k')
    caxis([-500 500])
    subplot(2,1,2)
    %  MeanFilt=filtfilt(b,a,nanmean(abs(dataBank2([1:30],:))));
    % [pks,locs] = findpeaks(MeanFilt,'MinPeakDistance',2000*3,'MinPeakHeight',50);
    imagesc(dataBank2)      % J: was commented
    hold on                 % J: was commented
    stem(Locs2,100*ones(size(Locs2)),'wo')     % J: was commented
    % % plot(dataBank2(2,:),'k')
    caxis([-500 500])        % J: was commented
    axis xy          % J: was commented
    % clf
    % plot(TrialAlignedMatNEVPerBank{1}(:,2),'o'); hold on; plot(TrialAlignedMatNEVPerBank{2}(:,2),'d')

    %%
    % Locs2= TrialAlignedMatNEVPerBank{2}(:,3)*FS;
    % clf
    % plot((1:size(dataBank2,2)),dataBank2(72,:))
    % hold on
    % stem(Locs2,100*ones(size(Locs2)),'ko')

    %% This is the bit where I hand-align the NEV to the CSV files.
    TrialRangeMatbeh=[1:size(Matrix,1)];

    TrialAlignedMatNEV= TrialAlignedMatNEVPerBank{1};
    % TrialAlignedMatNEV(:,3)=TrialAlignedMatNEV(:,2);
    TrialRangeNEV=[1:320];       % J: was [1:120];
    % TrialAlignedMatNEV(:,3)=TrialAlignedMatNEVPerBank{1}(:,2)+2/2000;
    % TrialAlignedMatNEV(:,3)=TrialAlignedMatNEVPerBank{1}(:,2)+2/2000;
    TrialAlignedMat1=[TrialAlignedMatNEV(TrialRangeNEV,:)  Matrix(TrialRangeMatbeh,:)];

    TrialAlignedMatNEV1=TrialAlignedMatNEV;

    % diffcheck=TrialAlignedMatNEVPerBank{1}(:,2)-TrialAlignedMatNEVPerBank{2}(:,2);

    TrialAlignedMatNEV= TrialAlignedMatNEVPerBank{2}; % J: was commented
    % TrialAlignedMatNEV([find(diffcheck<4 | diffcheck>4.2)],2:3)=TrialAlignedMatNEV1([find(diffcheck<4 | diffcheck>4.2)],2:3)-difference/2000;
    % TrialAlignedMatNEV(:,2)=TrialAlignedMatNEV(:,3);
    TrialRangeNEV=[1:320];  % J: original values commented in lines below
    TrialAlignedMat2=[TrialAlignedMatNEV(TrialRangeNEV,:)  Matrix(TrialRangeMatbeh,:)];
    % TrialRangeNEV=[1:170];
    % TrialAlignedMat2=[];

    TM=TrialAlignedMat1;

    clf
    plot(TrialAlignedMat1(:,3),'o'); hold on; 
    % plot(TrialAlignedMat2(:,3),'d')

    %%

    clf
    subplot(2,1,1)
    plot((1:length(dataBank1(129,:)))/FS, dataBank1(129,:), '+-')
    hold on
    ds=find(diff(DiffStimOnAll)>2000);
    plot(TrialAlignedMat1(:,2),200*ones(size(TrialAlignedMat1(:,2))),'o')
    plot(TrialAlignedMat1(:,3),300*ones(size(TrialAlignedMat1(:,3))),'s')

    title(['Digital notations from the NEV file, Bank: ', num2str(1),' ',NameF])

    Imageplot=TrialAlignedMatNEV(:,2);
    for GY=1:size(Imageplot,1)
        text(Imageplot(GY)-1,2500,num2str(GY),'fontsize',8,'Clipping','on')
    end
    box off
    xlabel('time (sec)')
    ylabel('event notation')
    legend('Stim triggers (sync) events')

    subplot(2,1,2)
    plot((1:length(dataBank2(129,:)))/FS, dataBank2(129,:), '+-') % J: was 72,:)))/FS, dataBank2(72,:), '+-')
    hold on
    ds=find(diff(DiffStimOnAll)>2000)+1;
    plot(TrialAlignedMat2(:,2),200*ones(size(TrialAlignedMat2(:,2))),'o')
    plot(TrialAlignedMat2(:,3),300*ones(size(TrialAlignedMat2(:,3))),'s')
    title(['Digital notations from the NEV file, Bank: ', num2str(2),' ',NameF])

    Imageplot=TrialAlignedMatNEV(:,2);
    for GY=1:size(Imageplot,1)
        text(Imageplot(GY)-1,2500,num2str(GY),'fontsize',8,'Clipping','on')
    end
    box off
    xlabel('time (sec)')
    ylabel('event notation')
    legend('Stim triggers (sync) events')

    %%

    save([SaveDirectory,'\ErrorCheckforData',NameF,TASK,STIM],...
        'TrialAlignedMat1','TrialAlignedMat2','NEVBank2','NEVBank1')

    Fig=gcf;
    Fig.Position=[1921 1 1920 1004];
    saveas(gcf,[SaveDirectory,'\ErrorCheckFigure',NameF,TASK,STIM])
    saveas(gcf,[SaveDirectory,'\ErrorCheckFigure',NameF,TASK,STIM,'.png'])

    CorrectedTimingperTrial=TrialAlignedMat1(:,2);

    TrialAlignedMatHeaders={'Trial','TrainOnset','PulseOnset'};
    VM=MatrixHeaders;XO=length(TrialAlignedMatHeaders);
    for OO=1:length(MatrixHeaders)
        TrialAlignedMatHeaders{XO+OO}=VM{OO};
    end
    A=[];

    save([SaveDirectory,NameF,TASK,STIM,'StimDataandTiming',BlockTag],'fs',...
        'Matrix','A','CorrectedTimingperTrial','TrialAlignedMat1','TrialAlignedMat2',...
        'MatrixHeaders','TrialAlignedMatHeaders','TrialAlignedMatNEVPerBank')


    %% Putting in the info for the experiments for stim

    % BlockStimOrderCSV={'Network'};
    BlockStimOrderCSV= {input('Enter stim experiment for BlockStimOrderCSV (eg. ''Network''): \n','s')}; 

    BlockOrderStimChan={[NaN NaN 1];};

    BlockStimChannels=BlockOrderStimChan;
    BlockStimFrequency={[1];};

    BlockStimCurrent={[7];};

    % BlockStimLocation={'Network'};
    BlockStimLocation= {input('Enter stim experiment for BlockStimLocation (eg. ''Network''): \n','s')}; 

    BlockStimDuration={[0];};
    BlockStimDelayRelImageOnset={[NaN];};
    BlockStimOrderRelativetoCSV=BlockStimOrderCSV;

    %%
    BlockSteps=[1; find(diff(TrialAlignedMat1(:,2))>20); length(TrialAlignedMat1(:,2))];
    % BlockSteps(BlockSteps==110 | BlockSteps==110)=[];
    clf
    close all
    BlockOrderInfo=[0 0 0]; % This goes along with the block experimental design from the BlockStimOrderCSV specs
    BlockType=[];BlockNumber=[];BlockStimParameters=[];
    for BL=1:length(BlockSteps)-1
        BlockType([BlockSteps(BL)+1:BlockSteps(BL+1)])=BlockOrderInfo(BL);
        BlockNumber([BlockSteps(BL)+1:BlockSteps(BL+1)])=BL;
        BlockStimParameters([BlockSteps(BL)+1:BlockSteps(BL+1)],:)=repmat([BL BlockOrderInfo(BL) BlockOrderStimChan{BL} BlockStimFrequency{BL}...
            BlockStimCurrent{BL} BlockStimDuration{BL} BlockStimDelayRelImageOnset{BL}],length(BlockSteps(BL)+1:BlockSteps(BL+1)),1);
    end
    BlockNumber(1)=1;
    BlockStimParametersHeader={'block number','block order type','channel 1 stim (bipolar stim)','channel 2 stim (bipolar stim)',...
        'bank','block stim frequency','block stim current','block stim duration','block stim delay relative to image onset(sec)'};
    scatter(TrialAlignedMat1(:,2),BlockNumber,16,BlockNumber)
    colorbar
    box off
    xlabel('time (sec)')
    ylabel('block number')
    title('checks on the block number and when it happens')


    %% Running a common script that allows saving of all the data above and putting things into fieldtrip formats
    %for two NSPs
    fs=FS;
    StrLen=4;
    FieldtripSavingScriptTwoBanksNOTASKStim

end


