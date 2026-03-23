function [hdrclin_edf] = perSessionChannelsTSVEDF(directoryBIDS,sub_XXXX,taskName,ieeg_run,filenameNS3_edf,badChannels_edf)
% This function is run once for each session. It creates a tsv file
% containing channel details.
% The tsv file will be saved in directoryBIDS\sub_XXXX\ses-postimp\ieeg\
% and have the name sub-XXXX_ses-postimp_task-TaskRAWNSP1_run-01_channels.tsv
% INPUTS:
%   - directoryBIDS: string of the main folder where the BIDS data is being saved
%   - sub_XXXX: string of the deidentified patient ID
%   - taskName: string of the session task name
%   - ieeg_run: string of the session order
%   - filenameNS3_edf: string of the edf .ns3 filename (full path)
%   - filenameNS3_nsp2: string of the NSP2 .ns3 filename (full path)
%   - badChannels_edf: string of the filename (full path) containing the
%       bad channel numbers in edf, can be empty
%   - badChannels_nsp2: string of the filename (full path) containing the
%       bad channel numbers in NSP2, can be empty
% OUTPUTS: 
%   - sub-XXXX_ses-postimp_task-TaskRAWNSP1_run-01_channels.tsv
%   - hdrclin_edf: structure containing edf .ns3 headers needed for
%       functions perSessionIEEG() and perSessionEventsTSV()
%   - hdrNS3_nsp2: structure containing NSP2 .ns3 headers needed for
%       functions perSessionIEEG() and perSessionEventsTSV()

%% file names of the saved .tsv files
filename_channelsTSV_edf = [directoryBIDS,'/',sub_XXXX,'/ses-postimp/ieeg/',sub_XXXX,'_ses-postimp_task-',...
    taskName,'RAWEDF_run-',ieeg_run,'_channels.tsv'];
filename_channelsTSV_nsp2 = [];

%% open ns3 headers
% [headerNS3_edf ] = edfread(filenameNS3_edf,'noread');
[headerNS3_edf] = edfread(filenameNS3_edf);
% headerNS3_nsp2 = openNSx(filenameNS3_nsp2,'noread');

%% REQUIRED
%% get channel names
channelNames_edf = headerNS3_edf.label';
channelNames_edf = regexprep(string(channelNames_edf), '\W', ''); % getting rid of whitespace
% channelNames_nsp2 = extractfield(headerNS3_nsp2.ElectrodesInfo,'Label')';
% channelNames_nsp2 = regexprep(string(channelNames_nsp2), '\W', '');

%% get channel types
% edf
% categorizing each channel name into a group (SEEG,EEG,EOC,EMG,ECG,MISC,TRIG)
channelType_edf_SEEG = regexp(channelNames_edf, '^(L|R)[a-zA-Z]{2,3}\d{1,2}$');
channelType_edf_EEG = regexp(channelNames_edf, '^[FTOCPS].{0,}[\dZzIiAaRrEeTt]$');
channelType_edf_EOC = regexp(channelNames_edf, '^(L|R)OC$');
channelType_edf_EMG = regexp(channelNames_edf, '^EMG');
channelType_edf_ECG = regexp(channelNames_edf, '(^EKG|Pulse)');
channelType_edf_MISC = regexp(channelNames_edf, '(^RESP|chan|empty|broke|BLANK|BLA1|1\d{2,}%)');
channelType_edf_TRIG = regexp(channelNames_edf, 'trigger','ignorecase');
channelType_edf_DC = regexp(channelNames_edf, 'DC','ignorecase');
% creating cell with channel types to use in tsv 
channelType_edf_all = cell(size(channelNames_edf));

for i = 1:size(channelNames_edf)
    if ~isempty(channelType_edf_TRIG{i})
        channelType_edf_all{i} = 'TRIG';
    elseif ~isempty(channelType_edf_DC{i})
        channelType_edf_all{i} = 'TRIG';
    elseif ~isempty(channelType_edf_EEG{i})
        channelType_edf_all{i} = 'EEG';
    elseif ~isempty(channelType_edf_EOC{i})
        channelType_edf_all{i} = 'EOC';
    elseif ~isempty(channelType_edf_EMG{i})
        channelType_edf_all{i} = 'EMG';
    elseif ~isempty(channelType_edf_ECG{i})
        channelType_edf_all{i} = 'ECG';
    elseif ~isempty(channelType_edf_MISC{i})
        channelType_edf_all{i} = 'MISC';
    elseif ~isempty(channelType_edf_SEEG{i})
        channelType_edf_all{i} = 'SEEG';
    else 
        channelType_edf_all{i} = 'TRIG';
    end
end

% repeat for NSP2
% categorizing each channel name into a group (SEEG,EEG,EOC,EMG,ECG,MISC,TRIG)
% channelType_nsp2_SEEG = regexp(channelNames_nsp2, '^(L|R)[a-zA-Z]{2,3}\d{1,2}$');
% channelType_nsp2_EEG = regexp(channelNames_nsp2, '^[FTOCPS].{0,}[\dZzIiAaRrEeTt]$');
% channelType_nsp2_EOC = regexp(channelNames_nsp2, '^(L|R)OC$');
% channelType_nsp2_EMG = regexp(channelNames_nsp2, '^EMG');
% channelType_nsp2_ECG = regexp(channelNames_nsp2, '(^EKG|Pulse)');
% channelType_nsp2_MISC = regexp(channelNames_nsp2, '(^RESP|chan|empty|broke|BLANK|BLA1|1\d{2,}%)');
% channelType_nsp2_TRIG = regexp(channelNames_nsp2, 'trigger','ignorecase');
% 
% % creating cell with channel types to use in tsv 
% channelType_nsp2_all = cell(size(channelNames_nsp2));
% for i = 1:size(channelNames_nsp2)
%     if ~isempty(channelType_nsp2_TRIG{i})
%         channelType_nsp2_all{i} = 'TRIG';
%     elseif ~isempty(channelType_nsp2_EEG{i})
%         channelType_nsp2_all{i} = 'EEG';
%     elseif ~isempty(channelType_nsp2_EOC{i})
%         channelType_nsp2_all{i} = 'EOC';
%     elseif ~isempty(channelType_nsp2_EMG{i})
%         channelType_nsp2_all{i} = 'EMG';
%     elseif ~isempty(channelType_nsp2_ECG{i})
%         channelType_nsp2_all{i} = 'ECG';
%     elseif ~isempty(channelType_nsp2_MISC{i})
%         channelType_nsp2_all{i} = 'MISC';
%     elseif ~isempty(channelType_nsp2_SEEG{i})
%         channelType_nsp2_all{i} = 'SEEG';
%     else 
%         channelType_nsp2_all{i} = 'TRIG';
%     end
% end

%% get voltage unit in each channel 
units_edf = headerNS3_edf.units';
units_edf = regexprep(string(units_edf), '\W', '');
% units_nsp2 = extractfield(headerNS3_nsp2.ElectrodesInfo,'AnalogUnits')';
% units_nsp2 = regexprep(string(units_nsp2), '\W', '');

%% get frequency cutoffs
% lowCutoff_edf = extractfield(headerNS3_edf.ElectrodesInfo,'LowFreqCorner')'; % saved in mHz so /1000
% highCutoff_edf = extractfield(headerNS3_edf.ElectrodesInfo,'HighFreqCorner')';
lowCutoff_edf = cell(size(channelNames_edf));
lowCutoff_edf(:) = {0.5};
highCutoff_edf = cell(size(channelNames_edf));
highCutoff_edf(:) = {512};
% lowCutoff_nsp2 = extractfield(headerNS3_nsp2.ElectrodesInfo,'LowFreqCorner')'/1000;
% highCutoff_nsp2 = extractfield(headerNS3_nsp2.ElectrodesInfo,'HighFreqCorner')'/1000;

%% RECOMMENDED
%% reference
reference_edf = cell(size(channelNames_edf));
reference_edf(:) = {'mastoid'};
% reference_nsp2 = cell(size(channelNames_nsp2));
% reference_nsp2(:) = {'mastoid'};

%% get channel groups (electrode, scalp, trigger, etc)
channelGroup_edf_all = cell(size(channelNames_edf));
for i = 1:size(channelNames_edf,1)
    if ~isempty(channelType_edf_SEEG{i})
      channelGroup_edf_all{i} = regexp(channelNames_edf{i}, '^(L|R)[a-zA-Z]{2,3}','match');
    else
      channelGroup_edf_all{i} = channelNames_edf{i};
    end
end

% channelGroup_nsp2_all = cell(size(channelNames_nsp2));
% for i = 1:size(channelNames_nsp2,1)
%     if ~isempty(channelType_nsp2_SEEG{i})
%       channelGroup_nsp2_all{i} = regexp(channelNames_nsp2{i}, '^(L|R)[a-zA-Z]{2,3}','match');
%     elsesamplingFrequency_nsp1
%       channelGroup_nsp2_all{i} = channelNames_nsp2{i};
%     end
% end

%% OPTIONAL
%% getting sampling frequency
samplingFrequency_edf = cell(size(channelNames_edf));
samplingFrequency_edf(:) = {1024};
% samplingFrequency_nsp2 = cell(size(channelNames_nsp2));
% samplingFrequency_nsp2(:) = {headerNS3_nsp2.MetaTags.SamplingFreq};

%% recording data type
description_edf = cell(size(channelNames_edf));
description_edf(:) = {'referential/unipolar'};
% description_nsp2 = cell(size(channelNames_nsp2));
% description_nsp2(:) = {'referential/unipolar'};

%% notch (set to 'n/a')
notch_edf = cell(size(channelNames_edf));
notch_edf(:) = {'n/a'};
% notch_nsp2 = cell(size(channelNames_nsp2));
% notch_nsp2(:) = {'n/a'};

%% channel status (only for SEEG or ECOG)
channelNames_edfCell = headerNS3_edf.label';

status_edf = cell(size(channelNames_edf));
if ~isempty(badChannels_edf)
%     badChannels_edf = load(badChannels_edf);
%     badChannels_edf = badChannels_edf;
    
    for i = 1:size(channelNames_edf,1)
        if strcmp(channelType_edf_all{i},'SEEG') || strcmp(channelType_edf_all{i},'ECOG')
            if ~isempty(cell2mat(strfind(badChannels_edf,channelNames_edfCell{i}))) % channel with respect to nps1 (1:128)
                status_edf{i} = 'bad';
%                 'bad'
%                 pause
            else
                status_edf{i} = 'good';
            end
        else
            status_edf{i} = 'n/a';
        end
    end
else
    status_edf(:) = {'n/a'};
end

% status_nsp2 = cell(size(channelNames_nsp2));
% if ~isempty(badChannels_nsp2)
%     badChannels_nsp2 = load(badChannels_nsp2);
%     badChannels_nsp2 = badChannels_nsp2.badChannels;
%     
%     for i = 1:size(channelNames_nsp2,1)
%         if strcmp(channelType_nsp2_all{i},'SEEG') || strcmp(channelType_nsp2_all{i},'ECOG')
%             if ismember(i,badChannels_nsp2) % channel number with respect to nsp2 (1:128)
%                 status_nsp2{i} = 'bad';
%             else
%                 status_nsp2{i} = 'good';
%             end
%         else
%             status_nsp2{i} = 'n/a';
%         end
%     end
% else
%     status_nsp2(:) = {'n/a'};
% end

%% status description (set to 'n/a')
statusDescription_edf = cell(size(channelNames_edf));
statusDescription_edf(:) = {'n/a'};
% statusDescription_nsp2 = cell(size(channelNames_nsp2));
% statusDescription_nsp2(:) = {'n/a'};

%% create tables and save tsv files
varNames = {'name','type','units','low_cutoff','high_cutoff','reference','group','sampling_frequency',...
    'description','notch','status','status_description'};

table_channelsTSV_nsp1 = table(channelNames_edf, channelType_edf_all, units_edf, lowCutoff_edf, highCutoff_edf, ...
    reference_edf, channelGroup_edf_all, samplingFrequency_edf, description_edf, notch_edf, ...
    status_edf, statusDescription_edf, 'VariableNames', varNames);

% table_channelsTSV_nsp2 = table(channelNames_nsp2, channelType_nsp2_all, units_nsp2, lowCutoff_nsp2, highCutoff_nsp2, ...
%     reference_nsp2, channelGroup_nsp2_all, samplingFrequency_nsp2, description_nsp2, notch_nsp2, ...
%     status_nsp2, statusDescription_nsp2, 'VariableNames', varNames);

writetable(table_channelsTSV_nsp1, filename_channelsTSV_edf, 'FileType', 'text', 'Delimiter', '\t');
% writetable(table_channelsTSV_nsp2, filename_channelsTSV_nsp2, 'FileType', 'text', 'Delimiter', '\t');

%% saving hdr info for needed for other functions
% edf    
hdrclin_edf.hdr.Fs = samplingFrequency_edf;    % sampling frequency
hdrclin_edf.hdr.nChans = length(headerNS3_edf.label); %  number of channels
hdrclin_edf.hdr.label = cellstr(channelNames_edf);     % channel name (eg. RAMY1)
hdrclin_edf.hdr.nSamples = headerNS3_edf.samples';    % number of samples
hdrclin_edf.hdr.chantype = channelType_edf_all; % channel types
hdrclin_edf.hdr.chanunit = cellstr(units_edf); % recording voltage units
% nsp2
% hdrNS3_nsp2.hdr.Fs = samplingFrequency_nsp2; 
% hdrNS3_nsp2.hdr.nChans = headerNS3_nsp2.MetaTags.ChannelCount; 
% hdrNS3_nsp2.hdr.label = channelNames_nsp2; 
% hdrNS3_nsp2.hdr.nSamples = headerNS3_nsp2.MetaTags.DataPoints; 
% hdrNS3_nsp2.hdr.chantype = channelType_nsp2_all; 
% hdrNS3_nsp2.hdr.chanunit = cellstr(units_nsp2); 

end