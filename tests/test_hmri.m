function tests = test_hmri
%TEST_HMRI Unit tests for the hMRI helpers. They need neither SPM nor real data.
%   Run from the repository root with: runtests('tests')
tests = functiontests(localfunctions);
end


function setupOnce(testCase)
repo_dir = fileparts(fileparts(mfilename('fullpath')));
testCase.applyFixture(matlab.unittest.fixtures.PathFixture(fullfile(repo_dir, 'matlab'), ...
    'IncludingSubfolders', true));
end


function setup(testCase)
% Fake BIDS dataset with empty files: 7T protocol, 6 PD and 6 T1 echoes, no MT.
fixture = testCase.applyFixture(matlab.unittest.fixtures.TemporaryFolderFixture);
bids = fixture.Folder;
anat = fullfile(bids, 'sub-115', 'ses-01', 'anat');
fmap = fullfile(bids, 'sub-115', 'ses-01', 'fmap');
mkdir(anat); mkdir(fmap);
for echo = [1:6, 10]  % echo-10 checks numeric (not lexical) sorting
    touch(fullfile(anat, sprintf('sub-115_ses-01_acq-PDw_echo-%d_flip-1_mt-off_part-mag_MPM.nii', echo)));
    touch(fullfile(anat, sprintf('sub-115_ses-01_acq-T1w_echo-%d_flip-2_mt-off_part-mag_MPM.nii.gz', echo)));
end
touch(fullfile(anat, 'sub-115_ses-01_acq-PDw_echo-1_flip-1_mt-off_part-phase_MPM.nii'));
touch(fullfile(fmap, 'sub-115_ses-01_acq-tr1_TB1AFI.nii.gz'));
touch(fullfile(fmap, 'sub-115_ses-01_acq-tr2_TB1AFI.nii.gz'));
testCase.TestData.bids = bids;
testCase.TestData.anat = anat;
testCase.TestData.fmap = fmap;
end


function touch(file)
fclose(fopen(file, 'w'));
end


function test_finds_echoes_sorted_numerically(testCase)
inputs = hmri_find_inputs(testCase.TestData.bids, 'sub-115', 'ses-01');
[~, names] = cellfun(@fileparts, inputs.PD, 'UniformOutput', false);
expected = arrayfun(@(e) sprintf('sub-115_ses-01_acq-PDw_echo-%d_flip-1_mt-off_part-mag_MPM', e), ...
    [1:6, 10]', 'UniformOutput', false);
verifyEqual(testCase, names, expected);
verifyNumElements(testCase, inputs.T1, 7);
end


function test_ignores_phase_images(testCase)
inputs = hmri_find_inputs(testCase.TestData.bids, 'sub-115', 'ses-01');
verifyEmpty(testCase, inputs.PD(contains(inputs.PD, 'part-phase')));
end


function test_mt_is_empty_without_mt_run(testCase)
inputs = hmri_find_inputs(testCase.TestData.bids, 'sub-115', 'ses-01');
verifyEqual(testCase, inputs.MT, cell(0, 1));
end


function test_b1_order_is_tr2_then_tr1(testCase)
inputs = hmri_find_inputs(testCase.TestData.bids, 'sub-115', 'ses-01');
verifyTrue(testCase, contains(inputs.B1{1}, 'acq-tr2'));
verifyTrue(testCase, contains(inputs.B1{2}, 'acq-tr1'));
end


function test_accepts_labels_without_prefix(testCase)
inputs = hmri_find_inputs(testCase.TestData.bids, '115', '01');
verifyEqual(testCase, inputs.subject, '115');
verifyEqual(testCase, inputs.session, '01');
verifyNumElements(testCase, inputs.PD, 7);
end


function test_prefers_uncompressed_when_both_exist(testCase)
touch(fullfile(testCase.TestData.fmap, 'sub-115_ses-01_acq-tr1_TB1AFI.nii'));
inputs = hmri_find_inputs(testCase.TestData.bids, 'sub-115', 'ses-01');
verifyTrue(testCase, endsWith(inputs.B1{2}, 'acq-tr1_TB1AFI.nii'));
end


function test_missing_b1_raises(testCase)
delete(fullfile(testCase.TestData.fmap, 'sub-115_ses-01_acq-tr2_TB1AFI.nii.gz'));
verifyError(testCase, @() hmri_find_inputs(testCase.TestData.bids, 'sub-115', 'ses-01'), ...
    'qmritools:hmri:missingInput');
end


function test_missing_subject_raises(testCase)
verifyError(testCase, @() hmri_find_inputs(testCase.TestData.bids, 'sub-999', 'ses-01'), ...
    'qmritools:hmri:missingInput');
end


function test_batch_contains_inputs_and_defaults(testCase)
inputs = hmri_find_inputs(testCase.TestData.bids, 'sub-115', 'ses-01');
batch = hmri_build_batch(inputs, '/out', 'defaults.m', 'b1_defaults.m');

verifyEqual(testCase, batch{1}.spm.tools.hmri.hmri_config.hmri_setdef.customised, {'defaults.m'});
subj = batch{2}.spm.tools.hmri.create_mpm.subj;
verifyEqual(testCase, subj.output.outdir, {'/out'});
verifyEqual(testCase, subj.b1_type.i3D_AFI.b1parameters.b1defaults, {'b1_defaults.m'});
verifyEqual(testCase, subj.raw_mpm.PD, strcat(inputs.PD, ',1'));
verifyEqual(testCase, subj.raw_mpm.T1, strcat(inputs.T1, ',1'));
verifyEqual(testCase, subj.b1_type.i3D_AFI.b1input, strcat(inputs.B1, ',1'));
verifyEqual(testCase, subj.raw_mpm.MT, '');
verifyEqual(testCase, subj.sensitivity.RF_us, '-');
verifyFalse(testCase, subj.popup);
end


function test_dataset_description_is_valid_bids(testCase)
out = fullfile(testCase.TestData.bids, 'derivatives', 'hMRI');
file = hmri_write_dataset_description(out);
description = jsondecode(fileread(file));
verifyEqual(testCase, description.DatasetType, 'derivative');
verifyEqual(testCase, description.GeneratedBy(1).Name, 'hMRI toolbox');
verifyTrue(testCase, isfield(description, 'BIDSVersion'));
end


function test_dataset_description_is_not_overwritten(testCase)
out = fullfile(testCase.TestData.bids, 'derivatives', 'hMRI');
mkdir(out);
file = fullfile(out, 'dataset_description.json');
fid = fopen(file, 'w'); fprintf(fid, '{"Name": "edited by hand"}'); fclose(fid);
hmri_write_dataset_description(out);
description = jsondecode(fileread(file));
verifyEqual(testCase, description.Name, 'edited by hand');
end
