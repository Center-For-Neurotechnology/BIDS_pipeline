function json_helper(json_filename, json_structure)
% this function saves a json file
% INPUTS:
%   - json_filename: string of the full path and name of json file to be saved (eg
%   'C:/user/folder/filename.json')
%   - json_structure: a structure containing the key-value pairs of the json file
%   (eg json_structure with format json_structure.field = 'value') 
jsonSaveDir = fileparts(json_filename);
if ~exist(jsonSaveDir,'dir')
    mkdir(jsonSaveDir)
    fprintf('Warning: directory to save json file did not exist, created: %s \n', jsonSaveDir);
end

try
    json_options.indent = '  ';
    jsonwrite(strrep(json_filename, '.tsv', '.json'), json_structure, json_options);
catch
    warning('%s\n%s\n%s\n%s', ...
            'Writing the JSON file seems to have failed.', ...
            'Make sure that the following library is in the matlab/octave path:', ...
            'https://github.com/gllmflndn/JSONio');
end

end