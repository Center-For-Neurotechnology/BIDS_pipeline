function [dataBipolarPerCh, chNamesBipolar, dataStim, indTimeAllSTIM, dataReferentialPerCh, chNamesRefToPlot, allChNames, hdr] = GetBipolarEEGFromNeuralynx(dirNeuraLynxData, posFixNCS, selChNames, selBipolar, stimChNames, startNSxSec, endNSxSec, minDistSTIMPulses)
% and as  [dataBipolarPerCh{1}, chNamesBipolar{1}, dataStim, indTimeAllSTIM, dataReferentialPerCh, chNamesRefToPlot, allChNames{1}, hdr] = GetBipolarEEGFromNSX(fileNameNSxPerNSP{1}, selChNames1, selBipolar1, stimAINPChNames, startNSxSec, endNSxSec);


if ~iscell(stimChNames)
    stimChNames = {stimChNames}; % stimChNames must be TOTAL stim (trigger channel, detected stim channel, random stim channel)
end

if ~exist('verbose','var'), verbose=1; end
if ~exist('minDistSTIMPulses','var') || isempty(minDistSTIMPulses) || length(minDistSTIMPulses)<length(stimChNames)
    minDistSTIMPulses= [100, zeros(1,length(stimChNames)-1)]; % 50ms for STIM nothing for other stim - 100 * ones(1,length(stimChNames)); %at least 100 samples (50ms) between individual STIM pulses for all pulses
end

%REMOVE60Hz = 0; % Whether to remove 60Hz line noise -> SFN2019 abstract was analysised without this! -> tends to destroy the response to STIM
howToDeTrend = 'LINEAR';% 'MEAN'; % if 'LINEAR' detrend each channel, if 'MEAN' only remove mean, if empty keep as it is

% 
% hdr=[];
% hdr.Fs          = dataNEV.MetaTags.SamplingFreq;
% hdr.nChans      = dataNEV.MetaTags.ChannelCount;
% hdr.nSamples    = dataNEV.MetaTags.DataPoints;
% hdr.nSamplesPre = 0; % continuous data
% hdr.nTrials     = 1; % continuous data
% hdr.orig        = dataNEV.MetaTags; % remember the original header
% hdr.howToDeTrend = howToDeTrend;
% hdr.startNSxSec = startNSxSec;
% hdr.endNSxSec = endNSxSec;


%% Read CSC files
[data,chNumber, selChNames, header] =  readCSCfiles(dirNeuraLynxData, selChNames, posFixNCS, 0);

%[Data,chNumber, chNames, header] = readCSCfilesChNamesFromXls(dirNeuraLynxData, xlsFileName, posFixNCS);
scaledData = data';
% if isempty(xlsFileName)
%     error(['File ', xlsFileName, ' not found']);
% end

allChNames = selChNames;

hdr = [];
hdr.Fs = header.Fs;
hdr.orig = header.org; % assumes same for all macro channels
hdr.nChans = length(selChNames);
hdr.nSamples = size(scaledData,1);

% Remove Original Date - keep only time to sync better
% hdr.startTimeSec = hdr.orig.DateTimeRaw(5)*3600+ hdr.orig.DateTimeRaw(6)*60+ hdr.orig.DateTimeRaw(7)+hdr.orig.DateTimeRaw(8)/1000;
% hdr.orig.DateTimeRaw(1:4)=[]; 
% hdr.orig.DateTime=[];
% 
% % If cell - keep the last one - it probably had an issue at some point
% if iscell(dataNEV.Data)
%     dataValuesInt =dataNEV.Data{end};
% else % if it is int16 - what should be! -keep as it is
%      dataValuesInt =dataNEV.Data;   
% end

% Get scaling conversion
% Blackrock packets are off by a factor of 4 in Central 6 and beyond
% cbScale = (double(dataNEV.ElectrodesInfo(1).MaxAnalogValue)-double(dataNEV.ElectrodesInfo(1).MinAnalogValue))/(double(dataNEV.ElectrodesInfo(1).MaxDigiValue)-double(dataNEV.ElectrodesInfo(1).MinDigiValue)); %0.25 corresponds to MaxAnalo / MaxDigital Values    
% scaledData = cbScale * double(dataValuesInt);

% % Keep EEG data for each channel of interest
if isempty(endNSxSec), endNSxSec=size(scaledData,2)/hdr.Fs; end
indSamplesOfInterest = round(startNSxSec*hdr.Fs+1): min(round(endNSxSec*hdr.Fs),size(scaledData,2));

%% Detrend selected interval
switch(upper(howToDeTrend))
    case 'LINEAR'
        detrendScaledData = detrend(scaledData(:,indSamplesOfInterest)','linear')';
    case 'MEAN'
        detrendScaledData = detrend(scaledData(:,indSamplesOfInterest)','constant')';
    otherwise
        detrendScaledData = scaledData(:,indSamplesOfInterest);
end

%% Channel organization
% Check that is in selChNames
if isempty(selChNames), selChNames = allChNames(1:min(numel(allChNames),256)); end
if isnumeric(selChNames),selChNames = allChNames(selChNames); end
nReferentialChannels = length(selChNames);
%%

%Only keep selected channels and remove 
iChNotFound=[];
selChNumber=zeros(1,nReferentialChannels);
chNamesRefToPlot=cell(nReferentialChannels,1);
for iCh=1:nReferentialChannels
    %find selected channels
    indChNumber = find(strncmpi(allChNames, selChNames{iCh},length(selChNames{iCh})),1);
    if ~isempty(indChNumber)
        selChNumber(iCh) = indChNumber;
        chNamesRefToPlot(iCh,1) = regexprep(allChNames(selChNumber(iCh))','\W',''); %remove extra spaces and get contacts names
%     else
%         disp(['Channel ',selChNames{iCh},' not found in file ',fileNameNSx])
%         iChNotFound = [iChNotFound, iCh];
%        % selBipolar(find(sum(ismember(selBipolar, iChNotFound),2)),:)=[];
    end
end
selChNumber(iChNotFound)=[];
chNamesRefToPlot(iChNotFound)=[];

nReferentialChannels = length(selChNumber);

if isempty(selBipolar) 
    selBipolar = [1:numel(chNamesRefToPlot)-1; 2:numel(chNamesRefToPlot)]';
end
nBipolarChannels = size(selBipolar,1);

hdr.label       = chNamesRefToPlot;

% ensure that these are column arrays
hdr.label    = hdr.label(:);
if isfield(hdr, 'chantype'), hdr.chantype = hdr.chantype(:); end
if isfield(hdr, 'chanunit'), hdr.chanunit = hdr.chanunit(:); end
 

%% Get EEG data 
%Get Referential data
dataReferentialPerCh = zeros(length(indSamplesOfInterest),nReferentialChannels);
for iCh=1:nReferentialChannels
    dataReferentialPerCh(:,iCh) = detrendScaledData(selChNumber(iCh), :);
end

% Get Bipolar data
 dataBipolarPerCh =[];
 chNamesBipolar = cell(1,0);
 for iBipCh=1:nBipolarChannels
     indCh1 = selChNumber(selBipolar(iBipCh,1));
     indCh2 = selChNumber(selBipolar(iBipCh,2));
     dataBipolarPerCh(:,iBipCh) = detrendScaledData(indCh2,:) - detrendScaledData(indCh1,:); % BIPOLAR channel is CH2-CH1
     chNamesBipolar{iBipCh,1} = [chNamesRefToPlot{selBipolar(iBipCh,2)} ,'-', chNamesRefToPlot{selBipolar(iBipCh,1)}]; % BIPOLAR channel is CH2-CH1
 end
%  indLastCh = length(chNamesBipolar);
%  for iBipCh=max(selBipolar(:))+1:nReferentialChannels  %Add analog inputs or other referential channels at the end
%      indLastCh = indLastCh +1;
%      indCh1 = selChNumber(iBipCh);
%      dataBipolarPerCh(:,indLastCh) = scaledData(indCh1,indSamplesOfInterest);
%      chNamesBipolar(indLastCh,1) = chNamesRefToPlot(iBipCh);
%  end
nBipolarChannels = size(chNamesBipolar,1); % Update including referntials at the end!



%% Get stim info
% % Detect pulses on analog inputs from NSP data
% for iStimType=1:length(stimChNames)
%     stimChNumber = find(strncmpi(allChNames, stimChNames{iStimType},length(stimChNames{iStimType})),1);
%     if ~isempty(stimChNumber)
%         dataStim{iStimType} = abs(scaledData(stimChNumber, indSamplesOfInterest));
%         thPulse = min(300, max([dataStim{:}])/3); % 1/3 of the max or 300mV DIFF 
%         indTimeAllSTIMPulses = find(diff([0 dataStim{iStimType}]) >= thPulse); % Find all STIM pulses
%     else
%         disp(['Stim name: ',num2str(iStimType),' - ',stimChNames{iStimType},' does NOT exist'])
%         indTimeAllSTIMPulses=[];
%         dataStim{iStimType} =[];
%     end
%     if length(minDistSTIMPulses)>=iStimType && minDistSTIMPulses(iStimType)>0
%         indRepeatedPulses = find(diff([ 0 indTimeAllSTIMPulses])< minDistSTIMPulses(iStimType));
%         indTimeAllSTIMPulses(indRepeatedPulses) = [];% Get only first point of the pulse - remove subsequent points
%     end
%     indTimeAllSTIM{iStimType}  = indTimeAllSTIMPulses;
% end



%% Get stim info

% read stim AINP data to create epochs
[stimData,chNumberSTIM, chNamesSTIM, hdrStim] =  readCSCfiles(dirNeuraLynxData, stimChNames, posFixNCS, 1); % it is NEGATIVE!
% we might need to accomodate differnt sampling rates!
if hdrStim.Fs ~= hdr.Fs 
    stimData = downsample(stimData, round(hdrStim.Fs / hdr.Fs)); % assuming multiples! - no need for LP filtering because this is only to get stim timing
end
indSamplesOfInterestStim = intersect(indSamplesOfInterest, 1:length(stimData));
dataStim{1} = (stimData(indSamplesOfInterestStim))';

thPulse = min(300, max([dataStim{1}])/3); % 1/3 of the max or 300mV DIFF
indTimeAllSTIMPulses = find(diff([0 dataStim{1}]) >= thPulse); % Find all STIM pulses

% Detect pulses on analog inputs from NSP data

if length(minDistSTIMPulses)>=1 && minDistSTIMPulses(1)>0
    indRepeatedPulses = find(diff([ 0 indTimeAllSTIMPulses])< minDistSTIMPulses(1));
    indTimeAllSTIMPulses(indRepeatedPulses) = [];% Get only first point of the pulse or train - remove subsequent points
end
indTimeAllSTIM{1}  = indTimeAllSTIMPulses;
hdr.hdrStim = hdrStim;
hdr.stimFs = hdrStim.Fs;
hdr.stimChNumber = chNumberSTIM;
hdr.stimChName = chNamesSTIM;
end


