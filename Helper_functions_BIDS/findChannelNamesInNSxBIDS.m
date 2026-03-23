function channInfo = findChannelNamesInNSxBIDS(channInfo, allChNames, fileNameNSx)

nChannels=size(channInfo.stimChNumber,2); % J: # of combos
nPairs=size(channInfo.stimChNumber,1); % J: # of max sites per stim (2 sites max * 2 channels per site = 4)
nPreFixName=2; % J: what is this? => the number of channel name letters being compared later

% J: reading channel names from ns3 file header
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

     % J: stimChNumber used to be ch pair x 2 ([ch1_a ch2_a; ch1_b ch2_b; ch1_c ch2_c]
     % J: that's a transpose shape from what this new stimChNumber (4x6)
channInfo.stimChNumber = channInfo.stimChNumber';
% Assign NSX channel number based on bank info
if isfield(channInfo,'bankInfo') && (~isfield(channInfo,'stimChNumberInNSX') || isempty(channInfo.stimChNumberInNSX))
    channInfo.stimChNumberInNSX = zeros(size(channInfo.stimChNumber));
    for iPair=1:nChannels
    % J: indChInBankX all used to be the same size but not anymore so
    % stimChNumberInNSX has to be filled differently
    indChInBankA = find(channInfo.stimChNumber(iPair,:)<=32); %The 1 is WRONG - it should be indepdent for each pair/channel
    indChInBankB = intersect(find(channInfo.stimChNumber(iPair,:)>32), find(channInfo.stimChNumber(iPair,:)<=64));
    indChInBankC = intersect(find(channInfo.stimChNumber(iPair,:)>64), find(channInfo.stimChNumber(iPair,:)<=96));
                    
     % J: new new NEW
     iBankA = channInfo.stimChNumber(iPair,indChInBankA) + 0;
     iBankA = iBankA(iBankA>0);
     currentBankIndexToAdd = channInfo.bankInfo.bankA(iBankA);
     channInfo.stimChNumberInNSX(iPair,1:length(iBankA)) = currentBankIndexToAdd;
     
     iBankB = channInfo.stimChNumber(iPair,indChInBankB) - 32;
     iBankB = iBankB(iBankB>0);
     currentBankIndexToAdd = channInfo.bankInfo.bankB(iBankB);
     channInfo.stimChNumberInNSX(iPair,[1:length(iBankB)]+length(iBankA)) = currentBankIndexToAdd;
     
     iBankC = channInfo.stimChNumber(iPair,indChInBankC) - 64;
     iBankC = iBankC(iBankC>0);
     currentBankIndexToAdd = channInfo.bankInfo.bankC(iBankC);
     channInfo.stimChNumberInNSX(iPair,[1:length(iBankC)]+length(iBankA)+length(iBankB)) = currentBankIndexToAdd;

     channInfo.NSPnumber(iPair,indChInBankA) = channInfo.bankInfo.bankANSP;          
     channInfo.NSPnumber(iPair,indChInBankB) = channInfo.bankInfo.bankBNSP;           
     channInfo.NSPnumber(iPair,indChInBankC) = channInfo.bankInfo.bankCNSP; 
     
    end
end

if ~isfield(channInfo,'stimChNames') || isempty(channInfo.stimChNames)
    channInfo.stimChNames={};
    for iCh=1:nChannels            
        indNSP = channInfo.NSPnumber(iCh,:);
        stimChNumbers = channInfo.stimChNumberInNSX(iCh,:);
        chNamesToAdd = cell(size(stimChNumbers));
        % looping through rows AND columns
        for iPair = 1:length(stimChNumbers)
            if ~ismember(stimChNumbers(iPair),0)
                chNamesToAdd(iPair) = allChNames{indNSP(iPair)}(stimChNumbers(iPair));
            end
        end
        channInfo.stimChNames(iCh,:) = chNamesToAdd;
        
    end
end



% J: **************************** left off here 2/5
% recBipolarChPerStim has bipolar ch pairs to the immediate left and right
% of the stim site: {1 x number of stim sites} => {1 x 2* number of stim
% sites} => ch2 - ch1
if ~isfield(channInfo,'recBipolarChPerStim')|| isempty(channInfo.recBipolarChPerStim)
    for iCh=1:nChannels
        
        stimChNumbers = channInfo.stimChNumberInNSX(iCh,:);
        indNSP = channInfo.NSPnumber(iCh,:);
        channInfo.recBipolarChPerStim{iCh} = cell(1,nPairs); % J: number of stim sites is the number of combos
        
        for iPair = 1:2:nPairs
            % skip second pair if it's single site stim
            if stimChNumbers(iPair) == 0
                continue
            end
            
            % pair to the left
            if stimChNumbers(iPair)>2 % J: it's ch2-ch1 and ch1 can't be less than 0 so must be > 2 (can it not be = 2?): no because we're not doing the stim site, we're doing a pair before and after
                channInfo.recBipolarChPerStim{iCh}{iPair} = strcat(allChNames{indNSP(iPair)}{stimChNumbers(iPair)-1},'-',allChNames{indNSP(iPair)}{stimChNumbers(iPair)-2});
            end
            % pair to the right
            channInfo.recBipolarChPerStim{iCh}{iPair+1} = strcat(allChNames{indNSP(iPair+1)}{stimChNumbers(iPair+1)+2},'-',allChNames{indNSP(iPair+1)}{stimChNumbers(iPair+1)+1});
           

            if ~strncmp(channInfo.recBipolarChPerStim{iCh}{iPair+1},channInfo.stimChNames{iCh,iPair+1}(1:nPreFixName),nPreFixName)
                channInfo.recBipolarChPerStim{iCh}(iPair+1) = [];
            end
            if ~strncmp(channInfo.recBipolarChPerStim{iCh}{iPair},channInfo.stimChNames{iCh,iPair}(1:nPreFixName),nPreFixName)
                channInfo.recBipolarChPerStim{iCh}(iPair) = [];
            end
        end

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
