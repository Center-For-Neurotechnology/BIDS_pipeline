function clipped_eeg = gettingClipTimes(pName,resultsPath,fileNameNSxPerNSP,file_being_split,selChName1,buffer_time_minutes,start_time,end_time,nspNum)
% %% Setting up raw nsx file path and result path
% pName = 'MG157'; % J: patient
% resultsPath =  'E:\BIDStesting\nsx_results'; % J: results path, Used in fxn call: FRONT

%% Directories and Files
if ~exist(resultsPath,'dir'), mkdir(resultsPath); end % J: BACK


    %% Plotting Configuration
    % ********************** BACK
    cfgInfoPlot.xlimZoomMiliSec = [-250 250]; % Longer before because stim is only ~100ms after IID (due to long filtering window)
    cfgInfoPlot.xTimeForYlim = [10 100]/1000; % in seconds
    cfgInfoPlot.ampUnits = 'uV';
    cfgInfoPlot.maxAmpVal = 500;
    cfgInfoPlot.minAmpVal = -500;
    % ********************** 

    % ********************** BACK
    excludeTrials.excludeTrialsNSX = [];
    excludeTrials.excludeTrialsDecider = [];
    NSPindex = 1;
    % **********************

    %% Channels
    % ********************** BACK
    stimAINP.chNames = {'SYNC'};
    stimAINP.chRealNames = {'SYNC'};%,'SEND STIM','RANDOM','DETECTED'};
    stimChannInfo.stimChNames = {};%{'LHH01','LHH02'};
    recChannInfo.pName = pName; 
    recChannInfo.chNames = {};% {'LHH03','LHH04','LHH05'};
    recChannInfo.chNumberBipolar = []; %[1,2;2,3];
    % **********************

    %% Plot NSP1 data to find time when experiments start/end
    % ********************** BACK
    startNSxSec= 0;   % should always be full since this script is meant to see entire nsx
    endNSxSec = [];
    % **********************

    % selChName1 = [13,14;19,20];    % J: bipolar ch name's to visualize for clipping: FRONT

    % ********************** BACK
    %selChName1=selChName1';
    selBipolar1 = [1,2];    

    % ********************** BACK
    % 1. put together stim channels and recording channels info:
    channInfo = recChannInfo;
    channInfo.stimAINPChNames = stimAINP.chNames;
    channInfo.stimChNames = stimChannInfo.stimChNames;
    channInfo.stimChNumber = selChName1; 

    % 2. Check alignment beween TXT files and NSX (when STIM actually ocurred!)
    titName = ''; % J: this is just for visualization so it's not important to perfect right now (also why it wasn't rewritten for sync stim)
    [fileNameStimSitesWNSXinfo,dataBipolarPerCh,indTimeSTIMPerFile] = scriptCheckStimInNSXBIDS(fileNameNSxPerNSP, [], resultsPath, stimAINP.chNames, channInfo, titName);
    % **********************
    if ~exist('eeg_data','var')
        eeg_data = dataBipolarPerCh{1};
    end

    %% ********* CLIPPING **************************
    %% user input values
    sampling_rate = 2000; % Hz
    % buffer_time_minutes = 1; % session buffer in minutes;  % FRONT
    
if ~isempty(buffer_time_minutes)
    %% calculations based on user input
    buffer_time_seconds = buffer_time_minutes*60;
    buffer_time_data_points = buffer_time_seconds*sampling_rate; % actual data size clipped in eeg (t*[s/t]) = s

    %% plot eeg and select session start and end points

    hold on;           % and keep it there while plotting
    xs = [];
    ys = [];           % initialisations
    xold = 0;
    yold = 0;
    but = 1;

    title('Mark the start and end of each session:', 'FontSize', 20)
    legend('AutoUpdate','off')
    marker_colors = {'bo','bo-','bo','ro-','ro','go-','go','co-','co','mo-','mo'};
    count = 1;

    while but == 1                      % while button 1 being pressed
        [xi, yi, but] = ginput(1);      % get a point
        xs = [xs; xi];                  % append its coords to vector
        ys = [ys; yi];
        if xold
            plot([xold xi], [yold yi], marker_colors{count},'MarkerSize',10,'LineWidth',3);  % draw as we go
        else
            plot(xi, yi, 'bo-','MarkerSize',10);         % first point on its own
        end
        xold = xi;
        yold = yi;
        count = count + 1;
    end
    %plot([xi xs(1)], [yi ys(1)], 'k','MarkerSize',10); % join first to last points % what was this for?

    % reshaping to [start, end]
    for i = 2:2:length(xs)
        start_end(i/2,1) = xs(i-1);
        start_end(i/2,2) = xs(i);
    end

    clear but xi xold xs yi yold ys 

    % %% calculate buffer time points
    buffered_start_end = []; % array of start and end of buffers
%     if ~exist('eeg_data','var')
%         eeg_data = dataBipolarPerCh{1};
%     end
    %eeg_data = dataBipolarPerCh{1};

    % if there is only one session in this nsx file, then start_end will be
    % [1x2]
    if size(start_end,1) == 1
        if start_end(1,1) - buffer_time_data_points <= 1
            buffered_start_end(1,1) = 1;
        else
            buffered_start_end(1,1) = start_end(1,1) - buffer_time_data_points;
        end

        if start_end(1,2) + buffer_time_data_points >= length(eeg_data)
            buffered_start_end(1,2) = length(eeg_data);
        else
            buffered_start_end(1,2) = start_end(1,2) + buffer_time_data_points;
        end
    else
        for i = 1:length(start_end)
            % before start
            if i == 1
                max_buffer = start_end(i,1)-1;
            else 
                max_buffer = start_end(i,1) - start_end(i-1,2);
            end

            if max_buffer < buffer_time_data_points
                curr_buffer = max_buffer;
            else
                curr_buffer = buffer_time_data_points;
            end

            curr_buffered_start = start_end(i,1) - curr_buffer;
            buffered_start_end(i,1) = curr_buffered_start;

            % after end
            if i == length(start_end)
                max_buffer = length(eeg_data) - start_end(i,2); % length()?: ok bc x axis is in datapoints not time
            else
                max_buffer = start_end(i+1,1) - start_end(i,2);
            end

            if max_buffer < buffer_time_data_points
                curr_buffer = max_buffer;
            else
                curr_buffer = buffer_time_data_points;
            end

            curr_buffered_end = start_end(i,2) + curr_buffer;
            buffered_start_end(i,2) = curr_buffered_end;
        end
    end

% 
%     title('EEG will be clipped at the buffer lines:', 'FontSize', 25)
%     buffer_colors = {'b','r','g','c','m','b--','r--','g--','c--','m--'};
%     for i = 1:size(start_end,1)
%         xline([buffered_start_end(i,1)'], buffer_colors{i},'LineWidth',3);
%         xline([buffered_start_end(i,2)'], buffer_colors{i+5},'LineWidth',3);
%         hold off
%     end
% 
%     pause(3)
else
%     eeg_data = dataBipolarPerCh{1};
    if isempty(start_time)
        start_time = 1;
    end
    if isempty(end_time)
        end_time = length(eeg_data);
    end
    start_end = [start_time,end_time];
    buffered_start_end = start_end;
end


title('EEG will be clipped at the buffer lines:', 'FontSize', 25)
buffer_colors = {'b','r','g','c','m','b--','r--','g--','c--','m--'};
for i = 1:size(start_end,1)
    xline([buffered_start_end(i,1)'], buffer_colors{i},'LineWidth',3);
    xline([buffered_start_end(i,2)'], buffer_colors{i+5},'LineWidth',3);
    hold off
end

pause(3)

%% clip .MAT eeg at buffers
% not actually saving .mat files, just plotting for visual check :)
clipped_eeg = cell(size(start_end,1),1);
% saving different sessions (of diff length) into its own cell
for i = 1:size(start_end,1)
    clipped_eeg{i} = eeg_data(buffered_start_end(i,1): buffered_start_end(i,2));
end

figure(2)
hold on

% plotting clipped sessions seperately 
for i = 1:size(start_end,1)
    subplot(size(start_end,1),1,i);
    plot(clipped_eeg{i},buffer_colors{i})
    title(['Clip # ',num2str(i)])
end
sgtitle('Your clipped sessions:', 'FontSize', 25)

%% now clip ns3 and nev files
% have the start and end times in samples
% convert to time in seconds (input needed for openNSx() and openNEV())
buffered_start_end_sec = buffered_start_end/sampling_rate;
buffered_start_end_sec(:,1) = floor(buffered_start_end_sec(:,1));
buffered_start_end_sec(:,2) = ceil(buffered_start_end_sec(:,2));

for i = 1:size(buffered_start_end_sec,1)
    % create string for time ie. 't:3:10'
    time_param = ['t:',num2str(buffered_start_end_sec(i,1)),':',num2str(buffered_start_end_sec(i,2))];
%     current_session = input(['Type the session name of clip # ',num2str(i),' (this will be used for the file name):'],'s');
    current_session = file_being_split;
    for j = 1:length(fileNameNSxPerNSP)  % assumes there's two NSPs, should detect num of nsps
        session_folder = [resultsPath,filesep,file_being_split,filesep,'NSP',num2str(nspNum)];
            if ~exist(session_folder,'dir') % can prob be before loop for speed
                mkdir(session_folder); 
            end  
        new_file_name = [session_folder,filesep,current_session];
        current_ns3 = openNSx(fileNameNSxPerNSP{j}, 'read', 'report',time_param,'sec');
%         current_nev = openNEV(fileNameNEVPerNSP{j},'report','nomat','nosave',time_param);
        disp(['Saving clipped .ns3 files for session ',current_session,' ...'])
        saveNSx(current_ns3,[new_file_name,'.ns3']);
%         saveNEV(current_nev,[new_file_name,'.nev']);
    end
    disp(['Saved clipped .ns3 files for session ',current_session,'!'])
end

end
















