
template = struct( ...
    'LongName', TaskName, ...
    'Description', '', ...
    'Levels', [], ...
    'Units', 'n/a', ...
    'TermURL', 'https://github.com/Center-For-Neurotechnology/CereLAB');

dd_json.trial_type = template;
dd_json.trial_type.Description = 'Stimulation';
dd_json.trial_type.Levels = struct( ...
    'SinglePulseshort', '0.233ms duration single pulse stim, multiple current amplitudes, multiple locations', ...
    'SinglePulselong', '1.053ms duration single pulse stim, 7mA current amplitudes, multiple locations', ...
    'Train', '400ms duration, multiple frequencies from 10Hz to 200Hz, multiple locations');
dd_json.identifier.LongName = 'Intracranial direct electrical stimulation';
dd_json.identifier.Description = ['Stimulation was controlled via a custom Cerestim API via MATLAB or a custom C++ code (https://github.com/Center-For-Neurotechnology/CereLAB).',... 
    'Waveforms of two different durations were used: .',...
    '233 µs duration: 90 µs charge-balanced biphasic symmetrical pulses with an interphase interval of 53 µsec with between 5 and 100 trials with a median of 20 trials per stimulation site across the data set .',...
    'and 2) 1053 µs (~1 msec) duration: 500 µs charge-balanced biphasic symmetrical pulses with an interphase interval of 53 µsec with between 10 and 26 trials per stimulation site with a median of 10 trials per site. .',...
    'The interval at 53 ms was required as a hardware-limited minimum interval between square pulses with the CereStim stimulator. .',...
    'For varying Current Amplitude tests, multiple current amplitudes were applied with the short duration (233 µsec) bipolar stimulation at the following steps: 0.5 mA to 10 mA at 0.5 mA steps with a minimum of 10 trials per stimulation site. ',...
    'For train stimuli, each trial delivered a 400 ms train (90 ms charge-balanced biphasic symmetrical pulses with an interphase interval of 53 msec) with varying ',...
    'pulse frequencies (10-200 Hz) and amplitudes (0.5-10 mA).']; % Free form description of stimulation parameters,
dd_json.StimulusPresentation.OperatingSystem = 'Windows 10';
dd_json.StimulusPresentation.SoftwareName = 'CereStim API and CereLAB';
dd_json.StimulusPresentation.SoftwareRRID = 'xxx_xxx';
dd_json.StimulusPresentation.SoftwareVersion = 'n/a';
dd_json.StimulusPresentation.Code = 'https://github.com/Center-For-Neurotechnology/CereLAB';

for bnk=1:2
    if bnk==1
        ChannelList=ElectrodeLabelsBank1;
        nspStr = 'NSP1';
        Trials=TrialAlignedMat1;
    elseif bnk==2
        ChannelList=ElectrodeLabelsBank2;
        nspStr = 'NSP2';
        Trials=TrialAlignedMat2;  
    end

    channels_tsv_name = fullfile(root_dir, project_label,['sub-' ieeg_sub], ['ses-' ieeg_ses], 'ieeg', ...
            ['sub-' ieeg_sub, '_ses-' ieeg_ses,'_task-' ieeg_task, nspStr,'_run-' ieeg_run '_channels.tsv']);
    events_tsv_name = fullfile(root_dir, project_label,['sub-' ieeg_sub],['ses-' ieeg_ses], 'ieeg', ...
            ['sub-' ieeg_sub,'_ses-' ieeg_ses,'_task-' ieeg_task, nspStr,'_run-' ieeg_run '_events.tsv']);
   
    if isempty(ChannelList)==0
        type=ChannelInformation(ChannelPairs(:,3)==bnk,12);
        name=ChannelInformation(ChannelPairs(:,3)==bnk,11);
        units=ChannelInformation(ChannelPairs(:,3)==bnk,13);
        low_cutoff=ChannelInformation(ChannelPairs(:,3)==bnk,15);
        high_cutoff=ChannelInformation(ChannelPairs(:,3)==bnk,14);
        reference=ChannelInformation(ChannelPairs(:,3)==bnk,16);
        group=ChannelInformation(ChannelPairs(:,3)==bnk,17);
        sampling_frequency=ChannelInformation(ChannelPairs(:,3)==bnk,18);
        status_description=ChannelInformation(ChannelPairs(:,3)==bnk,22);
        for simw=1:length(status_description)
            if isempty(status_description{simw})==1
                status_description{simw}='n/a';
            end
        end
        description=ChannelInformation(ChannelPairs(:,3)==bnk,19);
        status=ChannelInformation(ChannelPairs(:,3)==bnk,21);
        for simw=1:length(status)
            if isempty(status{simw})==1
                status{simw}='n/a';
            end
        end
        notch=ChannelInformation(ChannelPairs(:,3)==bnk,20);

        t = table(name, type, units, low_cutoff, high_cutoff, reference, ...
            group, sampling_frequency, description, notch, status, status_description);
        % J: where are t1/2 used? is it needed?
        if bnk==1
            t1=t;
        elseif bnk==2
            t2=t;
        end
        writetable(t, channels_tsv_name, 'FileType', 'text', 'Delimiter', '\t');
    end
    
    if isempty(Trials)==0
        % REQUIRED 
        onset = Trials(:,3); % Onset (in seconds) of the event measured  % J: is this a manual input, coming from TrialAlignedMat1 so I'm assuming that's already fixed
        duration=NaN*ones(size(Trials,1),1);   % Duration of the event (measured from onset) in seconds.
        Frequency=NaN*ones(size(Trials,1),1);
        electrical_stimulation_site=cell(size(Trials,1),1);
        % OPTIONAL 
        electrical_stimulation_trial_type=cell(size(Trials,1),1);  % Primary categorization of each trial to identify them as instances of the experimental conditions
        for TR=1:size(Trials,1)
            if Trials(TR,6)==0
                durStim=0.233;
                pulsetype='Single Pulse';
                freq=0;
            elseif Trials(TR,6)==1
                durStim=1.053;
                pulsetype='Single Pulse';
                freq=0;
            else
                durStim=400;
                pulsetype='Train';
                freq=Trials(TR,6);
            end
            duration(TR) = durStim;
            Frequency(TR)=freq;
            if Trials(TR,9)==1
                electrical_stimulation_trial_type(TR) = {['Bipolar ',pulsetype,' stim, channels: ',ElectrodeLabelsBank1{Trials(TR,8)},'-',ElectrodeLabelsBank1{Trials(TR,10)},...
                    ', current:',num2str(Trials(TR,7)),' mA',', stimulation duration:',num2str(durStim),'ms, frequency:',num2str(freq),'Hz']};
            elseif Trials(TR,9)==2
                electrical_stimulation_trial_type(TR) =  {['Bipolar ',pulsetype,' stim, channels: ',ElectrodeLabelsBank2{Trials(TR,8)},'-',ElectrodeLabelsBank2{Trials(TR,10)},...
                    ', current:',num2str(Trials(TR,7)),' mA',', stimulation duration:',num2str(durStim),'ms, frequency:',num2str(freq),'Hz']};
            end
            electrical_stimulation_site(TR)= {[ElectrodeLabelsBank1{Trials(TR,8)},'-',ElectrodeLabelsBank1{Trials(TR,10)}]}; % J: problem: sometimes Trials(TR,8)=0 (which is not a valid index number), so should it be skipped or manually fixed? ask ACP
        end
        response_time = repmat({'n/a'},size(Trials,1),1); % Response time in seconds. A negative response time can represent preemptive responses and n/a denotes a missed response.
        stim_file = repmat({'n/a'},size(Trials,1),1);  % Location of the stimulus file (image, video, sound etc.) presented at the onset time
        HED = repmat({'n/a'},size(Trials,1),1); % OPTIONAL Hierarchical Event Descriptor (HED) Tag.
        
        % Save table and json
        electrical_stimulation_type= repmat({'biphasic'},size(Trials,1),1);
        electrical_stimulation_StimOnset_sec = Trials(:,2);
        electrical_stimulation_StimOffset_sec = Trials(:,2);
        electrical_stimulation_Frequency_Hz = Frequency;
        electrical_stimulation_Current_mA = Trials(:,7);
        electrical_stimulation_Channel1Stim = Trials(:,8);
        electrical_stimulation_Channel1StimNSP = Trials(:,9);
        electrical_stimulation_Channel2Stim = Trials(:,10);
        electrical_stimulation_Channel2StimNSP = Trials(:,11);

        t = table(onset, duration, electrical_stimulation_trial_type, response_time, stim_file, HED,...
            electrical_stimulation_StimOnset_sec,electrical_stimulation_StimOffset_sec,electrical_stimulation_Frequency_Hz,electrical_stimulation_Current_mA,...
            electrical_stimulation_site,electrical_stimulation_type,electrical_stimulation_Channel1Stim,...
            electrical_stimulation_Channel1StimNSP,electrical_stimulation_Channel2Stim,electrical_stimulation_Channel2StimNSP);
        writetable(t, events_tsv_name, 'FileType', 'text', 'Delimiter', '\t');
        
        json_helper(events_tsv_name, dd_json)
    end
end

