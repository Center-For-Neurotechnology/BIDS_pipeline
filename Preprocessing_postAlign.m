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

    if ~isempty(NSP2_ns3)
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
    end

    %%
    if ~isempty(NSP2_ns3)
    save([SaveDirectory,'\ErrorCheckforData',NameF,TASK,STIM],...
        'TrialAlignedMat1','TrialAlignedMat2','NEVBank2','NEVBank1')
    else
        save([SaveDirectory,'\ErrorCheckforData',NameF,TASK,STIM],...
        'TrialAlignedMat1','NEVBank1')
    end

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

    if ~isempty(NSP2_ns3)
    save([SaveDirectory,NameF,TASK,STIM,'StimDataandTiming',BlockTag],'fs',...
        'Matrix','A','CorrectedTimingperTrial','TrialAlignedMat1','TrialAlignedMat2',...
        'MatrixHeaders','TrialAlignedMatHeaders','TrialAlignedMatNEVPerBank')
    else
        save([SaveDirectory,NameF,TASK,STIM,'StimDataandTiming',BlockTag],'fs',...
        'Matrix','A','CorrectedTimingperTrial','TrialAlignedMat1',...
        'MatrixHeaders','TrialAlignedMatHeaders','TrialAlignedMatNEVPerBank')
    end
    


    %% Putting in the info for the experiments for stim

    % BlockStimOrderCSV={'Network'};
    BlockStimOrderCSV= {input('Enter stim experiment for BlockStimOrderCSV (eg. ''Network''): \n','s')}; 

    BlockOrderStimChan={[NaN NaN 1];};

    BlockStimChannels=BlockOrderStimChan;
    BlockStimFrequency={[1];};

%     BlockStimCurrent={[7];};
    BlockStimCurrent= {input('Enter stim current: \n','s')}; 

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