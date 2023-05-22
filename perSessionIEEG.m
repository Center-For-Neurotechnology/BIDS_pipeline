function perSessionIEEG(directoryBIDS,sub_XXXX,taskName,ieeg_run,filenameNSx_nsp1,filenameNSx_nsp2, hdrNS3_nsp1, hdrNS3_nsp2)
%% according to the FT_function we just need:
% - filename = how we want to save the brainvision & edf file (w/o the
%   extensions, the FT scripts add that already)
% - hdr = hdr information, should get the required from the FT script but
%   the recommended from ACP's script
% - dat = data in [nchans, nsamples] = size(dat)
% - evt =  DON'T NEED

%% filenames of the output ieeg files
filename_IEEG_nsp1 = [directoryBIDS,'/',sub_XXXX,'/ses-postimp/ieeg/',sub_XXXX,'_ses-postimp_task-',taskName,'RAWNSP1_run-',ieeg_run,'_ieeg'];
filename_IEEG_nsp2 = [directoryBIDS,'/',sub_XXXX,'/ses-postimp/ieeg/',sub_XXXX,'_ses-postimp_task-',taskName,'RAWNSP2_run-',ieeg_run,'_ieeg'];

%% get variables not in arguement hdr
% dataStruct.sampleinfo = [1:dataStruct.hdr.nSamples]; %J: defines which samples are part of different trials, don't need if it's a continuous piece of data

% nsp1
hdrNS3_nsp1.label = hdrNS3_nsp1.hdr.label;  % labels from hdr again
hdrNS3_nsp1.time{1} = [1:hdrNS3_nsp1.hdr.nSamples]/hdrNS3_nsp1.hdr.Fs{1};   % time vector using info from hdr
hdrNS3_nsp1.fsample = hdrNS3_nsp1.hdr.Fs{1};   % sampling freq from hdr again
hdrNS3_nsp1.hdr.nSamplesPre = 0; % J: don't know, ask, keeing for now
hdrNS3_nsp1.hdr.nTrials = 1; % J: don't know, ask, keeping for now

% nsp2
hdrNS3_nsp2.label = hdrNS3_nsp2.hdr.label;  % labels from hdr again
hdrNS3_nsp2.time{1} = [1:hdrNS3_nsp2.hdr.nSamples]/hdrNS3_nsp2.hdr.Fs{1};   % time vector using info from hdr
hdrNS3_nsp2.fsample = hdrNS3_nsp2.hdr.Fs{1};   % sampling freq from hdr again
hdrNS3_nsp2.hdr.nSamplesPre = 0; % J: don't know, ask, keeing for now
hdrNS3_nsp2.hdr.nTrials = 1; % J: don't know, ask, keeping for now

%% getting ns3 eeg data
% from Rina's GetBipolarEEGFromNSX.m
dataNSx_nsp1 = openNSx(filenameNSx_nsp1, 'read', 'report'); %,'uV');
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

dataNSx_nsp2 = openNSx(filenameNSx_nsp2, 'read', 'report'); %,'uV');
% If cell - keep the last one - it probably had an issue at some point
if iscell(dataNSx_nsp2.Data)
    dataValuesInt_nsp2 =dataNSx_nsp2.Data{end};
else % if it is int16 - what should be! -keep as it is
     dataValuesInt_nsp2 =dataNSx_nsp2.Data;   
end

% Get scaling conversion
% Blackrock packets are off by a factor of 4 in Central 6 and beyond
cbScale_nsp2 = (double(dataNSx_nsp2.ElectrodesInfo(1).MaxAnalogValue)-double(dataNSx_nsp2.ElectrodesInfo(1).MinAnalogValue))/(double(dataNSx_nsp2.ElectrodesInfo(1).MaxDigiValue)-double(dataNSx_nsp2.ElectrodesInfo(1).MinDigiValue)); %0.25 corresponds to MaxAnalo / MaxDigital Values    
scaledData_nsp2 = cbScale_nsp2 * double(dataValuesInt_nsp2);

 %% where to put ns3 eeg data   
% put the data matrix here: electrodes x samples
% will have to actually read ns3 for this        
% J: fieldtrip : [nchans, nsamples] = size(dat);
hdrNS3_nsp1.trial{1} = scaledData_nsp1; % J: assuming [rows = channels, columns = samples], would just have to see the ns3 format
hdrNS3_nsp2.trial{1} = scaledData_nsp2;
        
 %% create ieeg files       
% creating hdr from the dataStruct created above
hdrData_nsp1 = ft_fetch_header(hdrNS3_nsp1);
hdrData_nsp2 = ft_fetch_header(hdrNS3_nsp2);
% save the data
ft_write_data(filename_IEEG_nsp1, hdrNS3_nsp1.trial{1}, 'header', hdrData_nsp1, 'dataformat', 'brainvision_eeg');
ft_write_data(filename_IEEG_nsp1, hdrNS3_nsp1.trial{1}, 'header', hdrData_nsp1, 'dataformat', 'edf');
ft_write_data(filename_IEEG_nsp2, hdrNS3_nsp2.trial{1}, 'header', hdrData_nsp2, 'dataformat', 'brainvision_eeg');
ft_write_data(filename_IEEG_nsp2, hdrNS3_nsp2.trial{1}, 'header', hdrData_nsp2, 'dataformat', 'edf');

end