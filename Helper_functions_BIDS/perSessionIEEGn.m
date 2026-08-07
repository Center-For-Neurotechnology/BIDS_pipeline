function perSessionIEEGn(directoryBIDS,sub_XXXX,taskName,ieeg_run,foldername_neuralynx,hdrn,posFixNCS,startNSxSec,endNSxSec)

% This function is run once for each session. It creates edf and brain
% vision files (ieeg, .edf, .vmrk, and .vhdr) with raw iEEG data.
% The files will be saved in directoryBIDS\sub_XXXX\ses-postimp\ieeg\
% and have the names
% sub-XXXX_ses-postimp_task-NetworkWake1RAWNSP1_run-01_ieeg.(eeg,edf,
% vmrk, vhdr)
% INPUTS:
%   - directoryBIDS: string of the main folder where the BIDS data is being saved
%   - sub_XXXX: string of the deidentified patient ID
%   - taskName: string of the session task name
%   - ieeg_run: string of the session order
%   - foldername_neuralynx: string of any .nsc filename in the wanted session folder(full path)
%   - hdrn: structure created by perSessionChannelsTSVn() with .nsc headers 
%   - posFixNCS: string after channel name in nsc file name (e.g. for file 'LTMb-Pul9_0017.ncs', posFixNCS = '_0017')
%
% OUTPUTS: 
%   - sub-XXXX_ses-postimp_task-NetworkWake1RAWNSP1_run-01_ieeg.(eeg,edf,
% vmrk, vhdr)

%% file names of the saved ieeg files
filename_IEEGn = [directoryBIDS,'/',sub_XXXX,'/ses-postimp/ieeg/',sub_XXXX,'_ses-postimp_task-',taskName,'RAW_run-',ieeg_run,'_ieeg'];


%% get variables not in arguement hdr
% hdr.label = hdr.hdr.label(tempInv_nsp1);%hdrNS3_nsp1.hdr.label;  % labels from .ns3 header structure % 6/18 don't think this is needed
hdrn.time{1} = [1:hdrn.nSamples]/hdrn.Fs;   % time vector from header structure 
hdrn.fsample = hdrn.Fs;   % sampling freq from original header structure
hdrn.hdr.nSamplesPre = 0;
hdrn.hdr.nTrials = 1;

%% getting ns3 eeg data
% % opening and reading NSP1 .ns3 file
% dataNSx_nsp1 = openNSx(filenameNSx_nsp1, 'read', 'report');
% % If cell - keep the last one - it probably had an issue at some point
% if iscell(dataNSx_nsp1.Data)
%     dataValuesInt_nsp1 =dataNSx_nsp1.Data{end};
% else % if it is int16 - what should be! -keep as it is
%      dataValuesInt_nsp1 =dataNSx_nsp1.Data;   
% end
% % Get scaling conversion
% % Blackrock packets are off by a factor of 4 in Central 6 and beyond
% cbScale_nsp1 = (double(dataNSx_nsp1.ElectrodesInfo(1).MaxAnalogValue)-double(dataNSx_nsp1.ElectrodesInfo(1).MinAnalogValue))/(double(dataNSx_nsp1.ElectrodesInfo(1).MaxDigiValue)-double(dataNSx_nsp1.ElectrodesInfo(1).MinDigiValue)); %0.25 corresponds to MaxAnalo / MaxDigital Values    
% scaledData_nsp1 = cbScale_nsp1 * double(dataValuesInt_nsp1); % in chan x sample format
% 

%% get continuous recordings
hdrn.label(strcmp(hdrn.label, 'SYNC')) = [];
nChannels = numel(hdrn.label);
iChToExclude=[];
[filepath,name,ext] = fileparts(foldername_neuralynx);
for iCh=1:nChannels
%     ncsFileName =[dirData,filesep,hdr.label{iCh},'.ncs']; %'CSC',num2str(iCh)
    ncsFileName = [filepath,'\',hdrn.label{iCh},posFixNCS,'.ncs'];
    [Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples, Samples, Header] = ...
        Nlx2MatCSC(ncsFileName,[1 1 1 1 1], 1, 1, [] );
    if length(unique(ChannelNumbers))==1 && length(unique(SampleFrequencies))   
        dataValuesInt(:,iCh) = Samples(:); % assumes all the same size!
    else
        iChToExclude = [iChToExclude, iCh];
    end
end
% remove corrupt channels
if ~isempty(iChToExclude)
    hdrn.label(iChToExclude)=[];
    dataValuesInt(:,iChToExclude)=[];
    chNumber(iChToExclude)=[];
end

% hdrn.Fs = targetFs;
% t0 = Timestamps(1); % microseconds
% % Convert to datetime in UTC
% dt = datetime(t0/1e6,'ConvertFrom','posixtime','TimeZone','UTC');


cADBitVolts = split(Header{17},' '); % field 17 is the ADBitVolts - use to get amploitude in Volts
cbScale = str2double(cADBitVolts{2}); %0.000000030517578125000001; %0.000000061035156250000001;% as comparison: BlackRock: (double(MaxAnalogValue)-double(dataNEV.ElectrodesInfo(1).MinAnalogValue))/(double(dataNEV.ElectrodesInfo(1).MaxDigiValue)-double(dataNEV.ElectrodesInfo(1).MinDigiValue)); %0.25 corresponds to MaxAnalo / MaxDigital Values
data = cbScale * double(dataValuesInt)*1000; %in miliVolts
data = data'; 

if isempty(startNSxSec), startNSxSec=0; end
if isempty(endNSxSec), endNSxSec=size(data,2)/hdrn.Fs; end
indSamplesOfInterest = round(startNSxSec*hdrn.Fs+1): min(round(endNSxSec*hdrn.Fs),size(data,2));
data = data(:,indSamplesOfInterest); 

hdrn.nSamples = size(data,2);
hdrn.time{1} = [1:hdrn.nSamples]/hdrn.Fs;   % time vector from header structure 


%% grabbing the ns3 eeg data
% save the data matrix here: [rows = channels, columns = samples]
% scaledData_nsp1(scalpIndex_nsp1,:) = [];
hdrn.trial{1} = data;
% save('E:\BIDS_Neuralynx\debug_hdr\perSessionIEEGn_hdr_2','hdrn','-v7.3')
        
% % create ieeg files       
% creating hdr from the dataStruct created above
hdrData = ft_fetch_header(hdrn);


% % save the files
ft_write_data(filename_IEEGn, hdrn.trial{1}, 'header', hdrData, 'dataformat', 'edf'); % edf file

