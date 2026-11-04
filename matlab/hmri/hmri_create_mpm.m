function out_dir = hmri_create_mpm(bids_dir, subject, session, defaults_file, b1_defaults_file, options)
%HMRI_CREATE_MPM Create hMRI maps (R1, R2*, PD, MTsat) for one BIDS subject/session.
%
%   out_dir = hmri_create_mpm(bids_dir, subject, session, defaults_file, b1_defaults_file)
%   out_dir = hmri_create_mpm(..., 'OutputDir', derivatives_dir)
%
%   Reads raw MPM echoes and 3D-AFI B1 maps from the BIDS dataset BIDS_DIR
%   (see HMRI_FIND_INPUTS for the expected file names) and runs the hMRI
%   toolbox "Create hMRI maps" module with the given defaults files.
%
%   Results are written to <OutputDir>/sub-<label>/ses-<label>/, where
%   OutputDir defaults to <bids_dir>/derivatives/hMRI. A BIDS
%   dataset_description.json is written to OutputDir if it does not exist.
%
%   The raw dataset is never modified: gzipped inputs are decompressed into
%   a temporary folder that is deleted afterwards.
%
%   Requires SPM12 with the hMRI toolbox on the MATLAB path.
%
%   Example
%       hmri_create_mpm('/data/bids', 'sub-01', 'ses-01', ...
%           'config/hmri_CBS_7T_defaults.m', 'config/hmri_b1_CBS_7T_defaults.m');

arguments
    bids_dir {mustBeFolder}
    subject {mustBeTextScalar}
    session {mustBeTextScalar}
    defaults_file {mustBeFile}
    b1_defaults_file {mustBeFile}
    options.OutputDir {mustBeTextScalar} = fullfile(bids_dir, 'derivatives', 'hMRI')
end

if exist('spm_jobman', 'file') ~= 2
    error('qmritools:hmri:noSPM', 'SPM12 (with the hMRI toolbox) must be on the MATLAB path.');
end

inputs = hmri_find_inputs(bids_dir, subject, session);

out_dir = fullfile(options.OutputDir, ['sub-' inputs.subject], ['ses-' inputs.session]);
if ~isfolder(out_dir)
    mkdir(out_dir);
end
hmri_write_dataset_description(options.OutputDir);

work_dir = tempname;
mkdir(work_dir);
cleanup = onCleanup(@() rmdir(work_dir, 's'));
for field = {'PD', 'T1', 'MT', 'B1'}
    inputs.(field{1}) = decompress(inputs.(field{1}), work_dir);
end

matlabbatch = hmri_build_batch(inputs, out_dir, char(defaults_file), char(b1_defaults_file));
spm_jobman('run', matlabbatch);
end


function files = decompress(files, work_dir)
% Replace every .nii.gz by an uncompressed copy in WORK_DIR (SPM cannot read .gz).
for i = 1:numel(files)
    if endsWith(files{i}, '.gz')
        files(i) = gunzip(files{i}, work_dir);
    end
end
end
