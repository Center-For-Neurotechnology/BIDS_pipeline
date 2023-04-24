%% save data as BrainVision BIDS
for bnk=1:2
    if bnk==1
        DataFeed=DATAlfp1;
        nspStr='NSP1';
    elseif bnk==2
        DataFeed=DATAlfp2;
        nspStr='NSP2';
    end
        
   ieeg_name_save = fullfile(root_dir,project_label, ['sub-' ieeg_sub], ['ses-' ieeg_ses], 'ieeg', ...
            ['sub-' ieeg_sub, '_ses-' ieeg_ses,'_task-' ieeg_task, nspStr,'_run-' ieeg_run, '_ieeg']);
 
    if isempty(DataFeed)==0
        % assign header fields:
        dataStruct.hdr.Fs = FS1;  % sampling frequency
        dataStruct.hdr.nChans = size(DataFeed,1);
        
        dataStruct.hdr.label = cell(dataStruct.hdr.nChans, 1);  % number of channels
        for kk = 1:dataStruct.hdr.nChans
            dataStruct.hdr.label{kk} = ['iEEG' int2str(kk)];
        end
     
        dataStruct.hdr.nSamples = size(DataFeed,2);  % number of samples
        dataStruct.hdr.nSamplesPre = 0;
        dataStruct.hdr.nTrials = 1;  % 1 trial for continuous data

        dataStruct.hdr.chantype = cell(dataStruct.hdr.nChans, 1); % channels type, see BIDS list of types
        for kk = sEEG_channels
            dataStruct.hdr.chantype{kk} = 'sEEG';
        end
        for kk = scalp_channels
            dataStruct.hdr.chantype{kk} = 'scalp'; % J: are these not used?
        end
        for kk = triggers_channels
            dataStruct.hdr.chantype{kk} = 'triggers';
        end
        
        dataStruct.hdr.chanunit = repmat({'uV'}, size(dataStruct.hdr.chantype, 1), 1); % from BIDS docs: "RECOMMENDED: uV or µV"
        dataStruct.label = dataStruct.hdr.label;  % labels again, same as before
        dataStruct.time{1} = [1:dataStruct.hdr.nSamples] / dataStruct.hdr.Fs;  % time vector
        dataStruct.trial{1} = DataFeed;  % put the data matrix here: electrodes x samples
        dataStruct.fsample = dataStruct.hdr.Fs; % sampling freq again, same as before
        dataStruct.sampleinfo = [1 dataStruct.hdr.nSamples];
        hdr_data = ft_fetch_header(dataStruct);  % now fetch a header

        % save the data
        ft_write_data(ieeg_name_save, dataStruct.trial{1}, 'header', hdr_data, 'dataformat', 'brainvision_eeg');
        if create_edf
            ft_write_data(ieeg_name_save, dataStruct.trial{1}, 'header', hdr_data, 'dataformat', 'edf');
        end
    end
end
