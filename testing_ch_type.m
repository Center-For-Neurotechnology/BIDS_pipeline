% SEE - DOE
channelType_SEEG = regexp(nsp1_channelNames_temp, '^(L|R)[a-zA-Z]{2,3}\d{1,2}$')
channelType_SEEG = regexp(nsp2_channelNames, '^(L|R)[a-zA-Z]{2,3}\d{1,2}$')

% EEG - DONE
ScalpElectrodeList={'FP1';'F7';'T3';'T7';'T5';'O1';'F3';'C3';'P3';'FP2';'F8';'T4';'T6';'O2';'F4';'P4';'FZ';...
    'CZ';'PZ';'T1';'T2';'CII';'C4';'FP__01';'FP__02';'O3';'C2';'O2 Sa';'FP1_r';'T4_re';'O2';'O2Sat'};
channelType_EEG = regexp(ScalpElectrodeList, '^[FTOCPS].{0,}[\dZzIiAaRrEeTt]$')
channelType_EEG = regexp(nsp2_channelNames, '^[FTOCPS].{0,}[\dZzIiAaRrEeTt]$')

% EOG - DONE
EOGElectrodesList={'LOC';'ROC';};
channelType_EOG = regexp(EOGElectrodesList, '^(L|R)OC$')
channelType_EOC = regexp(nsp2_channelNames, '^(L|R)OC$')

% EMG - DONE
EMGElectrodesList={'EMG';'EMG1';'EMG2';};
channelType_EMG = regexp(EMGElectrodesList, '^EMG')
channelType_EMG = regexp(nsp2_channelNames, '^EMG')

% ECG -  DONE
ECGElectrodesList={'EKG';'EKG  ';'Pulse';'EKG1';};
channelType_ECG = regexp(ECGElectrodesList, '(^EKG|Pulse)')
channelType_ECG = regexp(nsp2_channelNames, '(^EKG|Pulse)')

% MISC - DONE
MiscElectrodeslist={'RESP';'chan';'empty';'broke';'104';'105';'106';'107';'108';'109';'110';'111';'112';'113';...
    '114';'115';'116';'117';'118';'119';'120';'121';'122';'123';'124';'125';'126';'127';'128';'BLANK';'BLA1';};

channelType_MISC = regexp(MiscElectrodeslist, '(^RESP|chan|empty|broke|BLANK|BLA1|1\d{2,}%)')
channelType_MISC = regexp(nsp2_channelNames, '(^RESP|chan|empty|broke|BLANK|BLA1|1\d{2,}%)')


% TRIG
channelType_TRIG = regexp(nsp2_channelNames, 'trigger','ignorecase')



%% testing
channelType_SEEG = regexp(nsp2_channelNames, '^(L|R)[a-zA-Z]{2,3}\d{1,2}$')
channelType_EEG = regexp(nsp2_channelNames, '^[FTOCPS].{0,}[\dZzIiAaRrEeTt]$')
channelType_EOC = regexp(nsp2_channelNames, '^(L|R)OC$')
channelType_EMG = regexp(nsp2_channelNames, '^EMG')
channelType_ECG = regexp(nsp2_channelNames, '(^EKG|Pulse)')
channelType_MISC = regexp(nsp2_channelNames, '(^RESP|chan|empty|broke|BLANK|BLA1|1\d{2,}%)')







%%



% TRIG - everything else
TrigElectrodesList={'SYNC';'TRIGGER';'IMAGE';'34';'DETECT';'SHAM';'SEND STIM';'38';'39';'40';'41';'43';'44';...
    '45';'46';'ainp01';'ainp02';'ainp03';'ainp04';'ainp05';'ainp06';'ainp07';'ainp08';'ainp09';'ainp10';'ainp11';'ainp12';'ainp13';'ainp14';'ainp15';'ainp16';...
    'ainp_1';'ainp_2';'ainp_3';'ainp_4';'ainp_5';'ainp_6';'ainp_7';'ainp_8';'ainp_9';'ainp1';'ainp2';'ainp3';...
    'ainp4';'ainp5';'ainp6';'ainp7';'ainp8';'ainp9';'AUDIO';'TRIGG';'DETEC';...
    'SEND ';'ainp0';'EVT';'trig';'RANDOM';'RANDO';'EVENT';'sync';'REF';'A1';'Trigg';'A1';'A2';'Stim';'SEND';...
    'TRIGGE';'SEND S';'imageOnset';'ainp17';'ainp18';'ainp19';'ainp20';'ainp21';'ainp22';'ainp23';'ainp24';...
    'ainp25';'ainp26';'ainp27';'ainp28';'REF1';'REF3';'REF_01';'REF_03';'BLA0N';'Stim 1';'Stim 2';'Stim1';...
    'Stim2';'cerestimOUT';'alphatrig';'REF_02';'REF_03'};
