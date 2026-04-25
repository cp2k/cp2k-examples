# Runnable CP2K Made Simple Examples

This directory contains complete CP2K inputs derived from selected snippets of the paper
["The CP2K Program Package Made Simple"](https://doi.org/10.1021/acs.jpcb.5c05851).

The raw extracted snippets remain in `../paper-snippets/`. The files here are curated examples:
they add the missing cell, coordinates, basis-set/potential choices, and method context needed for
small standalone calculations.

## Examples

| input | topic | based on snippets | local test result |
| --- | --- | --- | --- |
| `dft/h2o-gpw-pbe.inp` | GPW/PBE single point | 001, 002 | energy -17.212337144585153 Ha |
| `dft/h2o-gpw-ot.inp` | GPW/PBE with OT | 001, 005, 006 | energy -17.212337144506982 Ha |
| `dft/h2o-gpw-smearing.inp` | GPW/PBE with smearing | 001, 005 | energy -17.212334309139813 Ha |
| `gapw/h2o-gapw-all-electron.inp` | all-electron GAPW/PBE | 003, 004 | energy -76.238068224190314 Ha |
| `hfx-admm/h2o-pbe0-admm.inp` | hybrid DFT with ADMM | 010, 011, 012, 013 | energy -17.151344159601688 Ha |
| `properties/h2o-tddfpt.inp` | linear-response TDDFPT | 056 | first excitation 8.43471 eV |

Run from this directory, for example:

```bash
CP2K_DATA_DIR=/path/to/cp2k/data cp2k.psmp -i dft/h2o-gpw-pbe.inp -o h2o-gpw-pbe.out
```

When CP2K has been installed with a configured data directory, `CP2K_DATA_DIR` is not needed.

The results above were checked with a local `cp2k.psmp` build using `OMP_NUM_THREADS=1`.
