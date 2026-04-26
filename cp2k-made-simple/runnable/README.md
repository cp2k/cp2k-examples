# Runnable CP2K Made Simple Examples

This directory contains complete CP2K inputs derived from selected snippets of the paper
["The CP2K Program Package Made Simple"](https://doi.org/10.1021/acs.jpcb.5c05851).

The raw extracted snippets remain in `../paper-snippets/`. The files here are curated examples:
they add the missing cell, coordinates, basis-set/potential choices, and method context needed for
small standalone calculations. The directory names follow the paper chapters.

## Examples

The examples are grouped by the paper chapters. Local test results are also recorded in
`manifest.tsv`, which includes the marker and reference value used by `run_smoke_tests.py`.
The tables below are generated from `manifest.tsv`; after changing the manifest, run
`python3 generate_readme.py`.

<!-- BEGIN GENERATED EXAMPLES -->
### 2. Total Energy and Force Methods

| input | topic | based on snippets | local test result | quick |
| --- | --- | --- | --- | --- |
| `02-total-energy-and-force-methods/h2o-gpw-pbe.inp` | GPW/PBE single point | 001, 002 | energy -17.212337144585153 Ha | yes |
| `02-total-energy-and-force-methods/h2o-gpw-ot.inp` | GPW/PBE with OT | 001, 005, 006 | energy -17.212337144506982 Ha | - |
| `02-total-energy-and-force-methods/h2o-gpw-smearing.inp` | GPW/PBE with diagonalization and smearing | 001, 005 | energy -17.212334309139813 Ha | - |
| `02-total-energy-and-force-methods/h2o-gapw-all-electron.inp` | all-electron GAPW/PBE | 003, 004 | energy -76.238068224190314 Ha | - |
| `02-total-energy-and-force-methods/h2o-pbe0-admm.inp` | hybrid DFT with ADMM | 010, 011, 012, 013 | energy -17.151344159601688 Ha | - |
| `02-total-energy-and-force-methods/h2o-dft-plus-u.inp` | DFT+U setup | 022, 023, 024, 025 | energy -17.180669501745012 Ha | yes |
| `02-total-energy-and-force-methods/h2o-ri-mp2.inp` | RI-MP2 correlation | 016, 017 | energy -17.170315778164436 Ha | - |

### 3. Electronic Band Structure

| input | topic | based on snippets | local test result | quick |
| --- | --- | --- | --- | --- |
| `03-electronic-band-structure/diamond-kpoints-band-structure.inp` | k-point band output | 007, 008, 030, 031 | energy -45.498947901745879 Ha | - |

### 4. Embedding Methods

| input | topic | based on snippets | local test result | quick |
| --- | --- | --- | --- | --- |
| `04-embedding-methods/h2o-sccs-solvation.inp` | SCCS implicit solvation | 032, 033, 034, 035 | energy -17.226540497029429 Ha | - |
| `04-embedding-methods/h2o-qmmm-gaussian.inp` | Gaussian electrostatic QMMM | 036, 037, 038, 039 | energy -16.860414497766239 Ha | yes |
| `04-embedding-methods/ch3oh-resp-charges.inp` | RESP charge fitting | 040, 041, 042 | energy -23.909587912298466 Ha; RESP RMS 7.55141E-05 | - |
| `04-embedding-methods/h2o-h2-dfet.inp` | density functional embedding | 043, 044, 045, 046, 047, 048, 049 | energy -18.321636385557674 Ha | - |

### 5. Magnetic Resonance

| input | topic | based on snippets | local test result | quick |
| --- | --- | --- | --- | --- |
| `05-magnetic-resonance/h2o-nmr-linear-response.inp` | NMR linear response | 050, 051, 052, 053 | shielding checksum 0.605916E+02 | yes |
| `05-magnetic-resonance/no2-epr-g-tensor.inp` | EPR g-tensor linear response | 050, 054 | EPR checksum -0.130768E-02 | - |
| `05-magnetic-resonance/h2o-hyperfine-coupling.inp` | EPR hyperfine coupling tensor | 055 | O Sca-Rel A_iso -118.2292921806 MHz; energy -75.901123242692378 Ha | - |

### 6. Optical Spectroscopy

| input | topic | based on snippets | local test result | quick |
| --- | --- | --- | --- | --- |
| `06-optical-spectroscopy/h2o-tddfpt.inp` | linear-response TDDFPT | 056 | first excitation 8.43471 eV | - |
| `06-optical-spectroscopy/h2o-stda-tddfpt.inp` | sTDA-TDDFPT | 057, 058, 059 | first excitation 7.86094 eV | yes |

### 7. Excited-State Dynamics

| input | topic | based on snippets | local test result | quick |
| --- | --- | --- | --- | --- |
| `07-excited-state-dynamics/h2o-real-time-propagation.inp` | real-time propagation | 061, 069 | final total energy -17.17816551662580 Ha | - |

### 8. X-Ray Spectroscopy

| input | topic | based on snippets | local test result | quick |
| --- | --- | --- | --- | --- |
| `08-x-ray-spectroscopy/co-xas-transition-potential.inp` | XAS transition potential | 064 | energy -92.844208496940453 Ha | - |
| `08-x-ray-spectroscopy/h2o-xastdp-gw2x.inp` | XAS_TDP with GW2X correction | 065, 066, 067 | first XAS excitation 538.170258 eV; energy -75.956287566248847 Ha | - |
| `08-x-ray-spectroscopy/h2o-real-time-gaussian-field.inp` | real-time propagation with Gaussian field | 070 | final RTP energy -17.17816621169307 Ha | yes |

### 9. Energy Decomposition Analysis

| input | topic | based on snippets | local test result | quick |
| --- | --- | --- | --- | --- |
| `09-energy-decomposition-analysis/h2o-almo-eda.inp` | ALMO energy decomposition | 071, 073 | energy -85.963743073058524 Ha | - |
| `09-energy-decomposition-analysis/lif-almo-ionic.inp` | ionic ALMO electron assignment | 072, 073 | energy -127.539319485670845 Ha | - |

### 10. Finite-Temperature Effects

| input | topic | based on snippets | local test result | quick |
| --- | --- | --- | --- | --- |
| `10-finite-temperature-effects/h2o-nnp-committee-md.inp` | committee NNP molecular dynamics | 074, 075, 076 | final energy 58.648809523054418 Ha | yes |
| `10-finite-temperature-effects/h2o-nnp-biased-md.inp` | biased committee NNP molecular dynamics | 074, 075, 076, 077 | final energy 58.661222155637667 Ha | - |
| `10-finite-temperature-effects/h2o-pint-nve.inp` | path-integral molecular dynamics | 078 | final PINT energy -17.137402749384318 Ha | - |
| `10-finite-temperature-effects/h2o-pint-nose.inp` | PINT with Nose thermostat | 078, 079 | final PINT energy -17.129535930553633 Ha | - |
| `10-finite-temperature-effects/h2o-pint-pile.inp` | PINT with PILE thermostat | 078, 080 | final PINT energy -68.549498536850606 Ha | - |
| `10-finite-temperature-effects/h2o-pint-qtb.inp` | PINT with QTB thermostat | 078, 081 | final PINT energy -68.549621077706419 Ha | - |
| `10-finite-temperature-effects/h2o-vibrational-analysis.inp` | vibrational analysis | 086 | first frequencies 0.000000 cm^-1 | - |
| `10-finite-temperature-effects/h2o-periodic-efield.inp` | periodic electric field | 087, 090 | energy -16.553933618515682 Ha | - |
| `10-finite-temperature-effects/h2o-orbital-localization.inp` | orbital localization and Wannier centers | 088 | localization converged in 26 iterations; energy -17.186709451452117 Ha | yes |
| `10-finite-temperature-effects/h2o-linear-response-polarizability.inp` | linear-response polarizability | 091 | polarizability xx/yy/zz 0.006179870499/0.958172935260/0.397344896793 ang^3 | yes |

<!-- END GENERATED EXAMPLES -->

Run from this directory, for example:

```bash
CP2K_DATA_DIR=/path/to/cp2k/data cp2k.psmp -i 02-total-energy-and-force-methods/h2o-gpw-pbe.inp -o h2o-gpw-pbe.out
```

When CP2K has been installed with a configured data directory, `CP2K_DATA_DIR` is not needed.
For reproducible quick checks, set `OMP_NUM_THREADS=1` and run each example in a separate work
directory or with a unique output file name. The inputs are small enough for serial execution, but
`cp2k.psmp` is also fine when used with a modest MPI/OpenMP layout.

To smoke-test the complete set:

```bash
python3 run_smoke_tests.py --cp2k /path/to/cp2k.psmp --data-dir /path/to/cp2k/data --jobs 1
```

To run only a representative quick subset with numeric output checks:

```bash
python3 run_smoke_tests.py --cp2k /path/to/cp2k.psmp --data-dir /path/to/cp2k/data --quick
```

Use `--jobs N` only when the machine has enough cores and memory for several independent CP2K
runs. Each input is executed in its own work directory.

The results above were checked with a local `cp2k.psmp` build using `OMP_NUM_THREADS=1`.
Snippets for SIRIUS and the larger GW/BSE, real-time XAS, Voronoi, NEWTON-X, and bosonic helium
workflows are tracked in `../optional-workflows/` because they can require optional libraries,
external data, or substantially larger production-style settings.
