function [hdr] = perSessionChannelsTSVn(directoryBIDS,sub_XXXX,taskName,ieeg_run,foldername_neuralynx,badChannels,posFixNCS)
% This function is run once for each session. It creates a tsv file
% containing channel details.
% The tsv file will be saved in directoryBIDS\sub_XXXX\ses-postimp\ieeg\
% and have the name sub-XXXX_ses-postimp_task-TaskRAWNSP1_run-01_channels.tsv
% INPUTS:
%   - directoryBIDS: string of the main folder where the BIDS data is being saved
%   - sub_XXXX: string of the deidentified patient ID
%   - taskName: string of the session task name
%   - ieeg_run: string of the session order
%   - foldername_neuralynx: string of any .nsc filename in the wanted session folder(full path)
%   - badChannels: string of the filename (full path) containing the
%       bad channel numbers, can be empty
%   - posFixNCS: string after channel name in nsc file name (e.g. for file 'LTMb-Pul9_0017.ncs', posFixNCS = '_0017')
%
% OUTPUTS: 
%   - sub-XXXX_ses-postimp_task-TaskRAWNSP1_run-01_channels.tsv
%   - hdr: structure containing .nsc headers needed for
%       functions perSessionIEEGn() and perSessionEventsTSVn()


%%
filename_channelsTSVn = [directoryBIDS,'/',sub_XXXX,'/ses-postimp/ieeg/',sub_XXXX,'_ses-postimp_task-',...
    taskName,'RAW_run-',ieeg_run,'_channels.tsv'];

%% open neuralynx files
% use rina's neuralynx repo
% need channel list to call readCSCfiles()

% load file names in datapath
[filepath,name,ext] = fileparts(foldername_neuralynx);
list = ls(filepath); % gets all file names in the folder

%% get channel names
channel_list = {};
for i = 1:size(list,1)
    filename = list(i,:);
    [filepath,name,ext] = fileparts(filename);
    if length(name) >= 2
        % select files ending in .ncs and not starting with 'CSC' (get sync later in perSessionEventsTSV)
        if strcmp(strtrim(ext),'.ncs') && ~strcmp(name(1:2),'CS')
            split_name_fromPOS = strsplit(name,'_');
            name = split_name_fromPOS{1};
            channel_list = [channel_list; name];
        end
    end
end
[filepath,~,~] = fileparts(foldername_neuralynx);

%% get channel types
% categorizing each channel name into a group (SEEG,EEG,EOC,EMG,ECG,MISC,TRIG)
channelType_SEEG = regexp(channel_list,'^(L|R)[a-zA-Z]{2,3}[-]?[a-zA-Z]{0,3}\d{1,2}$'); % first update: '^(L|R)[a-zA-Z]{2,3}[-]?[a-zA-Z]?','match'); % Original: '^(L|R)[a-zA-Z]{2,3}\d{1,2}$');
channelType_EEG = regexp(channel_list, '^[FTOCPS].{0,}[\dZzIiAaRrEeTt]$');
channelType_EOC = regexp(channel_list, '^(L|R)OC$');
channelType_EMG = regexp(channel_list, '^EMG');
channelType_ECG = regexp(channel_list, '(^EKG|Pulse)');
channelType_MISC = regexp(channel_list, '(^RESP|chan|empty|broke|BLANK|BLA1|1\d{2,}%)');
channelType_TRIG = regexp(channel_list, 'trigger','ignorecase');


% creating cell with channel types to use in tsv 
channelType_all = cell(size(channel_list));
for i = 1:size(channel_list,1)
    if ~isempty(channelType_TRIG{i})
        channelType_all{i} = 'TRIG';
    elseif ~isempty(channelType_EEG{i})
        channelType_all{i} = 'EEG';
    elseif ~isempty(channelType_EOC{i})
        channelType_all{i} = 'EOC';
    elseif ~isempty(channelType_EMG{i})
        channelType_all{i} = 'EMG';
    elseif ~isempty(channelType_ECG{i})
        channelType_all{i} = 'ECG';
    elseif ~isempty(channelType_MISC{i})
        channelType_all{i} = 'MISC';
    elseif ~isempty(channelType_SEEG{i})
        channelType_all{i} = 'SEEG';
    else 
        channelType_all{i} = 'TRIG';
    end
end


%% need recording file header info past here!
%% values needed from data:
FieldSelectionFlags = [1 1 1 1 1]; % setting Nlx2MatCSC args
HeaderExtractionFlag = 1;
ExtractMode = 1;
ExtractionModeVector = [];

lowPass_all = zeros(size(channel_list)); % for lowpass and high pass filters and sampling rate
highPass_all = zeros(size(channel_list));
fs_all = zeros(size(channel_list));

for i = 1:length(channel_list)
    ncsFileName = [filepath,'\',channel_list{i},posFixNCS,'.ncs'];
    % get header info per channel
    [Timestamps, ChannelNumbers, SampleFrequencies, NumberOfValidSamples, Samples, Header] = Nlx2MatCSC(ncsFileName, FieldSelectionFlags, HeaderExtractionFlag, ExtractMode, ExtractionModeVector);
    
    % parse header info
    lowPass = split(Header{25},' ');
    lowPass = str2num(lowPass{2});
    lowPass_all(i,1) = lowPass;
    
    highPass = split(Header{29},' ');
    highPass = str2num(highPass{2});
    highPass_all(i,1) = highPass;
    
    fs = split(Header{15},' ');
    fs = str2num(fs{2});
    fs_all(i,1) = fs; 
end

voltageunit_all = cell(size(channel_list));
voltageunit_all(:) = {'mv'};

%% values generated:
reference_all = cell(size(channel_list));
reference_all(:) = {'mastoid'}; 
recordingDescr_all = cell(size(channel_list));
recordingDescr_all(:) = {'referential/unipolar'};
notch_all = cell(size(channel_list));
notch_all(:) = {'n/a'}; 
statusDescription_all = cell(size(channel_list));
statusDescription_all(:) = {'n/a'}; 

% get channel groups (electrode, scalp, trigger, etc)
channelGroup_all = cell(size(channel_list));
for i = 1:size(channel_list,1)
    if ~isempty(channelType_SEEG{i})
      channelGroup_all{i} = regexp(channel_list{i},'^(L|R)[a-zA-Z]{2,3}[-]?[a-zA-Z]{0,3}','match'); % first update: '^(L|R)[a-zA-Z]{2,3}[-]?[a-zA-Z]?','match'); % original: '^(L|R)[a-zA-Z]{2,3}','match'); '^(L|R)[a-zA-Z]{2,3}','match');
    else
      channelGroup_all{i} = channel_list{i};
    end
end

% channel status (only for SEEG or ECOG)
channelStatus_all = cell(size(channel_list));
if ~isempty(badChannels)
    badChannels = load(badChannels);
    badChannels = badChannels.badChannels;
    for i = 1:size(channel_list,1)
        if strcmp(channelType_all{i},'SEEG') || strcmp(channelType_all{i},'ECOG')
            if ismember(i,badChannels) % channel with respect to nps1 (1:128)
                channelStatus_all{i} = 'bad';
            else
                channelStatus_all{i} = 'good';
            end
        else
            channelStatus_all{i} = 'n/a';
        end
    end
else
    channelStatus_all(:) = {'n/a'};
end

%% save
varNames = {'name','type','units','low_cutoff','high_cutoff','reference','group','sampling_frequency',...
    'description','notch','status','status_description'};

table_channelsTSV = table(channel_list, channelType_all, voltageunit_all, lowPass_all, highPass_all, ...
    reference_all, channelGroup_all, fs_all, recordingDescr_all, notch_all, ...
    channelStatus_all, statusDescription_all, 'VariableNames', varNames);

writetable(table_channelsTSV, filename_channelsTSVn, 'FileType', 'text', 'Delimiter', '\t');

hdr.Fs = fs_all(1);    % sampling frequency
hdr.nChans = size(channel_list,1); %  number of channels
hdr.label = channel_list;     % channel name (eg. RAMY1)
hdr.nSamples = numel(Samples);    % number of samples, TO DO double check!
hdr.chantype = channelType_all; % channel types
hdr.chanunit = cellstr(voltageunit_all); % recording voltage units


end