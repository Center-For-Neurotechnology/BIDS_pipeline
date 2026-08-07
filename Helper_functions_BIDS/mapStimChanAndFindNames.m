function channInfo = mapStimChanAndFindNames(channInfo, dirRawData, xlsFileName, posFixNCS)

channInfo.stimChNumberInNSX = zeros(size(channInfo.stimChNumber));
% first site
indChInBankA1 = find(channInfo.stimChNumber(1,:)<=32);
indChInBankB1 = intersect(find(channInfo.stimChNumber(1,:)>32), find(channInfo.stimChNumber(1,:)<=64));
indChInBankC1 = intersect(find(channInfo.stimChNumber(1,:)>64), find(channInfo.stimChNumber(1,:)<=96));
% second site
indChInBankA2 = find(channInfo.stimChNumber(2,:)<=32);
indChInBankB2 = intersect(find(channInfo.stimChNumber(2,:)>32), find(channInfo.stimChNumber(2,:)<=64));
indChInBankC2 = intersect(find(channInfo.stimChNumber(2,:)>64), find(channInfo.stimChNumber(2,:)<=96));


channInfo.stimChNumberInNSX(1,:) = [channInfo.bankInfo.bankA(channInfo.stimChNumber(1,indChInBankA1) + 0),channInfo.bankInfo.bankB(channInfo.stimChNumber(1,indChInBankB1) - 32),channInfo.bankInfo.bankC(channInfo.stimChNumber(1,indChInBankC1) - 64)];
channInfo.stimChNumberInNSX(2,:) = [channInfo.bankInfo.bankA(channInfo.stimChNumber(2,indChInBankA2) + 0),channInfo.bankInfo.bankB(channInfo.stimChNumber(2,indChInBankB2) - 32),channInfo.bankInfo.bankC(channInfo.stimChNumber(2,indChInBankC2) - 64)];

[data,chNumber, allChNames, hdr] = readCSCfilesChNamesFromXls_incBlanks(dirRawData, xlsFileName, posFixNCS);

nChannels=length(channInfo.stimChNumber);
if ~isfield(channInfo,'stimChNames') || isempty(channInfo.stimChNames)
    channInfo.stimChNames=[];
    for iCh=1:nChannels
        stimChNumbers = channInfo.stimChNumberInNSX(:,iCh);
        
        channInfo.stimChNames = [channInfo.stimChNames, allChNames(stimChNumbers)];
    end
end
output = reshape(channInfo.stimChNames,2, length(channInfo.stimChNames)/2);
channInfo.stimChNames = output;
