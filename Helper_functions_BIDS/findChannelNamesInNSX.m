function channInfo = findChannelNamesInNSX(channInfo, allChNames, fileNameNSx)

nChannels=length(channInfo.stimChNumber);
nPreFixName=2;

% --- normalize fileNameNSx: accept string or cell, drop empty NSP entries ---
if ~iscell(fileNameNSx)
    fileNameNSx = {fileNameNSx};          % wrap a single filename into a cell
end
fileNameNSx = fileNameNSx(~cellfun(@isempty, fileNameNSx));  % remove empty NSPs
if isempty(fileNameNSx)
    error('findChannelNamesInNSX: no valid NSX filenames provided.');
end

if isempty(allChNames) % we might want to change to the same input
    for iNSP=1:length(fileNameNSx)
        hdrNSX = openNSx(fileNameNSx{iNSP}, 'noread'); % only read header
        allChNames{iNSP} = {hdrNSX.ElectrodesInfo.Label}';
    end
end

% remove space from channel names
for iNSP=1:length(allChNames)
    for iCh=1:length(allChNames{iNSP})
        allChNames{iNSP}{iCh} = regexprep( allChNames{iNSP}{iCh},'\W','');
    end
end


% Assign NSX channel number based on bank info
if isfield(channInfo,'bankInfo') && (~isfield(channInfo,'stimChNumberInNSX') || isempty(channInfo.stimChNumberInNSX))
    channInfo.stimChNumberInNSX = zeros(size(channInfo.stimChNumber));
    indChInBankA = find(channInfo.stimChNumber(1,:)<=32);
    indChInBankB = intersect(find(channInfo.stimChNumber(1,:)>32), find(channInfo.stimChNumber(1,:)<=64));
    indChInBankC = intersect(find(channInfo.stimChNumber(1,:)>64), find(channInfo.stimChNumber(1,:)<=96));
    for iPair=1:2
    channInfo.stimChNumberInNSX(iPair,:) = [channInfo.bankInfo.bankA(channInfo.stimChNumber(iPair,indChInBankA) + 0),...
                                   channInfo.bankInfo.bankB(channInfo.stimChNumber(iPair,indChInBankB) - 32),...
                                   channInfo.bankInfo.bankC(channInfo.stimChNumber(iPair,indChInBankC) - 64)];
    end
    channInfo.NSPnumber = [ repmat(channInfo.bankInfo.bankANSP,1,length(indChInBankA)),...
                            repmat(channInfo.bankInfo.bankBNSP,1,length(indChInBankB)),...
                            repmat(channInfo.bankInfo.bankCNSP,1,length(indChInBankC))];
end

if ~isfield(channInfo,'stimChNames') || isempty(channInfo.stimChNames)
    channInfo.stimChNames=[];
    for iCh=1:nChannels
        stimChNumbers = channInfo.stimChNumberInNSX(:,iCh);
        indNSP = channInfo.NSPnumber(iCh);
        channInfo.stimChNames = [channInfo.stimChNames, allChNames{indNSP}(stimChNumbers)];
    end
end

if ~isfield(channInfo,'recBipolarChPerStim')|| isempty(channInfo.recBipolarChPerStim)
    for iCh=1:nChannels
        stimChNumbers = channInfo.stimChNumberInNSX(:,iCh);
        indNSP = channInfo.NSPnumber(iCh);
        channInfo.recBipolarChPerStim{iCh} = cell(1,2);
        if stimChNumbers(1)>2
            channInfo.recBipolarChPerStim{iCh}{1} = strcat(allChNames{indNSP}{stimChNumbers(1)-1},'-',allChNames{indNSP}{stimChNumbers(1)-2});
        end
        channInfo.recBipolarChPerStim{iCh}{2} = strcat(allChNames{indNSP}{stimChNumbers(2)+2},'-',allChNames{indNSP}{stimChNumbers(2)+1});
        if ~strncmp(channInfo.recBipolarChPerStim{iCh}{2},channInfo.stimChNames{1,iCh}(1:nPreFixName),nPreFixName)
            channInfo.recBipolarChPerStim{iCh}(2) = [];
        end
        if ~strncmp(channInfo.recBipolarChPerStim{iCh}{1},channInfo.stimChNames{1,iCh}(1:nPreFixName),nPreFixName)
            channInfo.recBipolarChPerStim{iCh}(1) = [];
        end
%         if isempty(channInfo.recBipolarChPerStim{iCh}{1}) % replace 1 with 2 if no first option
%             channInfo.recBipolarChPerStim{iCh}{1}=channInfo.recBipolarChPerStim{iCh}{2};
%             channInfo.recBipolarChPerStim{iCh}(2)=[];
%         end
    end
end

% assign other channInfo based on number of channels
if ~isfield(channInfo,'recChPerStim')
    channInfo.recChPerStim = cell(1,nChannels);
end
if ~isfield(channInfo,'selBipolar')
    channInfo.selBipolar = cell(1,nChannels);  %  create ALL pairs - some do not make sense!!  %before: channels.selBipolar =[{[1,2;3,4]},{[1,2;3,4]},{[1,2;3,4]}]; % we don't want to create bipolar channles between stim channels and no stim channels
end

%% Example structure
% %% STIMULATION CHANNELS - Network 1
% channInfo1.pName = 'MGxx';
% channInfo1.stimChNumber      = [1    10    15    24    40    58    83    91    95];    % the Cerestim number (1) from Network MAT file  - use: unique(stimchans(:,1))' 
% channInfo1.stimChNumber(2,:) = [2    11    16    25    41    59    84    92    96];     % the Cerestim number (2) - use: unique(stimchans(:,2))'
% nStim = 6; %size(channInfo1.stimChNumber,2);
% channInfo1.stimChNumberInNSX = [1    10    15    24    40    58,[83    91    95]-128+65 ]; %The NSX number of STIM channels - channels from NSP 2 are the number on the excel list -128 or the Cerestim # +bank -128
% channInfo1.stimChNumberInNSX(2,:) = [2    11    16    25    41    59, [84    92    96]-128+65 ]; % same for 2nd stim channel
% channInfo1.NSPnumber = [ones(1,3), 2*ones(1,3)];      % Whether is NSP1 or NSP2 %ones(nStim,1); %
% 
% %Optional - specify WHICH channels (otherwise all "around stim channels")
% channInfo1.stimChNames(1,1:nStim) = {'LOF01','LOF09', 'LAF01','LAF10', 'LAI09', 'LAT10'}; 
% channInfo1.stimChNames(2,1:nStim) = {'LOF02','LOF10', 'LAF02','LAF11','LAI10', 'LAT11'};
% channInfo1.recBipolarChPerStim = {{'LOF03-LOF04'},... 
%                                 {'LOF07-LOF08','LOF11-LOF12'},... 
%                                 {'LAF03-LAF04'},... 
%                                 {'LAF08-LAF09','LAF12-LAF13'},...
%                                 {'LAI07-LAI08','LAI11-LAI12'},...
%                                 {'LAT08-LAT09','LAT12-LAT13'},...
% }; 
% channInfo1.useBipolar =1;  
% channInfo1.chNamesToExcludeInput = {}; % from Notes:  if any
% channInfo1.recChPerStim = {[],[],[],[],[]}; 
% channInfo1.selBipolar = [{[]},{[]},{[]},{[]},{[]}]; %  channels.selBipolar =[{[1,2;3,4]},{[1,2;3,4]},{[1,2;3,4]}]; 
