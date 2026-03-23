function [hdrclin_edf] = perSessionChannelsTSVIntraop(directoryBIDS,sub_XXXX,taskName,ieeg_run,channelInfo,badChannels,SamplingRate,reference)
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
filename_channelsTSV_Intraop = [directoryBIDS,'/',sub_XXXX,'/ses-postimp/ieeg/',sub_XXXX,'_ses-postimp_task-',...
    taskName,'Clip_run-',ieeg_run,'_channels.tsv'];

%% open Electrode information headers
headerNS3_edf.label=table2cell(channelInfo(:,1));
% [headerNS3_edf ] = edfread(filenameNS3_edf,'noread');
% [headerNS3_edf] = edfread(filenameNS3_edf);
% headerNS3_nsp2 = openNSx(filenameNS3_nsp2,'noread');

%% REQUIRED
%% get channel names
channelNames_Clip = headerNS3_edf.label;
% channelNames_Clip = regexprep(string(channelNames_Clip), '\W', ''); % getting rid of whitespace
% channelNames_nsp2 = extractfield(headerNS3_nsp2.ElectrodesInfo,'Label')';
% channelNames_nsp2 = regexprep(string(channelNames_nsp2), '\W', '');

%% get channel types
% edf
% categorizing each channel name into a group (SEEG,EEG,EOC,EMG,ECG,MISC,TRIG)
% channelType_Clip_SEEG = regexp(channelNames_Clip, '^(L|R)[a-zA-Z]{2,3}\d{1,2}$');
% channelType_Clip_EEG = regexp(channelNames_Clip, '^[FTOCPS].{0,}[\dZzIiAaRrEeTt]$');
% channelType_Clip_EOC = regexp(channelNames_Clip, '^(L|R)OC$');
% channelType_Clip_EMG = regexp(channelNames_Clip, '^EMG');
% channelType_Clip_ECG = regexp(channelNames_Clip, '(^EKG|Pulse)');
% channelType_Clip_MISC = regexp(channelNames_Clip, '(^RESP|chan|empty|broke|BLANK|BLA1|1\d{2,}%)');
% channelType_Clip_TRIG = regexp(channelNames_Clip, 'trigger','ignorecase');
% channelType_Clip_DC = regexp(channelNames_Clip, 'DC','ignorecase');
% % creating cell with channel types to use in tsv 
% channelType_Clip_all = cell(size(channelNames_Clip));
% 
% for i = 1:size(channelNames_Clip)
%     if ~isempty(channelType_Clip_TRIG{i})
%         channelType_Clip_all{i} = 'TRIG';
%     elseif ~isempty(channelType_Clip_DC{i})
%         channelType_Clip_all{i} = 'TRIG';
%     elseif ~isempty(channelType_Clip_EEG{i})
%         channelType_Clip_all{i} = 'EEG';
%     elseif ~isempty(channelType_Clip_EOC{i})
%         channelType_Clip_all{i} = 'EOC';
%     elseif ~isempty(channelType_Clip_EMG{i})
%         channelType_Clip_all{i} = 'EMG';
%     elseif ~isempty(channelType_Clip_ECG{i})
%         channelType_Clip_all{i} = 'ECG';
%     elseif ~isempty(channelType_Clip_MISC{i})
%         channelType_Clip_all{i} = 'MISC';
%     elseif ~isempty(channelType_Clip_SEEG{i})
%         channelType_Clip_all{i} = 'SEEG';
%     else 
%         channelType_Clip_all{i} = 'TRIG';
%     end
% end

channelType_Clip_all=table2cell(channelInfo(:,5));


%% get voltage unit in each channel 

channelUnit = cell(size(channelNames_Clip));

for i = 1:size(channelNames_Clip,1)
        channelUnit{i} = 'uV';
end

units_edf = channelUnit;
% units_edf = regexprep(string(units_edf), '\W', '');

%% get frequency cutoffs
% lowCutoff_edf = extractfield(headerNS3_edf.ElectrodesInfo,'LowFreqCorner')'; % saved in mHz so /1000
% highCutoff_edf = extractfield(headerNS3_edf.ElectrodesInfo,'HighFreqCorner')';
lowCutoff_edf = cell(size(channelNames_Clip));
lowCutoff_edf(:) = {0.5};
highCutoff_edf = cell(size(channelNames_Clip));
highCutoff_edf(:) = {round(SamplingRate/2)};

%% RECOMMENDED
%% reference
reference_edf = cell(size(channelNames_Clip));
reference_edf(:) = {reference};

%% get channel groups (electrode, scalp, trigger, etc)
channelGroup_edf_all = table2cell(channelInfo(:,8));
% for i = 1:size(channelNames_Clip,1)
%     if ~isempty(channelType_Clip_SEEG{i})
%       channelGroup_edf_all{i} = regexp(channelNames_Clip{i}, '^(L|R)[a-zA-Z]{2,3}','match');
%     else
%       channelGroup_edf_all{i} = channelNames_Clip{i};
%     end
% end


%% OPTIONAL
%% getting sampling frequency
samplingFrequency_edf = cell(size(channelNames_Clip));
samplingFrequency_edf(:) = {SamplingRate};
% samplingFrequency_nsp2 = cell(size(channelNames_nsp2));
% samplingFrequency_nsp2(:) = {headerNS3_nsp2.MetaTags.SamplingFreq};

%% recording data type
description_edf = cell(size(channelNames_Clip));
description_edf(:) = {'referential/unipolar'};

%% notch (set to 'n/a')
notch_edf = cell(size(channelNames_Clip));
notch_edf(:) = {'n/a'};
% notch_nsp2 = cell(size(channelNames_nsp2));
% notch_nsp2(:) = {'n/a'};

%% channel status (only for SEEG or ECOG)
channelNames_edfCell = headerNS3_edf.label;

status_2 = cell(size(channelNames_Clip));
if ~isempty(badChannels)
    
    for i = 1:size(channelNames_Clip,1)
        if strcmp(channelType_Clip_all{i},'SEEG') || strcmp(channelType_Clip_all{i},'ECOG')
            % if ~isempty(cell2mat(strfind(badChannels_edf,channelNames_edfCell{i}))) % channel with respect to nps1 (1:128)
            if badChannels(i,1)==0 % channel with respect to nps1 (1:128)
                status_2{i} = 'bad';
%                 'bad'
%                 pause
            else
                status_2{i} = 'good';
            end
        else
            status_2{i} = 'n/a';
        end
    end
else
    status_2(:) = {'n/a'};
end

%% status description (set to 'n/a')
description_edf = table2cell(channelInfo(:,11));

%% status description (set to 'n/a')
statusDescription_edf = cell(size(channelNames_Clip));
statusDescription_edf(:) = {'n/a'};

%% create tables and save tsv files
varNames = {'name','type','units','low_cutoff','high_cutoff','reference','group','sampling_frequency',...
    'description','notch','status','status_description'};

table_channelsTSV_nsp1 = table(channelNames_Clip, channelType_Clip_all, units_edf, lowCutoff_edf, highCutoff_edf, ...
    reference_edf, channelGroup_edf_all, samplingFrequency_edf, description_edf, notch_edf, ...
    status_2, statusDescription_edf, 'VariableNames', varNames);

t2C=table2cell(table_channelsTSV_nsp1);
t2C1=[varNames;t2C];
% writecell(t2C1, filename_channelsTSV_Intraop, 'FileType', 'text', 'Delimiter', '\t')
writetable(table_channelsTSV_nsp1, filename_channelsTSV_Intraop, 'FileType', 'text', 'Delimiter', '\t','WriteVariableNames', true);

%% saving hdr info for needed for other functions
% edf    
hdrclin_edf.hdr.Fs = samplingFrequency_edf;    % sampling frequency
hdrclin_edf.hdr.nChans = length(headerNS3_edf.label); %  number of channels
hdrclin_edf.hdr.label = cellstr(channelNames_Clip);     % channel name (eg. RAMY1)
% hdrclin_edf.hdr.nSamples = headerNS3_edf.samples';    % number of samples
hdrclin_edf.hdr.chantype = channelType_Clip_all; % channel types
hdrclin_edf.hdr.chanunit = cellstr(units_edf); % recording voltage units
% nsp2
% hdrNS3_nsp2.hdr.Fs = samplingFrequency_nsp2; 
% hdrNS3_nsp2.hdr.nChans = headerNS3_nsp2.MetaTags.ChannelCount; 
% hdrNS3_nsp2.hdr.label = channelNames_nsp2; 
% hdrNS3_nsp2.hdr.nSamples = headerNS3_nsp2.MetaTags.DataPoints; 
% hdrNS3_nsp2.hdr.chantype = channelType_nsp2_all; 
% hdrNS3_nsp2.hdr.chanunit = cellstr(units_nsp2); 

end