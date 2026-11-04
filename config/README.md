# hMRI defaults

Site- and protocol-specific hMRI defaults used by the examples:

| File | Used for |
| --- | --- |
| `hmri_CBS_7T_defaults.m` | General hMRI defaults for 7T MPM data from MPI CBS Leipzig (Magnetom/Terra) |
| `hmri_b1_CBS_7T_defaults.m` | B1 mapping defaults for the same scanners |

They are passed to `hmri_create_mpm` as `defaults_file` and `b1_defaults_file`.
For another scanner or protocol, start from the templates shipped with the
hMRI toolbox (`config/local/hmri_local_defaults.m`,
`config/hmri_b1_standard_defaults.m`) and add your own files here.

## License

The files in this folder are modified copies of defaults files from the
[hMRI toolbox](https://github.com/hMRI-group/hMRI-toolbox) and are therefore
licensed under the **GNU General Public License v2.0**, like the hMRI toolbox
itself. The rest of this repository is MIT-licensed (see [LICENSE](../LICENSE)).
