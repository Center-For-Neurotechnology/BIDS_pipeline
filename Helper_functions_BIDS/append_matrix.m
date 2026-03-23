files = {'K:\StimDataBackup\Data_Stimulation\MG237\ThalamicMatrix1\Logfiles\Matrix-11-Feb-2026_19-10-30.mat',...
    'K:\StimDataBackup\Data_Stimulation\MG237\ThalamicMatrix1\Logfiles\Matrix-11-Feb-2026_19-13-48.mat',...
    'K:\StimDataBackup\Data_Stimulation\MG237\ThalamicMatrix1\Logfiles\Matrix-11-Feb-2026_19-17-01.mat'};

stimLog_all = table();

for f = 1:length(files)

    S = load(files{f});
    stimLog = S.stimMatrix;



    stimLog_all = [stimLog_all; stimLog];

end

stimLog_all.Trial = (1:height(stimLog_all))';