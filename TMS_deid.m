% ----- settings -----
root = 'K:\StimDataBackup\Data_Stimulation\MG216b\TMS\NSP2';

% find every .ns3 under root, at any depth
ns3_files = dir(fullfile(root, '**', '*.ns3'));

if isempty(ns3_files)
    error('No .ns3 files found under %s', root);
end

for k = 1:numel(ns3_files)
    in_folder = ns3_files(k).folder;                 % subfolder holding this .ns3
    in_path   = fullfile(in_folder, ns3_files(k).name);

    % make an "edfs" folder INSIDE that same subfolder
    out_dir = fullfile(in_folder, 'edfs');
    if ~exist(out_dir, 'dir'); mkdir(out_dir); end

    % keep original base name, swap extension to .edf
    [~, fname] = fileparts(ns3_files(k).name);
    out_path = fullfile(out_dir, [fname '.edf']);

    if exist(out_path, 'file')
        fprintf('Skipping (exists): %s\n', out_path);
        continue
    end

    try
        fprintf('[%d/%d] %s -> %s\n', k, numel(ns3_files), in_path, out_path);
        blackrock_ns3_to_edf(in_path, out_path);
    catch ME
        fprintf(2, 'FAILED %s : %s\n', in_path, ME.message);
    end
end