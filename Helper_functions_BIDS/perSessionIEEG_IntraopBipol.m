function perSessionIEEG_IntraopBipol(directoryBIDS,sub_XXXX,taskName,ieeg_run,LFPData, hdrclin_edf,badChannels,ChannelInfo,EDFWriteFi)
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
%   - hdrclin_edf: structure created by perSessionChannelsTSV() containing NSP1 .ns3 headers 
%   - hdrNS3_nsp2: structure created by perSessionChannelsTSV() containing NSP2 .ns3 headers 
% OUTPUTS: 
%   - sub-XXXX_ses-postimp_task-NetworkWake1RAWNSP1_run-01_ieeg.(eeg,edf,
% vmrk, vhdr)

%% file names of the saved ieeg files
filename_IEEG_edf = [directoryBIDS,'/',sub_XXXX,'/ses-postimp/ieeg/',sub_XXXX,'_ses-postimp_task-',taskName,'Clip_run-',ieeg_run,'_ieeg'];


%% getting ns3 eeg data
% opening and reading NSP1 .ns3 file
% [header,dataNSx_edf] = edfread(filenameNSx_edf);
dataNSx_edf=LFPData;
% If cell - keep the last one - it probably had an issue at some point
% if iscell(dataNSx_edf.Data)
%     dataValuesInt_edf =dataNSx_edf.Data{end};
% else % if it is int16 - what should be! -keep as it is
%      dataValuesInt_edf =dataNSx_edf.Data;   
% end
% Get scaling conversion
% Blackrock packets are off by a factor of 4 in Central 6 and beyond
% cbScale_edf = (double(dataNSx_edf.ElectrodesInfo(1).MaxAnalogValue)-double(dataNSx_edf.ElectrodesInfo(1).MinAnalogValue))/(double(dataNSx_edf.ElectrodesInfo(1).MaxDigiValue)-double(dataNSx_edf.ElectrodesInfo(1).MinDigiValue)); %0.25 corresponds to MaxAnalo / MaxDigital Values    
% scaledData_edf = cbScale_edf * double(dataValuesInt_edf); % in chan x sample format
% scaledData_edf=dataNSx_edf;

%% grabbing the ns3 eeg data   
% save the data matrix here: [rows = channels, columns = samples]
hdrclin_edf.trial{1} = dataNSx_edf; % J: assuming , would just have to see the ns3 format

%% get variables not in arguement hdr
% nsp1
hdrclin_edf.hdr.nSamples=size(dataNSx_edf,2);
hdrclin_edf.label = hdrclin_edf.hdr.label;  % labels from .ns3 header structure
hdrclin_edf.time{1} = [1:hdrclin_edf.hdr.nSamples]/hdrclin_edf.hdr.Fs{1};   % time vector from .ns3 header structure
hdrclin_edf.fsample = hdrclin_edf.hdr.Fs{1};   % sampling freq from .ns3 header structure
hdrclin_edf.hdr.nSamplesPre = 0;
hdrclin_edf.hdr.nTrials = 1;

% for kn=1:length(headerNS3_edf.physicalMin)
%     if headerNS3_edf.physicalMin([kn])==headerNS3_edf.physicalMax([kn])
% headerNS3_edf.physicalMin([kn])=-1;
% headerNS3_edf.physicalMax([kn])=1;
%     end
% end
        
%% create ieeg files       
% creating hdr from the dataStruct created above
% save the files
% ft_write_data(filename_IEEG_edf, hdrclin_edf.trial{1}, 'header', hdrData_edf, 'dataformat', 'brainvision_eeg'); % brainvision files
if EDFWriteFi==1
hdrData_edf = ft_fetch_header(hdrclin_edf);
ft_write_data(filename_IEEG_edf, hdrclin_edf.trial{1}, 'header', hdrData_edf, 'dataformat', 'edf'); % edf file
end
LFPDataCl=LFPData;
SamplingRate=hdrclin_edf.hdr.Fs{1};
save(filename_IEEG_edf, 'LFPDataCl','SamplingRate','badChannels','ChannelInfo','hdrclin_edf'); 

end