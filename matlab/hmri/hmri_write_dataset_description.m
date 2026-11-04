function file = hmri_write_dataset_description(derivatives_dir)
%HMRI_WRITE_DATASET_DESCRIPTION Write a BIDS dataset_description.json for hMRI derivatives.
%
%   file = hmri_write_dataset_description(derivatives_dir)
%
%   Creates <derivatives_dir>/dataset_description.json, as required for a
%   BIDS derivatives dataset. An existing file is left untouched so that
%   edits by hand (authors, funding, ...) are preserved.

file = fullfile(derivatives_dir, 'dataset_description.json');
if isfile(file)
    return
end
if ~isfolder(derivatives_dir)
    mkdir(derivatives_dir);
end

hmri_version = 'unknown';
if exist('hmri_get_version', 'file') == 2
    hmri_version = hmri_get_version();
end

description = struct( ...
    'Name', 'hMRI multi-parameter maps', ...
    'BIDSVersion', '1.10.0', ...
    'DatasetType', 'derivative', ...
    'GeneratedBy', {{struct( ...
        'Name', 'hMRI toolbox', ...
        'Version', hmri_version, ...
        'CodeURL', 'https://github.com/hMRI-group/hMRI-toolbox', ...
        'Description', 'Run via qMRITools hmri_create_mpm (https://github.com/LenaStroh/qMRITools)')}});

fid = fopen(file, 'w');
if fid < 0
    error('qmritools:hmri:cannotWrite', 'Cannot write %s', file);
end
closer = onCleanup(@() fclose(fid));
fprintf(fid, '%s\n', jsonencode(description, 'PrettyPrint', true));
end
