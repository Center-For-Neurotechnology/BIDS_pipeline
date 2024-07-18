function perSessionIEEG(directoryBIDS,sub_XXXX,taskName,ieeg_run,filenameNSx_nsp1,filenameNSx_nsp2, hdrNS3_nsp1, hdrNS3_nsp2)
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
%   - filenameNS3_nsp1: string of the NSP1 .ns3 filename (full path)
%   - filenameNS3_nsp2: string of the NSP2 .ns3 filename (full path)
%   - hdrNS3_nsp1: structure created by perSessionChannelsTSV() containing NSP1 .ns3 headers 
%   - hdrNS3_nsp2: structure created by perSessionChannelsTSV() containing NSP2 .ns3 headers 
% OUTPUTS: 
%   - sub-XXXX_ses-postimp_task-NetworkWake1RAWNSP1_run-01_ieeg.(eeg,edf,
% vmrk, vhdr)

%% file names of the saved ieeg files
filename_IEEG_nsp1 = [directoryBIDS,'/',sub_XXXX,'/ses-postimp/ieeg/',sub_XXXX,'_ses-postimp_task-',taskName,'RAWNSP1_run-',ieeg_run,'_ieeg'];
if ~isempty(filenameNSx_nsp2)
    filename_IEEG_nsp2 = [directoryBIDS,'/',sub_XXXX,'/ses-postimp/ieeg/',sub_XXXX,'_ses-postimp_task-',taskName,'RAWNSP2_run-',ieeg_run,'_ieeg'];
end

%% get variables not in arguement hdr
% nsp1
%tempInv_nsp1 = ~ismember(1:size(hdrNS3_nsp1.hdr.label,1),scalpIndex_nsp1)'; % use in prev perSessionChannelsTSV instead of ~scalpIndex_nsp1
%if ~isempty(filenameNSx_nsp2)
%    tempInv_nsp2 = ~ismember(1:size(hdrNS3_nsp2.hdr.label,1),scalpIndex_nsp2)';
%end

hdrNS3_nsp1.label = hdrNS3_nsp1.hdr.label;  % labels from .ns3 header structure
hdrNS3_nsp1.time{1} = [1:hdrNS3_nsp1.hdr.nSamples]/hdrNS3_nsp1.hdr.Fs{1};   % time vector from .ns3 header structure
hdrNS3_nsp1.fsample = hdrNS3_nsp1.hdr.Fs{1};   % sampling freq from .ns3 header structure
hdrNS3_nsp1.hdr.nSamplesPre = 0;
hdrNS3_nsp1.hdr.nTrials = 1;

% nsp2
if ~isempty(filenameNSx_nsp2)
    hdrNS3_nsp2.label = hdrNS3_nsp2.hdr.label;
    hdrNS3_nsp2.time{1} = [1:hdrNS3_nsp2.hdr.nSamples]/hdrNS3_nsp2.hdr.Fs{1};
    hdrNS3_nsp2.fsample = hdrNS3_nsp2.hdr.Fs{1};
    hdrNS3_nsp2.hdr.nSamplesPre = 0;
    hdrNS3_nsp2.hdr.nTrials = 1;
end

%% getting ns3 eeg data
% opening and reading NSP1 .ns3 file
dataNSx_nsp1 = openNSx(filenameNSx_nsp1, 'read', 'report');
% If cell - keep the last one - it probably had an issue at some point
if iscell(dataNSx_nsp1.Data)
    dataValuesInt_nsp1 =dataNSx_nsp1.Data{end};
else % if it is int16 - what should be! -keep as it is
     dataValuesInt_nsp1 =dataNSx_nsp1.Data;   
end
% Get scaling conversion
% Blackrock packets are off by a factor of 4 in Central 6 and beyond
cbScale_nsp1 = (double(dataNSx_nsp1.ElectrodesInfo(1).MaxAnalogValue)-double(dataNSx_nsp1.ElectrodesInfo(1).MinAnalogValue))/(double(dataNSx_nsp1.ElectrodesInfo(1).MaxDigiValue)-double(dataNSx_nsp1.ElectrodesInfo(1).MinDigiValue)); %0.25 corresponds to MaxAnalo / MaxDigital Values    
scaledData_nsp1 = cbScale_nsp1 * double(dataValuesInt_nsp1); % in chan x sample format

% repeat for NSP2
if ~isempty(filenameNSx_nsp2)
    dataNSx_nsp2 = openNSx(filenameNSx_nsp2, 'read', 'report');
    if iscell(dataNSx_nsp2.Data)
        dataValuesInt_nsp2 =dataNSx_nsp2.Data{end};
    else 
         dataValuesInt_nsp2 =dataNSx_nsp2.Data;   
    end
    cbScale_nsp2 = (double(dataNSx_nsp2.ElectrodesInfo(1).MaxAnalogValue)-double(dataNSx_nsp2.ElectrodesInfo(1).MinAnalogValue))/(double(dataNSx_nsp2.ElectrodesInfo(1).MaxDigiValue)-double(dataNSx_nsp2.ElectrodesInfo(1).MinDigiValue)); %0.25 corresponds to MaxAnalo / MaxDigital Values    
    scaledData_nsp2 = cbScale_nsp2 * double(dataValuesInt_nsp2);
end

%% grabbing the ns3 eeg data
% save the data matrix here: [rows = channels, columns = samples]
% scaledData_nsp1(scalpIndex_nsp1,:) = [];
hdrNS3_nsp1.trial{1} = scaledData_nsp1; %scaledData_nsp1(tempInv_nsp1,1:size(scaledData_nsp1,2));
% scaledData_nsp2(scalpIndex_nsp2,:) = [];
if ~isempty(filenameNSx_nsp2)
    hdrNS3_nsp2.trial{1} = scaledData_nsp2;%scaledData_nsp2(tempInv_nsp2,1:size(scaledData_nsp2,2));
end
        
%% create ieeg files       
% creating hdr from the dataStruct created above
hdrData_nsp1 = ft_fetch_header(hdrNS3_nsp1);
if ~isempty(filenameNSx_nsp2)
    hdrData_nsp2 = ft_fetch_header(hdrNS3_nsp2);
end
% save the files
ft_write_data(filename_IEEG_nsp1, hdrNS3_nsp1.trial{1}, 'header', hdrData_nsp1, 'dataformat', 'brainvision_eeg'); % brainvision files
ft_write_data(filename_IEEG_nsp1, hdrNS3_nsp1.trial{1}, 'header', hdrData_nsp1, 'dataformat', 'edf'); % edf file
if ~isempty(filenameNSx_nsp2)
    ft_write_data(filename_IEEG_nsp2, hdrNS3_nsp2.trial{1}, 'header', hdrData_nsp2, 'dataformat', 'brainvision_eeg');
    ft_write_data(filename_IEEG_nsp2, hdrNS3_nsp2.trial{1}, 'header', hdrData_nsp2, 'dataformat', 'edf');
end

end