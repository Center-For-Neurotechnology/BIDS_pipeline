function perSessionChannelsTSV(filename_nsp1_ns3,filename_nsp2_ns3)
%% output variables needed:
% *** REQUIRED
% channel name X
% channel type X
% units X
% low cutoff ---------
% hight cutoff --------
% *** RECOMMENDED
% reference -----------
% group X
% *** OPTIONAL
% sampling frequency X
% description notich ---------
% status description ---------


%% temp variables
filename_nsp1_ns3 = 'Z:\Original Data\MG\MG151revised\MG151revised_Tasks\STIMULATION\NetworkWake1\NSP1\10-193513-001.ns3';
filename_nsp2_ns3 = 'Z:\Original Data\MG\MG151revised\MG151revised_Tasks\STIMULATION\NetworkWake1\NSP2\10-193514-001.ns3';


%% open nsx header
header_nsp1_ns3 = openNSx(filename_nsp1_ns3,'noread');
header_nsp2_ns3 = openNSx(filename_nsp2_ns3,'noread');

%% getting sampling frequency
nsp1_samplingFrequency = header_nsp1_ns3.MetaTags.SamplingFreq;
nsp2_samplingFrequency = header_nsp2_ns3.MetaTags.SamplingFreq;


%% get channel names
nsp1_channelNames = extractfield(header_nsp1_ns3.ElectrodesInfo,'Label')';
nsp1_channelNames = regexprep(string(nsp1_channelNames), '\W', '');
nsp2_channelNames = extractfield(header_nsp2_ns3.ElectrodesInfo,'Label')';
nsp2_channelNames = regexprep(string(nsp2_channelNames), '\W', '');


%% get channel types
channelType_nsp1_SEEG = regexp(nsp1_channelNames, '^(L|R)[a-zA-Z]{2,3}\d{1,2}$');
channelType_nsp1_EEG = regexp(nsp1_channelNames, '^[FTOCPS].{0,}[\dZzIiAaRrEeTt]$');
channelType_nsp1_EOC = regexp(nsp1_channelNames, '^(L|R)OC$');
channelType_nsp1_EMG = regexp(nsp1_channelNames, '^EMG');
channelType_nsp1_ECG = regexp(nsp1_channelNames, '(^EKG|Pulse)');
channelType_nsp1_MISC = regexp(nsp1_channelNames, '(^RESP|chan|empty|broke|BLANK|BLA1|1\d{2,}%)');
channelType_nsp1_TRIG = regexp(nsp1_channelNames, 'trigger','ignorecase');

channelType_nsp1_all = cell(size(nsp1_channelNames));
for i = 1:size(nsp1_channelNames)
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
    

channelType_nsp2_SEEG = regexp(nsp2_channelNames, '^(L|R)[a-zA-Z]{2,3}\d{1,2}$');
channelType_nsp2_EEG = regexp(nsp2_channelNames, '^[FTOCPS].{0,}[\dZzIiAaRrEeTt]$');
channelType_nsp2_EOC = regexp(nsp2_channelNames, '^(L|R)OC$');
channelType_nsp2_EMG = regexp(nsp2_channelNames, '^EMG');
channelType_nsp2_ECG = regexp(nsp2_channelNames, '(^EKG|Pulse)');
channelType_nsp2_MISC = regexp(nsp2_channelNames, '(^RESP|chan|empty|broke|BLANK|BLA1|1\d{2,}%)');
channelType_nsp2_TRIG = regexp(nsp2_channelNames, 'trigger','ignorecase');

channelType_nsp2_all = cell(size(nsp2_channelNames));
for i = 1:size(nsp2_channelNames)
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

%% get channel groups
channelGroup_nsp1_all = cell(size(nsp1_channelNames));
for i = 1:size(nsp1_channelNames,1)
    if ~isempty(channelType_nsp1_SEEG{i})
      channelGroup_nsp1_all{i} = regexp(nsp1_channelNames{i}, '^(L|R)[a-zA-Z]{2,3}','match');
    else
      channelGroup_nsp1_all{i} = nsp1_channelNames{i};
    end
end

channelGroup_nsp2_all = cell(size(nsp2_channelNames));
for i = 1:size(nsp2_channelNames,1)
    if ~isempty(channelType_nsp2_SEEG{i})
      channelGroup_nsp2_all{i} = regexp(nsp2_channelNames{i}, '^(L|R)[a-zA-Z]{2,3}','match');
    else
      channelGroup_nsp2_all{i} = nsp2_channelNames{i};
    end
end

%% get current unit label
nsp1_units = extractfield(header_nsp1_ns3.ElectrodesInfo,'AnalogUnits')';
nsp1_units_temp = regexprep(string(nsp1_units), '\W', '');
nsp2_units = extractfield(header_nsp2_ns3.ElectrodesInfo,'AnalogUnits')';
nsp2_units_temp = regexprep(string(nsp2_units), '\W', '');


%% 
 varargout = openNEV(varargin) % try opening nev file to get required vals missing from this tsv file (low/high cutoff frequencies)
 % and optional vals that angelique includes (reference, refernce, notch,
 % status, status description)





 
 %% save tsv files


end