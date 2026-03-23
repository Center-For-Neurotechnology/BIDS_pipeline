function perSessionEventsTSVIntraop(directoryBIDS,sub_XXXX,taskName,ieeg_run,table_eventsTSV_edf,varNames)
% This function is run once for each session. It creates a tsv containing 
% electrical stimulation events and parameters. 
% The file will be saved in directoryBIDS\sub_XXXX\ses-postimp\ieeg\
% and have the name sub-XXXX_ses-postimp_task-NetworkWake1RAWNSP1_run-01_events.tsv
% INPUTS:
%   - directoryBIDS: string of the main folder where the BIDS data is being saved
%   - sub_XXXX: string of the deidentified patient ID
%   - taskName: string of the session task name
%   - ieeg_run: string of the session order
%   - filenameNS3_edf: string of the NSP1 .ns3 filename (full path)
%   - filenameNS3_nsp2: string of the NSP2 .ns3 filename (full path)
%   - stimParameters: structure containing pulse duration,
%       frequency, current, and stimulation type
%   - channInfo: structure containing information about cerestim-nsp
%       connection configuration
%   - fileNameStimSites: string of .mat file name (full path) containing
%       containing the stimulation channels for each event
%   - hdrclin_edf: structure created by perSessionChannelsTSV() containing NSP1 .ns3 headers 
% OUTPUTS: 
%   - sub-XXXX_ses-postimp_task-NetworkWake1RAWNSP1_run-01_events.tsv

%% file names of the saved .tsv files
% sub_XXXX\ses-postimp\ieeg\sub-XXXX_ses-postimp_task-NetworkWake1RAWNSP1_run-01_events.tsv
filename_eventsTSV_edf = [directoryBIDS,'/',sub_XXXX,'/ses-postimp/ieeg/',sub_XXXX,'_ses-postimp_task-',...
    taskName,'Clip_run-',ieeg_run,'_events.tsv'];


%% n/a values
response_time = 'n/a';
stim_file = 'n/a';
HED = 'n/a';
% 
% participant=seizuresInfo(:,1);
% Seizure_number=seizuresInfo(:,2);
% Seizure_file=seizuresInfo(:,3);
% Seizure_time_start=seizuresInfo(:,4);
% Seizure_time_end=seizuresInfo(:,5);
% Seizure_channel_onset=seizuresInfo(:,6);
% Seizure_Notes=seizuresInfo(:,7);



%% create tables and save tsv files
% varNames = seizuresInfoHeader;

if ~isempty(table_eventsTSV_edf) % avoid saving an empty file if there were no stim events in that nsp
    % table_eventsTSV_edf = table(participant,Seizure_number,Seizure_file,Seizure_time_start,Seizure_time_end,Seizure_channel_onset,...
    %     Seizure_Notes,...
    %     'VariableNames', varNames);
    % writetable(table_eventsTSV_edf, filename_eventsTSV_edf, 'FileType', 'text', 'Delimiter', '\t');

    t2C=table2cell(table_eventsTSV_edf);
    t2C1=[varNames;t2C];
    % writecell(t2C1, filename_eventsTSV_edf, 'FileType', 'text', 'Delimiter', '\t')

    writetable(table_eventsTSV_edf, filename_eventsTSV_edf, 'FileType', 'text', 'Delimiter', '\t','WriteVariableNames', true);

end


end