% ----- settings -----
session = 'K:\StimDataBackup\Data_Stimulation\MG216b\TMS';
out_root = fullfile(session, 'edfs');

nsps = {'NSP1', 'NSP2'};

for n = 1:numel(nsps)
    nsp = nsps{n};

    % per-NSP output folder, e.g. ...\edfs\NSP1
    out_dir = fullfile(out_root, nsp);
    if ~exist(out_dir, 'dir'); mkdir(out_dir); end

    ns3_files = dir(fullfile(session, nsp, '*.ns3'));

    if isempty(ns3_files)
        fprintf(2, 'No .ns3 files in %s\n', fullfile(session, nsp));
        continue
    end

    for k = 1:numel(ns3_files)
        in_path = fullfile(ns3_files(k).folder, ns3_files(k).name);

        % keep the original .ns3 base name, just change extension to .edf
        [~, fname] = fileparts(ns3_files(k).name);
        out_path = fullfile(out_dir, [fname '.edf']);

        if exist(out_path, 'file')
            fprintf('Skipping (exists): %s\n', out_path);
            continue
        end

        try
            fprintf('%s [%d/%d]: %s -> %s\n', ...
                nsp, k, numel(ns3_files), in_path, out_path);
            blackrock_ns3_to_edf(in_path, out_path);
        catch ME
            fprintf(2, 'FAILED %s : %s\n', in_path, ME.message);
        end
    end
end