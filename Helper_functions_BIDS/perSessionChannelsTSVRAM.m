 function [hdrNS3_nsp1, hdrNS3_nsp2] = perSessionChannelsTSVRAM(directoryBIDS,sub_XXXX,taskName,ieeg_run,filenameNS3_nsp1,badChannels_nsp1)
% This function is run once for each session. It creates a tsv file
% containing channel details.
% The tsv file will be saved in directoryBIDS\sub_XXXX\ses-postimp\ieeg\
% and have the name sub-XXXX_ses-postimp_task-TaskRAWNSP1_run-01_channels.tsv
% INPUTS:
%   - directoryBIDS: string of the main folder where the BIDS data is being saved
%   - sub_XXXX: string of the deidentified patient ID
%   - taskName: string of the session task name
%   - ieeg_run: string of the session order
%   - filenameNS3_nsp1: string of the NSP1 .ns3 filename (full path)
%   - filenameNS3_nsp2: string of the NSP2 .ns3 filename (full path)
%   - badChannels_nsp1: string of the filename (full path) containing the
%       bad channel numbers in NSP1, can be empty
%   - badChannels_nsp2: string of the filename (full path) containing the
%       bad channel numbers in NSP2, can be empty
% OUTPUTS: 
%   - sub-XXXX_ses-postimp_task-TaskRAWNSP1_run-01_channels.tsv
%   - hdrNS3_nsp1: structure containing NSP1 .ns3 headers needed for
%       functions perSessionIEEG() and perSessionEventsTSV()
%   - hdrNS3_nsp2: structure containing NSP2 .ns3 headers needed for
%       functions perSessionIEEG() and perSessionEventsTSV()

%% file names of the saved .tsv files

filename_channelsTSV_nsp1 = [directoryBIDS,'/',sub_XXXX,'/ses-postimp/ieeg/',sub_XXXX,'_ses-postimp_task-',...
    taskName,'RAWNSP1_run-',ieeg_run,'_channels.tsv'];
%if ~exist(filename_channelsTSV_nsp1,'dir'), mkdir(filename_channelsTSV_nsp1); end
% if ~isempty(filenameNS3_nsp2)
%     filename_channelsTSV_nsp2 = [directoryBIDS,'/',sub_XXXX,'/ses-postimp/ieeg/',sub_XXXX,'_ses-postimp_task-',...
%         taskName,'RAWNSP2_run-',ieeg_run,'_channels.tsv'];
%     %if ~exist(filename_channelsTSV_nsp2,'dir'), mkdir(filename_channelsTSV_nsp2); end
% end

%% open ns3 headers
headerNS3_nsp1 = openNSx(filenameNS3_nsp1,'noread');
% headerNS3_nsp2 = openNSx(filenameNS3_nsp2,'noread');

%% REQUIRED
%% get channel names
channelNames_nsp1 = extractfield(headerNS3_nsp1.ElectrodesInfo,'Label')';
channelNames_nsp1 = regexprep(string(channelNames_nsp1), '\W', ''); % getting rid of whitespace
% if ~isempty(filenameNS3_nsp2)
%     channelNames_nsp2 = extractfield(headerNS3_nsp2.ElectrodesInfo,'Label')';
%     channelNames_nsp2 = regexprep(string(channelNames_nsp2), '\W', '');
% end

%% get channel types
% NSP1
% categorizing each channel name into a group (SEEG,EEG,EOC,EMG,ECG,MISC,TRIG)
channelType_nsp1_SEEG = regexp(channelNames_nsp1,'^(L|R)[a-zA-Z]{2,3}[-]?[a-zA-Z]?\d{1,2}$'); % Original: '^(L|R)[a-zA-Z]{2,3}\d{1,2}$');       % J: new ch names update?
channelType_nsp1_EEG = regexp(channelNames_nsp1, '^[FTOCPS].{0,}[\dZzIiAaRrEeTt]$');
channelType_nsp1_EOC = regexp(channelNames_nsp1, '^(L|R)OC$');
channelType_nsp1_EMG = regexp(channelNames_nsp1, '^EMG');
channelType_nsp1_ECG = regexp(channelNames_nsp1, '(^EKG|Pulse)');
channelType_nsp1_MISC = regexp(channelNames_nsp1, '(^RESP|chan|empty|broke|BLANK|BLA1|1\d{2,}%)');
channelType_nsp1_TRIG = regexp(channelNames_nsp1, 'trigger','ignorecase');
scalpIndex_nsp1 = [];
scalpCounter_nsp1 = 1;

% creating cell with channel types to use in tsv 
channelType_nsp1_all = cell(size(channelNames_nsp1));
for i = 1:size(channelNames_nsp1)
    if ~isempty(channelType_nsp1_TRIG{i})
        channelType_nsp1_all{i} = 'TRIG';
    elseif ~isempty(channelType_nsp1_EEG{i})
        channelType_nsp1_all{i} = 'EEG';
        scalpIndex_nsp1(scalpCounter_nsp1) = i;
        scalpCounter_nsp1 = scalpCounter_nsp1 + 1;  % getting scalp channels
    elseif ~isempty(channelType_nsp1_EOC{i})
        channelType_nsp1_all{i} = 'EOC';
        scalpIndex_nsp1(scalpCounter_nsp1) = i;
        scalpCounter_nsp1 = scalpCounter_nsp1 + 1;
    elseif ~isempty(channelType_nsp1_EMG{i})
        channelType_nsp1_all{i} = 'EMG';
    elseif ~isempty(channelType_nsp1_ECG{i})
        channelType_nsp1_all{i} = 'ECG';
    elseif ~isempty(channelType_nsp1_MISC{i})
        channelType_nsp1_all{i} = 'MISC';
    elseif ~isempty(channelType_nsp1_SEEG{i})
        channelType_nsp1_all{i} = 'SEEG';
    else 
        channelType_nsp1_all{i} = 'TRIG';
    end
end
scalpIndxLogical_nsp1=ismember(1:numel(channelNames_nsp1),scalpIndex_nsp1); 



%% get voltage unit in each channel 
units_nsp1 = extractfield(headerNS3_nsp1.ElectrodesInfo,'AnalogUnits')';
units_nsp1 = regexprep(string(units_nsp1), '\W', '');
% if ~isempty(filenameNS3_nsp2)
%     units_nsp2 = extractfield(headerNS3_nsp2.ElectrodesInfo,'AnalogUnits')';
%     units_nsp2 = regexprep(string(units_nsp2), '\W', '');
% end

%% get frequency cutoffs
lowCutoff_nsp1 = extractfield(headerNS3_nsp1.ElectrodesInfo,'LowFreqCorner')'/1000; % saved in mHz so /1000
highCutoff_nsp1 = extractfield(headerNS3_nsp1.ElectrodesInfo,'HighFreqCorner')'/1000;
% if ~isempty(filenameNS3_nsp2)
%     lowCutoff_nsp2 = extractfield(headerNS3_nsp2.ElectrodesInfo,'LowFreqCorner')'/1000;
%     highCutoff_nsp2 = extractfield(headerNS3_nsp2.ElectrodesInfo,'HighFreqCorner')'/1000;
% end

%% RECOMMENDED
%% reference
reference_nsp1 = cell(size(channelNames_nsp1));
reference_nsp1(:) = {'mastoid'};
% if ~isempty(filenameNS3_nsp2)
%     reference_nsp2 = cell(size(channelNames_nsp2));
%     reference_nsp2(:) = {'mastoid'};
% end

%% get channel groups (electrode, scalp, trigger, etc)
channelGroup_nsp1_all = cell(size(channelNames_nsp1));
for i = 1:size(channelNames_nsp1,1)
    if ~isempty(channelType_nsp1_SEEG{i})
      channelGroup_nsp1_all{i} = regexp(channelNames_nsp1{i}, '^(L|R)[a-zA-Z]{2,3}','match');
    else
      channelGroup_nsp1_all{i} = channelNames_nsp1{i};
    end
end

% if ~isempty(filenameNS3_nsp2)
%     channelGroup_nsp2_all = cell(size(channelNames_nsp2));
%     for i = 1:size(channelNames_nsp2,1)
%         if ~isempty(channelType_nsp2_SEEG{i})
%           channelGroup_nsp2_all{i} = regexp(channelNames_nsp2{i}, '^(L|R)[a-zA-Z]{2,3}','match');
%         else
%           channelGroup_nsp2_all{i} = channelNames_nsp2{i};
%         end
%     end
% end

%% OPTIONAL
%% getting sampling frequency
samplingFrequency_nsp1 = cell(size(channelNames_nsp1));
samplingFrequency_nsp1(:) = {headerNS3_nsp1.MetaTags.SamplingFreq};
% if ~isempty(filenameNS3_nsp2)
%     samplingFrequency_nsp2 = cell(size(channelNames_nsp2));
%     samplingFrequency_nsp2(:) = {headerNS3_nsp2.MetaTags.SamplingFreq};
% end

%% recording data type
description_nsp1 = cell(size(channelNames_nsp1));
description_nsp1(:) = {'referential/unipolar'};
if ~isempty(filenameNS3_nsp2)
    description_nsp2 = cell(size(channelNames_nsp2));
    description_nsp2(:) = {'referential/unipolar'};
end

%% notch (set to 'n/a')
notch_nsp1 = cell(size(channelNames_nsp1));
notch_nsp1(:) = {'n/a'};
% if ~isempty(filenameNS3_nsp2)
%     notch_nsp2 = cell(size(channelNames_nsp2));
%     notch_nsp2(:) = {'n/a'};
% end

%% channel status (only for SEEG or ECOG)
status_nsp1 = cell(size(channelNames_nsp1));
if ~isempty(badChannels_nsp1)
    badChannels_nsp1 = load(badChannels_nsp1);
    badChannels_nsp1 = badChannels_nsp1.badChannels;
    for i = 1:size(channelNames_nsp1,1)
        if strcmp(channelType_nsp1_all{i},'SEEG') || strcmp(channelType_nsp1_all{i},'ECOG')
            if ismember(i,badChannels_nsp1) % channel with respect to nps1 (1:128)
                status_nsp1{i} = 'bad';
            else
                status_nsp1{i} = 'good';
            end
        else
            status_nsp1{i} = 'n/a';
        end
    end
else
    status_nsp1(:) = {'n/a'};
end

% if ~isempty(filenameNS3_nsp2)
%     status_nsp2 = cell(size(channelNames_nsp2));
%     if ~isempty(badChannels_nsp2)
%         badChannels_nsp2 = load(badChannels_nsp2);
%         badChannels_nsp2 = badChannels_nsp2.badChannels;
%         for i = 1:size(channelNames_nsp2,1)
%             if strcmp(channelType_nsp2_all{i},'SEEG') || strcmp(channelType_nsp2_all{i},'ECOG')
%                 if ismember(i,badChannels_nsp2) % channel number with respect to nsp2 (1:128)
%                     status_nsp2{i} = 'bad';
%                 else
%                     status_nsp2{i} = 'good';
%                 end
%             else
%                 status_nsp2{i} = 'n/a';
%             end
%         end
%     else
%         status_nsp2(:) = {'n/a'};
%     end
% end

%% status description (set to 'n/a')
statusDescription_nsp1 = cell(size(channelNames_nsp1));
statusDescription_nsp1(:) = {'n/a'};
% if ~isempty(filenameNS3_nsp2)
%     statusDescription_nsp2 = cell(size(channelNames_nsp2));
%     statusDescription_nsp2(:) = {'n/a'};
% end

%% Neuron2023: remove data/header info on scalp indices
% channelNames_nsp1(scalpIndex_nsp1) = []; %string array
% channelType_nsp1_all(scalpIndex_nsp1) = []; % cell array
% units_nsp1(scalpIndex_nsp1) = []; % string array
% lowCutoff_nsp1(scalpIndex_nsp1) = []; % unit32 column vector
% highCutoff_nsp1(scalpIndex_nsp1) = []; % unit32 column vector
% reference_nsp1(scalpIndex_nsp1) = []; % cell array
% channelGroup_nsp1_all(scalpIndex_nsp1) = []; % cell array
% samplingFrequency_nsp1(scalpIndex_nsp1) = []; % cell array
% description_nsp1(scalpIndex_nsp1) = []; % cell array
% notch_nsp1(scalpIndex_nsp1) = []; % cell array
% status_nsp1(scalpIndex_nsp1) = []; % cell array
% statusDescription_nsp1(scalpIndex_nsp1) = []; % cell array
% 
% channelNames_nsp2(scalpIndex_nsp2) = [];
% channelType_nsp2_all(scalpIndex_nsp2) = [];
% units_nsp2(scalpIndex_nsp2) = [];
% lowCutoff_nsp2(scalpIndex_nsp2) = [];
% highCutoff_nsp2(scalpIndex_nsp2) = [];
% reference_nsp2(scalpIndex_nsp2) = [];
% channelGroup_nsp2_all(scalpIndex_nsp2) = [];
% samplingFrequency_nsp2(scalpIndex_nsp2) = [];
% description_nsp2(scalpIndex_nsp2) = [];
% notch_nsp2(scalpIndex_nsp2) = [];
% status_nsp2(scalpIndex_nsp2) = [];
% statusDescription_nsp2(scalpIndex_nsp2) = [];
%% create tables and save tsv files
varNames = {'name','type','units','low_cutoff','high_cutoff','reference','group','sampling_frequency',...
    'description','notch','status','status_description'};

table_channelsTSV_nsp1 = table(channelNames_nsp1(~scalpIndxLogical_nsp1), channelType_nsp1_all(~scalpIndxLogical_nsp1), units_nsp1(~scalpIndxLogical_nsp1), lowCutoff_nsp1(~scalpIndxLogical_nsp1), highCutoff_nsp1(~scalpIndxLogical_nsp1), ...
    reference_nsp1(~scalpIndxLogical_nsp1), channelGroup_nsp1_all(~scalpIndxLogical_nsp1), samplingFrequency_nsp1(~scalpIndxLogical_nsp1), description_nsp1(~scalpIndxLogical_nsp1), notch_nsp1(~scalpIndxLogical_nsp1), ...
    status_nsp1(~scalpIndxLogical_nsp1), statusDescription_nsp1(~scalpIndxLogical_nsp1), 'VariableNames', varNames);

% if ~isempty(filenameNS3_nsp2)
%     table_channelsTSV_nsp2 = table(channelNames_nsp2(~scalpIndxLogical_nsp2), channelType_nsp2_all(~scalpIndxLogical_nsp2), units_nsp2(~scalpIndxLogical_nsp2), lowCutoff_nsp2(~scalpIndxLogical_nsp2), highCutoff_nsp2(~scalpIndxLogical_nsp2), ...
%         reference_nsp2(~scalpIndxLogical_nsp2), channelGroup_nsp2_all(~scalpIndxLogical_nsp2), samplingFrequency_nsp2(~scalpIndxLogical_nsp2), description_nsp2(~scalpIndxLogical_nsp2), notch_nsp2(~scalpIndxLogical_nsp2), ...
%         status_nsp2(~scalpIndxLogical_nsp2), statusDescription_nsp2(~scalpIndxLogical_nsp2), 'VariableNames', varNames);
% end

writetable(table_channelsTSV_nsp1, filename_channelsTSV_nsp1, 'FileType', 'text', 'Delimiter', '\t');
% if ~isempty(filenameNS3_nsp2)
%     writetable(table_channelsTSV_nsp2, filename_channelsTSV_nsp2, 'FileType', 'text', 'Delimiter', '\t');
% end

%% saving hdr info needed for other functions
% nsp1    
hdrNS3_nsp1.hdr.Fs = samplingFrequency_nsp1;    % sampling frequency
hdrNS3_nsp1.hdr.nChans = headerNS3_nsp1.MetaTags.ChannelCount-scalpCounter_nsp1; %  number of channels
hdrNS3_nsp1.hdr.label = channelNames_nsp1;     % channel name (eg. RAMY1)
hdrNS3_nsp1.hdr.nSamples = headerNS3_nsp1.MetaTags.DataPoints;    % number of samples
hdrNS3_nsp1.hdr.chantype = channelType_nsp1_all; % channel types
hdrNS3_nsp1.hdr.chanunit = cellstr(units_nsp1); % recording voltage units
% nsp2
% if ~isempty(filenameNS3_nsp2)
%     hdrNS3_nsp2.hdr.Fs = samplingFrequency_nsp2; 
%     hdrNS3_nsp2.hdr.nChans = headerNS3_nsp2.MetaTags.ChannelCount-scalpCounter_nsp2; 
%     hdrNS3_nsp2.hdr.label = channelNames_nsp2; 
%     hdrNS3_nsp2.hdr.nSamples = headerNS3_nsp2.MetaTags.DataPoints; 
%     hdrNS3_nsp2.hdr.chantype = channelType_nsp2_all; 
%     hdrNS3_nsp2.hdr.chanunit = cellstr(units_nsp2); 
% else
%     hdrNS3_nsp2 = {};
%     scalpIndex_nsp2 =[];
% end

end