# hMRI defaults

Site- and protocol-specific hMRI defaults used by the examples. Put these here:

| File | Used for |
| --- | --- |
| `hmri_CBS_7T_defaults.m` | General hMRI defaults for the 7T MPM protocol at MPI CBS Leipzig |
| `hmri_b1_CBS_7T_defaults.m` | 3D-AFI B1 mapping parameters for the same protocol |

They are passed to `hmri_create_mpm` as `defaults_file` and `b1_defaults_file`.
For another scanner or protocol, start from the templates shipped with the
hMRI toolbox (`config/hmri_defaults.m`, `config/hmri_b1_defaults.m`) and
add your own files here.
