%% function for splicing CSC files. 

%{
Input = csc files in the same directory with posfix A and B
posfixA = _xxxx;
posfixB = _yyyy;
Output = csc files in the same directory, with posfix _xxxxyyyymerged.
%}

%% 
clear;clc

dirData = 'K:\StimDataBackup\Data_Stimulation\MG258\eTBS\rawData\'; % path to folder containing neuralynx data

posFixNCS{1} = '_0003'; % string after channel name in nsc file name (e.g. for file 'LTMb-Pul9_0017.ncs', posFixNCS = '_0017')
posFixNCS{2} = '_0004'; % string after channel name in nsc file name (e.g. for file 'LTMb-Pul9_0017.ncs', posFixNCS = '_0017')
% posFixNCS{3} = '_0006';
% posFixNCS{4} = '_0007';

posFix_combined = '_0003_4_combined';




%% Identify all channel names
suffix = [posFixNCS{1},'.ncs'];
suffixPattern = ['*',posFixNCS{1},'.ncs'];
allFiles = dir(fullfile(dirData, suffixPattern));

allChNames = cell(size(allFiles));
for iFile = 1:length(allFiles)
    fname = allFiles(iFile).name;
    if endsWith(fname, suffix)
        allChNames{iFile} = extractBefore(fname, strlength(fname) - strlength(suffix) + 1);
    end
end


suffix_2 = [posFixNCS{2},'.ncs'];
suffixPattern_2 = ['*',posFixNCS{2},'.ncs'];
allFiles_2 = dir(fullfile(dirData, suffixPattern_2));

allChNames_2 = cell(size(allFiles_2));
for iFile = 1:length(allFiles_2)
    fname = allFiles_2(iFile).name;
    if endsWith(fname, suffix_2)
        allChNames_2{iFile} = extractBefore(fname, strlength(fname) - strlength(suffix_2) + 1);
    end
end

allChNames = intersect(allChNames, allChNames_2);
%%
dirCombined = [dirData, '\combined\'];
if ~isdir(dirCombined)
    mkdir(dirCombined)
end

%% get continuous recordings

nChannels = length(allChNames);
iChToExclude=[];


filepath = dirData;
for iCh=1:nChannels
    
    ncsFileName_combined = [dirCombined,allChNames{iCh},posFix_combined,'.ncs'];
    
    ncsFileName = cell(1,0);
    Timestamps = cell(1,0);
    ChannelNumbers = cell(1,0);
    SampleFrequencies = cell(1,0);
    NumberOfValidSamples = cell(1,0);
    Samples = cell(1,0);
    Header = cell(1,0);
    isValid = zeros(1,length(posFixNCS));
    
    
    for iFile = 1:length(posFixNCS)
        ncsFileName{iFile} = [filepath,'\',allChNames{iCh},posFixNCS{iFile},'.ncs'];
        % Assuming the same channels are present for both posfix1 and 2. 
        
        % Load Data from ncs files
        [Timestamps{iFile}, ChannelNumbers{iFile}, SampleFrequencies{iFile}, NumberOfValidSamples{iFile}, Samples{iFile}, Header{iFile}] = Nlx2MatCSC(ncsFileName{iFile},[1 1 1 1 1], 1, 1, [] );
        isValid(iFile) = (length(unique(ChannelNumbers{iFile}))==1 && length(unique(SampleFrequencies{iFile})) && (length(Timestamps{iFile})>1));
    end

    if sum(isValid) == length(posFixNCS)
        Timestamps_all = [];
        ChannelNumbers_all = [];
        SampleFrequencies_all = [];
        NumberOfValidSamples_all = [];
        Samples_all = [];
        Header_all = [];

        for iFile = 1:length(posFixNCS)
            Timestamps_all = [Timestamps_all, Timestamps{iFile}];
            ChannelNumbers_all = [ChannelNumbers_all, ChannelNumbers{iFile}];
            SampleFrequencies_all = [SampleFrequencies_all, SampleFrequencies{iFile}];
            NumberOfValidSamples_all = [NumberOfValidSamples_all, NumberOfValidSamples{iFile}];
            Samples_all = [Samples_all, Samples{iFile}]; 
        end
        Header_all = Header{1}; % Just using header of the first file. 

        Mat2NlxCSC(ncsFileName_combined, 0, 1, 1, [1 1 1 1 1 1], Timestamps_all, ChannelNumbers_all, SampleFrequencies_all, NumberOfValidSamples_all, Samples_all, Header_all);
    else
        iChToExclude = [iChToExclude, iCh];
        disp(['Excluding Channel: ',allChNames{iCh} ,' - Corrupted File: ', ncsFileName{1}]);
    end
end

