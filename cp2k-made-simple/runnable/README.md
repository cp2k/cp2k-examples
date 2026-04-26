# Runnable CP2K Made Simple Examples

This directory contains complete CP2K inputs derived from selected snippets of the paper
["The CP2K Program Package Made Simple"](https://doi.org/10.1021/acs.jpcb.5c05851).

The raw extracted snippets remain in `../paper-snippets/`. The files here are curated examples:
they add the missing cell, coordinates, basis-set/potential choices, and method context needed for
small standalone calculations. The directory names follow the paper chapters.

## Examples

| input | topic | based on snippets | local test result |
| --- | --- | --- | --- |
| `02-total-energy-and-force-methods/h2o-gpw-pbe.inp` | GPW/PBE single point | 001, 002 | energy -17.212337144585153 Ha |
| `02-total-energy-and-force-methods/h2o-gpw-ot.inp` | GPW/PBE with OT | 001, 005, 006 | energy -17.212337144506982 Ha |
| `02-total-energy-and-force-methods/h2o-gpw-smearing.inp` | GPW/PBE with smearing | 001, 005 | energy -17.212334309139813 Ha |
| `02-total-energy-and-force-methods/h2o-gapw-all-electron.inp` | all-electron GAPW/PBE | 003, 004 | energy -76.238068224190314 Ha |
| `02-total-energy-and-force-methods/h2o-pbe0-admm.inp` | hybrid DFT with ADMM | 010, 011, 012, 013 | energy -17.151344159601688 Ha |
| `02-total-energy-and-force-methods/h2o-dft-plus-u.inp` | DFT+U setup | 022, 023, 024, 025 | energy -17.180669501745012 Ha |
| `02-total-energy-and-force-methods/h2o-ri-mp2.inp` | RI-MP2 correlation | 016, 017 | energy -17.170315778164436 Ha |
| `03-electronic-band-structure/diamond-kpoints-band-structure.inp` | k-point band output | 007, 008, 030, 031 | energy -45.498947901745879 Ha |
| `04-embedding-methods/h2o-sccs-solvation.inp` | SCCS implicit solvation | 032, 033, 034, 035 | energy -17.226540497029429 Ha |
| `04-embedding-methods/h2o-qmmm-gaussian.inp` | Gaussian electrostatic QMMM | 036, 037, 038, 039 | energy -16.860414497766239 Ha |
| `04-embedding-methods/ch3oh-resp-charges.inp` | RESP charge fitting | 040, 041, 042 | energy -23.909587912298466 Ha; RESP RMS 7.55141E-05 |
| `05-magnetic-resonance/h2o-nmr-linear-response.inp` | NMR linear response | 050, 051, 052, 053 | shielding checksum 0.605916E+02 |
| `05-magnetic-resonance/no2-epr-g-tensor.inp` | EPR g-tensor linear response | 050, 054 | EPR checksum -0.130768E-02 |
| `06-optical-spectroscopy/h2o-tddfpt.inp` | linear-response TDDFPT | 056 | first excitation 8.43471 eV |
| `06-optical-spectroscopy/h2o-stda-tddfpt.inp` | sTDA-TDDFPT | 057, 058, 059 | first excitation 7.86094 eV |
| `07-excited-state-dynamics/h2o-real-time-propagation.inp` | real-time propagation | 061, 069 | final total energy -17.17816551662580 Ha |
| `08-x-ray-spectroscopy/co-xas-transition-potential.inp` | XAS transition potential | 064 | energy -92.844208496940453 Ha |
| `09-energy-decomposition-analysis/h2o-almo-eda.inp` | ALMO energy decomposition | 071, 073 | energy -85.963743073058524 Ha |
| `09-energy-decomposition-analysis/lif-almo-ionic.inp` | ionic ALMO electron assignment | 072, 073 | energy -127.539319485670845 Ha |
| `10-finite-temperature-effects/h2o-nnp-committee-md.inp` | committee NNP molecular dynamics | 074, 075, 076 | final energy 58.648809523054418 Ha |
| `10-finite-temperature-effects/h2o-pint-nve.inp` | path-integral molecular dynamics | 078 | final PINT energy -17.137402749384318 Ha |
| `10-finite-temperature-effects/h2o-vibrational-analysis.inp` | vibrational analysis | 086 | first frequencies 0.000000 cm^-1 |

Run from this directory, for example:

```bash
CP2K_DATA_DIR=/path/to/cp2k/data cp2k.psmp -i 02-total-energy-and-force-methods/h2o-gpw-pbe.inp -o h2o-gpw-pbe.out
```

When CP2K has been installed with a configured data directory, `CP2K_DATA_DIR` is not needed.

The results above were checked with a local `cp2k.psmp` build using `OMP_NUM_THREADS=1`.
Snippets for SIRIUS and the larger GW/BSE workflows remain in `../paper-snippets/` because they
can require optional libraries, external data, or substantially larger production-style settings.
