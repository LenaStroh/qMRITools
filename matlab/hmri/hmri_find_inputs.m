function inputs = hmri_find_inputs(bids_dir, subject, session)
%HMRI_FIND_INPUTS Locate raw MPM echoes and 3D-AFI B1 maps in a BIDS dataset.
%
%   inputs = hmri_find_inputs(bids_dir, subject, session)
%
%   Searches <bids_dir>/sub-<label>/ses-<label>/anat for magnitude MPM
%   echoes named after the BIDS qMRI convention, e.g.
%       sub-01_ses-01_acq-PDw_echo-1_flip-1_mt-off_part-mag_MPM.nii[.gz]
%   and <bids_dir>/sub-<label>/ses-<label>/fmap for the two 3D-AFI B1 maps
%       sub-01_ses-01_acq-tr1_TB1AFI.nii[.gz], sub-01_ses-01_acq-tr2_TB1AFI.nii[.gz]
%
%   SUBJECT and SESSION may be given with or without their prefix
%   ('sub-01' or '01', 'ses-01' or '01').
%
%   Returns a struct with fields
%       subject, session : labels without prefix
%       PD, T1, MT       : column cellstr of full paths, sorted by echo number
%                          (MT is {} when the protocol has no MT-weighted run)
%       B1               : {tr2; tr1}, the order the hMRI 3D-AFI input expects
%
%   Errors (id 'qmritools:hmri:missingInput') if PD, T1 or B1 files are missing.

sub = strip_prefix(subject, 'sub-');
ses = strip_prefix(session, 'ses-');
prefix = sprintf('sub-%s_ses-%s', sub, ses);
session_dir = fullfile(bids_dir, ['sub-' sub], ['ses-' ses]);
anat_dir = fullfile(session_dir, 'anat');
fmap_dir = fullfile(session_dir, 'fmap');

inputs.subject = sub;
inputs.session = ses;
inputs.PD = find_echoes(anat_dir, prefix, 'PDw');
inputs.T1 = find_echoes(anat_dir, prefix, 'T1w');
inputs.MT = find_echoes(anat_dir, prefix, 'MTw');
inputs.B1 = {find_one(fmap_dir, [prefix '_acq-tr2_TB1AFI']); ...
             find_one(fmap_dir, [prefix '_acq-tr1_TB1AFI'])};

for contrast = {'PD', 'T1'}
    if isempty(inputs.(contrast{1}))
        error('qmritools:hmri:missingInput', ...
            'No %sw MPM echoes found for %s in %s', contrast{1}, prefix, anat_dir);
    end
end
end


function label = strip_prefix(label, prefix)
label = char(label);
if startsWith(label, prefix)
    label = label(numel(prefix) + 1:end);
end
end


function files = find_echoes(directory, prefix, acq)
% All magnitude echoes of one contrast, sorted numerically by echo index.
files = list_nifti(directory, [prefix '_acq-' acq '_echo-*part-mag_MPM']);
if isempty(files)
    return
end
tokens = regexp(files, '_echo-(\d+)_', 'tokens', 'once');
echo_numbers = cellfun(@(t) str2double(t{1}), tokens);
[~, order] = sort(echo_numbers);
files = files(order);
end


function file = find_one(directory, stem)
files = list_nifti(directory, stem);
if numel(files) ~= 1
    error('qmritools:hmri:missingInput', ...
        'Expected exactly one %s.nii[.gz] in %s, found %d', stem, directory, numel(files));
end
file = files{1};
end


function files = list_nifti(directory, pattern)
% Full paths of <pattern>.nii and <pattern>.nii.gz; .nii wins if both exist.
listing = [dir(fullfile(directory, [pattern '.nii'])); ...
           dir(fullfile(directory, [pattern '.nii.gz']))];
names = {listing.name};
stems = regexprep(names, '\.nii(\.gz)?$', '');
[~, keep] = unique(stems, 'first');
files = fullfile(directory, names(sort(keep)));
files = files(:);
end
