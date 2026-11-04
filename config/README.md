# hMRI defaults

Put your hMRI defaults files in this folder. `hmri_create_mpm` needs two:

| File | Contains |
| --- | --- |
| general defaults, e.g. `hmri_MYSITE_defaults.m` | Settings for map creation, including the MPM acquisition parameters of your protocol |
| B1 defaults, e.g. `hmri_b1_MYSITE_defaults.m` | Settings for the B1 map, including the 3D-AFI TR ratio and flip angle |

They are passed to `hmri_create_mpm` as `defaults_file` and `b1_defaults_file`.

These files are specific to a scanner and protocol, so they are not part of
this repository, and git ignores `.m` files in this folder. The files for
the 7T MPM protocol at MPI CBS Leipzig are available from the author on
request. To make your own, start from the templates shipped with the hMRI
toolbox (`config/local/hmri_local_defaults.m` and
`config/hmri_b1_standard_defaults.m` in the hMRI folder).
