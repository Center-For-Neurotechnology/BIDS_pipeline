function Matrix = get_eTBSMatrix(DataDirectory)
%%


% DataDirectory = 'G:\BIDScodeTest\MG209\eTBS\';
DirPlist=dir([DataDirectory,'\*.mat']);

[~,idx] = sort([DirPlist.datenum]);

BlockOrderFiles={};
for hk=1:length(DirPlist)
    BlockOrderFiles{hk}=DirPlist(idx(hk)).name;
end
BlockOrderFiles=BlockOrderFiles';



%%
Amplitudes=[7 7 7];
HeadersOrderMSIT={'Trial','Frequency','delay','Amplitude'}
StimMatrix=[];

Matrix=[];
for BL=1:length(BlockOrderFiles)

    load([DataDirectory,BlockOrderFiles{BL}])
    % A=importdata(['Y:\StimDataBackup\Data_Stimulation\MG167\NetworkWake1\Network-d03_11-17-08 _Read.txt']);
    % stimchans=A(:,2:3);
    if contains(BlockOrderFiles{BL},'thetaburstInterv')==0

        stimchans1=stimchans(:,2:3);
        stimchans1(stimchans(:,2)>0 & stimchans(:,3)<33,1:2)=stimchans(stimchans(:,2)>0 & stimchans(:,3)<33,2:3)+0;
        stimchans1(stimchans(:,2)>32 & stimchans(:,3)<65,1:2)=stimchans(stimchans(:,2)>32 & stimchans(:,3)<65,2:3)+32;
        stimchans1(stimchans(:,2)>64 & stimchans(:,3)<97,1:2)=stimchans(stimchans(:,2)>64 & stimchans(:,3)<97,2:3)+0;
        Matrix1=[stimchans(:,1) stimchans1 stimchans(:,4:13)];
        Matrix1(stimchans(:,2)>0 & stimchans(:,2)<129,4)=1;
        ChanStim=Matrix1(stimchans(:,1)>0 & stimchans(:,1)<129,5);

        Matrix=[Matrix;Matrix1];

    elseif contains(BlockOrderFiles{BL},'thetaburstInterv')==1
% pause
        stimchans1=stimchans(:,2:3);
        stimchans1(stimchans(:,2)>0 & stimchans(:,3)<33,1:2)=stimchans(stimchans(:,2)>0 & stimchans(:,3)<33,2:3)+0;
        stimchans1(stimchans(:,2)>32 & stimchans(:,3)<65,1:2)=stimchans(stimchans(:,2)>32 & stimchans(:,3)<65,2:3)+32;
        stimchans1(stimchans(:,2)>64 & stimchans(:,3)<97,1:2)=stimchans(stimchans(:,2)>64 & stimchans(:,3)<97,2:3)+0;
        Matrix1=[stimchans(:,1) stimchans1 1*ones(size(stimchans1(:,1))) stimchans(:,[4:9 11:13])];
        Matrix1(Matrix1(:,2)>0 & Matrix1(:,2)<129,[4])=1;
        ChanStim=Matrix1(stimchans(:,1)>0 & stimchans(:,1)<129,5);

        Matrix=[Matrix;Matrix1];
    end
end
