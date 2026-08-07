function [data,chNumber, chNames, hdr] = readCSCfilesChNamesFromXls_incBlanks(dirData, xlsFileName, posFixNCS)

%dirData = ['\\172.17.146.246\Tarzan2\neuralynxTestingData\2023-12-11_13-21-20'];

%posFixNCS = '_0003';

%% read channel names from XLS all Channels
%% READ XLS in 2 parts - NSP1 and NSP2 as there is no col separating in between 
tableChList = readtable(xlsFileName,'Sheet',2,'Range','A3:K34','ReadRowNames',false, 'ReadVariableNames',false);
cellChListNSP1 = table2cell(tableChList);
tableChList = readtable(xlsFileName,'Sheet',2,'Range','L3:V34','ReadRowNames',false, 'ReadVariableNames',false);
cellChListNSP2 = table2cell(tableChList);

%% Organize table to get chNames and chNumbers for NSP1 and NSP 2 separate
% columns 1/4/7 etc are the channel numbers colums 2/5/8 etc are the channel names
chNumbersNSP=[];
chNamesFromXls =[];
% NSP1: 1:128
for iCol=1:3:size(cellChListNSP1,2)-1
    chNumbersNSP = [chNumbersNSP; cellChListNSP1(:,iCol)];
    chNamesFromXls = [chNamesFromXls; cellChListNSP1(:,iCol+1)];
end
% NSP2: 129:256
for iCol=1:3:size(cellChListNSP2,2)-1
    chNumbersNSP = [chNumbersNSP; cellChListNSP2(:,iCol)];
    chNamesFromXls = [chNamesFromXls; cellChListNSP2(:,iCol+1)];
end
nChannels=length(chNamesFromXls);


%% Read data from CSC files
chNumber=[];
chNames=[];
dataValuesInt = [];
for iCh=1:nChannels
    ncsFileName =[dirData,filesep,chNamesFromXls{iCh},posFixNCS,'.ncs']; %'CSC',num2str(iCh)
    
    if ~any(isnan(chNamesFromXls{iCh})) && exist(ncsFileName,'file')
        [Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples, Samples, Header] = ...
            Nlx2MatCSC(ncsFileName,[1 1 1 1 1], 1, 1, [] );
        
        chNumber = [chNumber; ChannelNumbers(1)]; % it is a vector, but should all be the same
        dataValuesInt = [dataValuesInt, Samples(:)]; % assumes all the same size!
        chNames = [chNames,chNamesFromXls(iCh)];
    else
        chNumber = [chNumber; iCh]; % it is a vector, but should all be the same
        dataValuesInt = [dataValuesInt, zeros(size(Samples(:)))]; % assumes all the same size!
        chNames = [chNames,chNamesFromXls(iCh)];
    end
    
    
end


cADBitVolts = split(Header{17},' '); % field 17 is the ADBitVolts - use to get amploitude in Volts
cbScale = str2double(cADBitVolts{2}); %0.000000030517578125000001; %0.000000061035156250000001;% as comparison: BlackRock: (double(MaxAnalogValue)-double(dataNEV.ElectrodesInfo(1).MinAnalogValue))/(double(dataNEV.ElectrodesInfo(1).MaxDigiValue)-double(dataNEV.ElectrodesInfo(1).MinDigiValue)); %0.25 corresponds to MaxAnalo / MaxDigital Values
data = cbScale * double(dataValuesInt)*1000; %in miliVolts
hdr.orig = Header; % assumes same for all macro channels
hdr.Fs = unique(SampleFrequencies);







% if usePlot
% figure;hold on; 
% plot(50000*(iCh) + Samples{iCh}(:),'-')
% plot((Timestamps- Timestamps(1))/2000*4, zeros(length(Timestamps),1),'x')
% 
% end
