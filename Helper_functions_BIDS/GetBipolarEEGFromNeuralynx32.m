function [dataBipolarPerCh, chNamesBipolar, dataStim, indTimeAllSTIM, dataReferentialPerCh, chNamesRefToPlot, allChNames, hdr] = GetBipolarEEGFromNeuralynx32(posFixNCS, dirPatient, dirData, xlsFileName, selChNames, selBipolar, stimChNames, startNSxSec, endNSxSec, minDistSTIMPulses)
% returns bipolar data from the recording along with the Sync AINP timings
% The 32 in the function refers to the fact that this function works for
% both cases - where the AINP is sampled at 2k and at 32k.




% chNamesSTIM = 'CSC289'; % this is where SYNC (AINP1) is
chNamesSTIM = stimChNames;




%%
%Gets data from NS3 files (from BlackRock NSP) at the time of STIM
if ~iscell(stimChNames)
    stimChNames = {stimChNames}; % stimChNames must be TOTAL stim (trigger channel, detected stim channel, random stim channel)
end

if ~exist('verbose','var'), verbose=1; end
if ~exist('minDistSTIMPulses','var') || length(minDistSTIMPulses)<=1
    minDistSTIMPulses= [100, zeros(1,length(stimChNames)-1)]; % 50ms for STIM nothing for other stim - 100 * ones(1,length(stimChNames)); %at least 100 samples (50ms) between individual STIM pulses for all pulses
end

%REMOVE60Hz = 0; % Whether to remove 60Hz line noise -> SFN2019 abstract was analysised without this! -> tends to destroy the response to STIM
howToDeTrend = 'LINEAR';% 'MEAN'; % if 'LINEAR' detrend each channel, if 'MEAN' only remove mean, if empty keep as it is

%% Load Data from NSx files



[Data,chNumber, chNames, header] = readCSCfilesChNamesFromXls_incBlanks(dirData, xlsFileName, posFixNCS);
scaledData = Data';


allChNames = chNames;

hdr = [];
hdr.Fs = header.Fs;
hdr.orig = header.orig; % assumes same for all macro channels
hdr.nChans = length(selChNames);
hdr.nSamples = size(scaledData,1);



% % Keep EEG data for each channel of interest
if isempty(startNSxSec), startNSxSec=0; end
if isempty(endNSxSec), endNSxSec=size(scaledData,2)/hdr.Fs; end
indSamplesOfInterest = round(startNSxSec*hdr.Fs+1): min(round(endNSxSec*hdr.Fs),size(scaledData,2));
% if isempty(endNSxSec), endNSxSec=size(scaledData,2)/hdr.Fs; end
% indSamplesOfInterest = round(startNSxSec*hdr.Fs+1): min(round(endNSxSec*hdr.Fs),size(scaledData,2));

%% Clean - commented: it destroid the edges of the response to STIM
% % Remove 60Hz by applying a moving averaged with Savitzky-Golay (filters of order Fs/60 (should be changed to 50 if in europe!)
% if REMOVE60Hz
%     cleanData = sgolayfilt(scaledData(:,indSamplesOfInterest)', 1, round(hdr.Fs/60));
% else
%     cleanData = scaledData(:,indSamplesOfInterest)';
% end

% Detrend selected interval
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

%% Remove NaN

selChNames2 = cell(1,0);
count = 1;
for i = 1:length(selChNames)
    if (~isempty(selChNames{i})) & (~isnan(selChNames{i}))
        selChNames2{count} = selChNames{i};
        count = count + 1;
    end
end
selChNames = selChNames2;

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

nBipolarChannels = size(chNamesBipolar,1); % Update including referntials at the end!



%% Get stim info




% read stim AINP data to create epochs
[stimData,chNumberSTIM, chNamesSTIM, hdrStim] =  readCSCfiles(dirData, chNamesSTIM, posFixNCS, 1); % it is NEGATIVE!


if hdrStim.Fs ~= hdr.Fs 
    stimData = downsample(stimData, round(hdrStim.Fs / hdr.Fs)); % assuming multiples! - no need for LP filtering because this is only to get stim timing
end
indSamplesOfInterestStim = intersect(indSamplesOfInterest, 1:length(stimData));
dataStim{1} = (stimData(indSamplesOfInterestStim))';

% thPulse = min(300, max([dataStim{1}])/3); % 1/3 of the max or 300mV DIFF
% thPulse = 0.04; % changed  for MG245 bc of sync unconnected
thPulse = 2; %changed for BW101 usually '1'
indTimeAllSTIMPulses = find(diff([dataStim{1} 0]) <= -thPulse);
% Detect pulses on analog inputs from NSP data
if length(minDistSTIMPulses)>=1 && minDistSTIMPulses(1)>0
    indRepeatedPulses = find(diff([ 0 indTimeAllSTIMPulses])< minDistSTIMPulses(1));
    indTimeAllSTIMPulses(indRepeatedPulses) = [];% Get only first point of the pulse - remove subsequent points
end

indTimeAllSTIM{1}  = indTimeAllSTIMPulses;

end


