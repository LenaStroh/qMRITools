# qMRITools

[![tests](https://github.com/LenaStroh/qMRITools/actions/workflows/tests.yml/badge.svg)](https://github.com/LenaStroh/qMRITools/actions/workflows/tests.yml)

Tools for quantitative and high-resolution structural MRI that read from and
write to [BIDS](https://bids.neuroimaging.io) datasets.
## Available tools

| Tool | What it does |
| --- | --- |
| [`hmri_create_mpm`](matlab/hmri/hmri_create_mpm.m) | Creates R1, R2\*, PD and MTsat maps from multi-parameter mapping (MPM) data with the [hMRI toolbox](https://hmri-group.github.io/hMRI-toolbox/), using 3D-AFI B1 maps. Set up for the 7T MPM protocol at MPI CBS Leipzig. |

## Requirements

- MATLAB
- [SPM12](https://www.fil.ion.ucl.ac.uk/spm/software/spm12/) with the
  [hMRI toolbox](https://github.com/hMRI-group/hMRI-toolbox) installed in `spm12/toolbox/`

### hMRI version

The 7T results (including Stroh et al., *Science Advances*, 2026) were
produced with the **MPI CBS fork of the hMRI toolbox** (`hMRI-cbs`), version
`v0.2.4-335-geec6213`. With the public hMRI toolbox the code runs untested,
and results may differ from the published ones. `hmri_create_mpm` records 
the hMRI version it ran with in `derivatives/hMRI/dataset_description.json`.

## Installation

```bash
git clone https://github.com/LenaStroh/qMRITools.git
```

In MATLAB, add SPM12 and this repository to the path:

```matlab
addpath('/path/to/spm12');
addpath(genpath('/path/to/qMRITools/matlab'));
```

## Usage

### hMRI maps from 7T MPM data

The input must be a BIDS dataset that uses the qMRI naming for MPMs.
Magnitude images go in `anat/` and the two 3D-AFI B1 images in `fmap/`:

```
bids/
└── sub-01/ses-01/
    ├── anat/
    │   ├── sub-01_ses-01_acq-PDw_echo-1_flip-1_mt-off_part-mag_MPM.nii(.gz)
    │   ├── ...                                   (all PDw echoes)
    │   ├── sub-01_ses-01_acq-T1w_echo-1_flip-2_mt-off_part-mag_MPM.nii(.gz)
    │   └── ...                                   (all T1w echoes; MTw is optional)
    └── fmap/
        ├── sub-01_ses-01_acq-tr1_TB1AFI.nii(.gz)
        └── sub-01_ses-01_acq-tr2_TB1AFI.nii(.gz)
```

```matlab
hmri_create_mpm('/path/to/bids', 'sub-01', 'ses-01', ...
    'config/hmri_CBS_7T_defaults.m', 'config/hmri_b1_CBS_7T_defaults.m');
```

The maps are written to `bids/derivatives/hMRI/sub-01/ses-01/`. To write them
somewhere else, pass `'OutputDir', '/other/path'`. A BIDS
`dataset_description.json` is created in the derivatives folder. The raw
dataset is not modified: gzipped inputs are decompressed into a temporary
folder that is deleted afterwards.

To process several subjects, see [examples/run_hmri_7T.m](examples/run_hmri_7T.m).
The protocol-specific hMRI defaults are described in [config/](config/README.md).

## Repository layout

```
matlab/      MATLAB code, one folder per tool (add matlab/ to the path)
config/      protocol-specific settings used by the tools
examples/    runnable example scripts
tests/       unit tests (no SPM or real data needed)
```

## Running the tests

From the repository root in MATLAB:

```matlab
results = runtests('tests')
```

The tests also run automatically on GitHub for every push and pull request.

## Citation

If you use this code, please cite it (see [CITATION.cff](CITATION.cff)) and
the hMRI toolbox:

> Tabelow K, Balteau E, Ashburner J, et al. hMRI – A toolbox for quantitative
> MRI in neuroscience and clinical research. *NeuroImage* 194 (2019) 191–210.

## License

[MIT](LICENSE)
