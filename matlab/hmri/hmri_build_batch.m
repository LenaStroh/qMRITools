function matlabbatch = hmri_build_batch(inputs, out_dir, defaults_file, b1_defaults_file)
%HMRI_BUILD_BATCH Build the SPM batch that creates hMRI maps from 3D-AFI B1 data.
%
%   matlabbatch = hmri_build_batch(inputs, out_dir, defaults_file, b1_defaults_file)
%
%   INPUTS is the struct returned by HMRI_FIND_INPUTS (paths must point to
%   uncompressed .nii files). OUT_DIR is where hMRI writes its results.
%   DEFAULTS_FILE and B1_DEFAULTS_FILE are the hMRI site/protocol defaults
%   (e.g. config/hmri_CBS_7T_defaults.m and config/hmri_b1_CBS_7T_defaults.m).
%
%   The batch has two jobs: (1) load the customised hMRI defaults,
%   (2) create the maps. RF sensitivity correction is disabled ('-'), as for
%   7T acquisitions without separate sensitivity scans.
%
%   The batch is only built, not run: pass it to spm_jobman('run', ...).

matlabbatch{1}.spm.tools.hmri.hmri_config.hmri_setdef.customised = {defaults_file};

subj.output.outdir = {out_dir};
subj.sensitivity.RF_us = '-';
subj.b1_type.i3D_AFI.b1input = spm_frames(inputs.B1);
subj.b1_type.i3D_AFI.b1parameters.b1defaults = {b1_defaults_file};
if isempty(inputs.MT)
    subj.raw_mpm.MT = '';
else
    subj.raw_mpm.MT = spm_frames(inputs.MT);
end
subj.raw_mpm.PD = spm_frames(inputs.PD);
subj.raw_mpm.T1 = spm_frames(inputs.T1);
subj.popup = false;

matlabbatch{2}.spm.tools.hmri.create_mpm.subj = subj;
end


function frames = spm_frames(files)
% SPM addresses volumes as '<file>,<frame>'; every input here is a single volume.
frames = strcat(files(:), ',1');
end
