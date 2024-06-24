function [data,chNumber, chNamesToRead, hdr] =  readCSCfiles(dirData, chNamesToRead, posFixNCS, usePlot)
% use this to read AINP info (CSC289 is SYNC data)


%dirData = ['\\172.17.146.246\Tarzan2\neuralynxTestingData\2023-12-11_13-21-20'];
if ~iscell(chNamesToRead), chNamesToRead ={chNamesToRead}; end

nChannels =numel(chNamesToRead);

%posFixNCS = '_0003';


%% Read from each CS file
for iCh=1:nChannels
    ncsFileName =[dirData,filesep,chNamesToRead{iCh},posFixNCS,'.ncs']; %'CSC',num2str(iCh)
    [Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples, Samples, Header] = ...
        Nlx2MatCSC(ncsFileName,[1 1 1 1 1], 1, 1, [] );
    
    chNumber(iCh) = unique(ChannelNumbers);
    dataValuesInt(:,iCh) = Samples(:); % assumes all the same size!
end

cADBitVolts = split(Header{17},' '); % field 17 is the ADBitVolts - use to get amploitude in Volts
cbScale = str2double(cADBitVolts{2}); %0.000000030517578125000001; %0.000000061035156250000001;% as comparison: BlackRock: (double(MaxAnalogValue)-double(dataNEV.ElectrodesInfo(1).MinAnalogValue))/(double(dataNEV.ElectrodesInfo(1).MaxDigiValue)-double(dataNEV.ElectrodesInfo(1).MinDigiValue)); %0.25 corresponds to MaxAnalo / MaxDigital Values
data = cbScale * double(dataValuesInt)*1000; %in miliVolts
hdr.org = Header; % assumes same for all macro channels
hdr.Fs = unique(SampleFrequencies);


%% Plot
if usePlot
    figure;hold on;
    for iCh=1:nChannels
        plot(100*(iCh) + data(:,iCh),'-')
        
  %      plot((Timestamps- Timestamps(1))/2000*4, zeros(length(Timestamps),1),'x')
    end
end
