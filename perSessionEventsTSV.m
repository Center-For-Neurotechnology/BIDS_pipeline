function perSessionEventsTSV(filenameNEV_nsp1,filenameNEV_nsp2,stimPulseDuration,stimFrequency,stimCurrent,stim_type,cerestimA_nsp,cerestimB_nsp,cerestimC_nsp,cerestimA_channels,cerestimB_channels,cerestimC_channels,stimLogFile)
%{
-	Onset: 1261.195 * NOTE: this defines the number of stim events
-	Duration: 0.233;  stimPulseDuration X
-	electrical_stimulation_trial_type; X
-	response_time X
-	stim_file X
-	HED X
-	electrical_stimulation_StimOnset_sec: 1261.195
-	electrical_stimulation_StimOffset_sec: 1261.195
-	electrical_stimulation_Frequency_Hz: 0; stimFrequency X
-	electrical_stimulation_Current_mA; stimCurrent X
-	electrical_stimulation_site; stimBipolarSites X
-	electrical_stimulation_type; stim_type X
-	electrical_stimulation_Channel1Stim; stimLogChannelsNSP(:,1) X	
-	electrical_stimulation_Channel1StimNSP; stimLogNSPs(:,1) X
-	electrical_stimulation_Channel2Stim; stimLogChannelsNSP(:,2) X 	
-	electrical_stimulation_Channel2StimNSP; stimLogNSPs(:,2) X
%}


response_time = 'n/a';
stim_file = 'n/a';
HED = 'n/a';

cerestimAllBanks = [cerestimA_nsp; cerestimB_nsp; cerestimC_nsp];
cerestimAllChannels = [cerestimA_channels; cerestimB_channels; cerestimC_channels];

stimLogChannels = load(stimLogFile);
stimLogChannels = stimLogChannels.stimchans;
stimLogNSPs = [];
stimLogChannelsNSP = [];

% using log file to map cerestim stim channels to nsp channels to get: nsp
% number and channel number
for i = 1:size(stimLogChannels,1)
    for j = 1:size(stimLogChannels,2)
        if stimLogChannels(i,j) <= 32
            stimLogNSPs(i,j) = cerestimAllBanks(1);
            if cerestimAllBanks(1) == 1
                stimLogChannelsNSP(i,j) = stimLogChannels(i,j);
            else
                stimLogChannelsNSP(i,j) = stimLogChannels(i,j)+128;
            end
        elseif stimLogChannels(i,j) <= 65
            stimLogNSPs(i,j) = cerestimAllBanks(2);
            if cerestimAllBanks(2) == 1
                stimLogChannelsNSP(i,j) = stimLogChannels(i,j);
            else
                stimLogChannelsNSP(i,j) = stimLogChannels(i,j)+128;
            end
        else 
            stimLogNSPs(i,j) = cerestimAllBanks(3);
            if cerestimAllBanks(3) == 1
                stimLogChannelsNSP(i,j) = stimLogChannels(i,j);
            else
                stimLogChannelsNSP(i,j) = stimLogChannels(i,j)+128;
            end
        end 
    end
end

stimBipolarSites = {}; % getting the stim site channels
for i = 1:size(stimLogChannelsNSP,1)
    if stimLogChannelsNSP(i,1) <= 128
        stim_ch1 = hdrNS3_nsp1.hdr.label(stimLogChannelsNSP(i,1));
    else
        stim_ch1 = hdrNS3_nsp2.hdr.label(stimLogChannelsNSP(i,1)-128);
    end
    if stimLogChannelsNSP(i,2) <= 128
        stim_ch2 = hdrNS3_nsp1.hdr.label(stimLogChannelsNSP(i,2));
    else
        stim_ch2 = hdrNS3_nsp2.hdr.label(stimLogChannelsNSP(i,2)-128);
    end
    stimBipolarSites{i,1} = join([stim_ch1 stim_ch2],'-');
end

% 'Bipolar Single Pulse stim, channels: LTB_10-LTB_11, current: 7 mA, stimulation duration: 0.233 ms, frequency: 0 Hz'
electrical_stimulation_trial_type = {};
part1 = join([stim_type{1},"Single Pulse stim"],' ');
part3 = join(["current:", string(stimCurrent), 'mA'],' ');
part4 = join(["stimulation duration:", string(stimPulseDuration), 'ms'],' ');
part5 = join(["frequency:", string(stimFrequency), 'Hz'],' ');
for i = 1:size(stimBipolarSites,1) % both onset_sec and stimBipolarSites should be the same length/size
    part2 = join(["channels:", stimBipolarSites{i}],' ');
    electrical_stimulation_trial_type{i,1} = join([part1,part2,part3,part4,part5],', ');    
end




%******************** deal with times later


NEV_nsp1 = openNEV(filenameNEV_nsp1,'overwrite','report');
NEV_nsp2 = openNEV(filenameNEV_nsp2,'overwrite','report');

spikeSec_nsp1 = NEV_nsp1.Data.SerialDigitalIO.TimeStampSec; % but why r there so many spikes? start & end?
spikeSec_nsp2 = NEV_nsp2.Data.SerialDigitalIO.TimeStampSec;






end