% Create hMRI maps for 7T MPM data (3D-AFI B1 mapping, no MT run).
%
% Edit the three settings below, then run this script. SPM12 with the
% hMRI toolbox must be on the MATLAB path.

bids_dir = '/path/to/bids';          % BIDS root containing sub-*/ses-*/anat and fmap
subjects = {'sub-01', 'sub-02'};
session  = 'ses-01';

repo_dir = fileparts(fileparts(mfilename('fullpath')));
addpath(genpath(fullfile(repo_dir, 'matlab')));
defaults    = fullfile(repo_dir, 'config', 'hmri_CBS_7T_defaults.m');
b1_defaults = fullfile(repo_dir, 'config', 'hmri_b1_CBS_7T_defaults.m');

for i = 1:numel(subjects)
    fprintf('Creating hMRI maps for %s %s\n', subjects{i}, session);
    hmri_create_mpm(bids_dir, subjects{i}, session, defaults, b1_defaults);
end
