function [hdrNS3_nsp1, hdrNS3_nsp2] = perSessionChannelsTSV(directoryBIDS,sub_XXXX,taskName,ieeg_run,filenameNS3_nsp1,filenameNS3_nsp2,badChannels_nsp1,badChannels_nsp2)
%% output variables needed:
% *** REQUIRED
% channel name X
% channel type X
% units X
% low cutoff X
% hight cutoff X
% *** RECOMMENDED
% reference X
% group X
% *** OPTIONAL
% sampling frequency X
% description X
% notch --------- (n/a?)
% status ------------- X
% status description --------- (n/a?)

%% filenames of the output tables
filename_channelsTSV_nsp1 = [directoryBIDS,'/',sub_XXXX,'/ses-postimp/ieeg/',sub_XXXX,'_ses-postimp_task-',...
    taskName,'RAWNSP1_run-',ieeg_run,'_channels.tsv'];
filename_channelsTSV_nsp2 = [directoryBIDS,'/',sub_XXXX,'/ses-postimp/ieeg/',sub_XXXX,'_ses-postimp_task-',...
    taskName,'RAWNSP2_run-',ieeg_run,'_channels.tsv'];

%% open nsx header
headerNS3_nsp1 = openNSx(filenameNS3_nsp1,'noread');
headerNS3_nsp2 = openNSx(filenameNS3_nsp2,'noread');

%% REQUIRED
%% get channel names
channelNames_nsp1 = extractfield(headerNS3_nsp1.ElectrodesInfo,'Label')';
channelNames_nsp1 = regexprep(string(channelNames_nsp1), '\W', '');
channelNames_nsp2 = extractfield(headerNS3_nsp2.ElectrodesInfo,'Label')';
channelNames_nsp2 = regexprep(string(channelNames_nsp2), '\W', '');

%% get channel types
channelType_nsp1_SEEG = regexp(channelNames_nsp1, '^(L|R)[a-zA-Z]{2,3}\d{1,2}$');
channelType_nsp1_EEG = regexp(channelNames_nsp1, '^[FTOCPS].{0,}[\dZzIiAaRrEeTt]$');
channelType_nsp1_EOC = regexp(channelNames_nsp1, '^(L|R)OC$');
channelType_nsp1_EMG = regexp(channelNames_nsp1, '^EMG');
channelType_nsp1_ECG = regexp(channelNames_nsp1, '(^EKG|Pulse)');
channelType_nsp1_MISC = regexp(channelNames_nsp1, '(^RESP|chan|empty|broke|BLANK|BLA1|1\d{2,}%)');
channelType_nsp1_TRIG = regexp(channelNames_nsp1, 'trigger','ignorecase');

channelType_nsp1_all = cell(size(channelNames_nsp1));
for i = 1:size(channelNames_nsp1)
    if ~isempty(channelType_nsp1_TRIG{i})
        channelType_nsp1_all{i} = 'TRIG';
    elseif ~isempty(channelType_nsp1_EEG{i})
        channelType_nsp1_all{i} = 'EEG';
    elseif ~isempty(channelType_nsp1_EOC{i})
        channelType_nsp1_all{i} = 'EOC';
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
    
channelType_nsp2_SEEG = regexp(channelNames_nsp2, '^(L|R)[a-zA-Z]{2,3}\d{1,2}$');
channelType_nsp2_EEG = regexp(channelNames_nsp2, '^[FTOCPS].{0,}[\dZzIiAaRrEeTt]$');
channelType_nsp2_EOC = regexp(channelNames_nsp2, '^(L|R)OC$');
channelType_nsp2_EMG = regexp(channelNames_nsp2, '^EMG');
channelType_nsp2_ECG = regexp(channelNames_nsp2, '(^EKG|Pulse)');
channelType_nsp2_MISC = regexp(channelNames_nsp2, '(^RESP|chan|empty|broke|BLANK|BLA1|1\d{2,}%)');
channelType_nsp2_TRIG = regexp(channelNames_nsp2, 'trigger','ignorecase');

channelType_nsp2_all = cell(size(channelNames_nsp2));
for i = 1:size(channelNames_nsp2)
    if ~isempty(channelType_nsp2_TRIG{i})
        channelType_nsp2_all{i} = 'TRIG';
    elseif ~isempty(channelType_nsp2_EEG{i})
        channelType_nsp2_all{i} = 'EEG';
    elseif ~isempty(channelType_nsp2_EOC{i})
        channelType_nsp2_all{i} = 'EOC';
    elseif ~isempty(channelType_nsp2_EMG{i})
        channelType_nsp2_all{i} = 'EMG';
    elseif ~isempty(channelType_nsp2_ECG{i})
        channelType_nsp2_all{i} = 'ECG';
    elseif ~isempty(channelType_nsp2_MISC{i})
        channelType_nsp2_all{i} = 'MISC';
    elseif ~isempty(channelType_nsp2_SEEG{i})
        channelType_nsp2_all{i} = 'SEEG';
    else 
        channelType_nsp2_all{i} = 'TRIG';
    end
end

%% get current unit label
units_nsp1 = extractfield(headerNS3_nsp1.ElectrodesInfo,'AnalogUnits')';
units_nsp1 = regexprep(string(units_nsp1), '\W', '');
units_nsp2 = extractfield(headerNS3_nsp2.ElectrodesInfo,'AnalogUnits')';
units_nsp2 = regexprep(string(units_nsp2), '\W', '');

%% get frequency cutoffs
lowCutoff_nsp1 = extractfield(headerNS3_nsp1.ElectrodesInfo,'LowFreqCorner')'/1000; % saved in mHz so /1000
highCutoff_nsp1 = extractfield(headerNS3_nsp1.ElectrodesInfo,'HighFreqCorner')'/1000;
lowCutoff_nsp2 = extractfield(headerNS3_nsp2.ElectrodesInfo,'LowFreqCorner')'/1000;
highCutoff_nsp2 = extractfield(headerNS3_nsp2.ElectrodesInfo,'HighFreqCorner')'/1000;


%% RECOMMENDED
%% reference (check if this value is fixed?)
reference_nsp1 = cell(size(channelNames_nsp1));
reference_nsp1(:) = {'mastoid'};
reference_nsp2 = cell(size(channelNames_nsp2));
reference_nsp2(:) = {'mastoid'};

%% get channel groups
channelGroup_nsp1_all = cell(size(channelNames_nsp1));
for i = 1:size(channelNames_nsp1,1)
    if ~isempty(channelType_nsp1_SEEG{i})
      channelGroup_nsp1_all{i} = regexp(channelNames_nsp1{i}, '^(L|R)[a-zA-Z]{2,3}','match');
    else
      channelGroup_nsp1_all{i} = channelNames_nsp1{i};
    end
end

channelGroup_nsp2_all = cell(size(channelNames_nsp2));
for i = 1:size(channelNames_nsp2,1)
    if ~isempty(channelType_nsp2_SEEG{i})
      channelGroup_nsp2_all{i} = regexp(channelNames_nsp2{i}, '^(L|R)[a-zA-Z]{2,3}','match');
    else
      channelGroup_nsp2_all{i} = channelNames_nsp2{i};
    end
end


%% OPTIONAL
%% getting sampling frequency
samplingFrequency_nsp1 = cell(size(channelNames_nsp1));
samplingFrequency_nsp1(:) = {headerNS3_nsp1.MetaTags.SamplingFreq};
samplingFrequency_nsp2 = cell(size(channelNames_nsp2));
samplingFrequency_nsp2(:) = {headerNS3_nsp2.MetaTags.SamplingFreq};

%% description (nsx is refernetial)
description_nsp1 = cell(size(channelNames_nsp1));
description_nsp1(:) = {'referential/unipolar'};
description_nsp2 = cell(size(channelNames_nsp2));
description_nsp2(:) = {'referential/unipolar'};

%% notch (check if this value is fixed?)
notch_nsp1 = cell(size(channelNames_nsp1));
notch_nsp1(:) = {'n/a'};
notch_nsp2 = cell(size(channelNames_nsp2));
notch_nsp2(:) = {'n/a'};

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

status_nsp2 = cell(size(channelNames_nsp2));
if ~isempty(badChannels_nsp2)
    badChannels_nsp2 = load(badChannels_nsp2);
    badChannels_nsp2 = badChannels_nsp2.badChannels;
    
    for i = 1:size(channelNames_nsp2,1)
        if strcmp(channelType_nsp2_all{i},'SEEG') || strcmp(channelType_nsp2_all{i},'ECOG')
            if ismember(i,badChannels_nsp2) % channel number with respect to nsp2 (1:128)
                status_nsp2{i} = 'bad';
            else
                status_nsp2{i} = 'good';
            end
        else
            status_nsp2{i} = 'n/a';
        end
    end
else
    status_nsp2(:) = {'n/a'};
end

 %% status description (check if this value is fixed?)
statusDescription_nsp1 = cell(size(channelNames_nsp1));
statusDescription_nsp1(:) = {'n/a'};
statusDescription_nsp2 = cell(size(channelNames_nsp2));
statusDescription_nsp2(:) = {'n/a'};


 %% save tsv files
varNames = {'name','type','units','low_cutoff','high_cutoff','reference','group','sampling_frequency',...
    'description','notch','status','status_description'};

table_channelsTSV_nsp1 = table(channelNames_nsp1, channelType_nsp1_all, units_nsp1, lowCutoff_nsp1, highCutoff_nsp1, ...
    reference_nsp1, channelGroup_nsp1_all, samplingFrequency_nsp1, description_nsp1, notch_nsp1, ...
    status_nsp1, statusDescription_nsp1, 'VariableNames', varNames);

table_channelsTSV_nsp2 = table(channelNames_nsp2, channelType_nsp2_all, units_nsp2, lowCutoff_nsp2, highCutoff_nsp2, ...
    reference_nsp2, channelGroup_nsp2_all, samplingFrequency_nsp2, description_nsp2, notch_nsp2, ...
    status_nsp2, statusDescription_nsp2, 'VariableNames', varNames);

writetable(table_channelsTSV_nsp1, filename_channelsTSV_nsp1, 'FileType', 'text', 'Delimiter', '\t');
writetable(table_channelsTSV_nsp2, filename_channelsTSV_nsp2, 'FileType', 'text', 'Delimiter', '\t');


%% saving hdr info for ieeg script
% nsp1    
hdrNS3_nsp1.hdr.Fs = samplingFrequency_nsp1;    % sampling frequency
hdrNS3_nsp1.hdr.nChans = headerNS3_nsp1.MetaTags.ChannelCount; % J: number of channels
hdrNS3_nsp1.hdr.label = channelNames_nsp1; % J: use regular channel name (RAMY1) and ask about that later
hdrNS3_nsp1.hdr.nSamples = headerNS3_nsp1.MetaTags.DataPoints;    % number of samples
hdrNS3_nsp1.hdr.chantype = channelType_nsp1_all; % same channl types as found before
hdrNS3_nsp1.hdr.chanunit = cellstr(units_nsp1); % J: units
% nsp2
hdrNS3_nsp2.hdr.Fs = samplingFrequency_nsp2;    % sampling frequency
hdrNS3_nsp2.hdr.nChans = headerNS3_nsp2.MetaTags.ChannelCount; % J: number of channels
hdrNS3_nsp2.hdr.label = channelNames_nsp2; % J: use regular channel name (RAMY1) and ask about that later
hdrNS3_nsp2.hdr.nSamples = headerNS3_nsp2.MetaTags.DataPoints;    % number of samples
hdrNS3_nsp2.hdr.chantype = channelType_nsp2_all; % same channl types as found before
hdrNS3_nsp2.hdr.chanunit = cellstr(units_nsp2); % J: units

end