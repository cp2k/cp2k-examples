# CP2K Made Simple Guided Workflows

The runnable inputs are intentionally small, but they can be combined into short learning paths.
Each path below starts from an input that should run quickly, then moves toward a more specialized
calculation.

## Quickstep Ground State

1. `../runnable/02-total-energy-and-force-methods/h2o-gpw-pbe.inp`
2. `../runnable/02-total-energy-and-force-methods/h2o-gpw-ot.inp`
3. `../runnable/02-total-energy-and-force-methods/h2o-gapw-all-electron.inp`
4. `../runnable/02-total-energy-and-force-methods/h2o-pbe0-admm.inp`
5. `../runnable/02-total-energy-and-force-methods/h2o-ri-mp2.inp`

This path compares the basic GPW setup with OT minimization, all-electron GAPW, hybrid DFT with
ADMM, and a compact RI-MP2 calculation.

## Embedding and Fragment Workflows

1. `../runnable/04-embedding-methods/h2o-sccs-solvation.inp`
2. `../runnable/04-embedding-methods/h2o-qmmm-gaussian.inp`
3. `../runnable/04-embedding-methods/ch3oh-resp-charges.inp`
4. `../runnable/04-embedding-methods/h2o-h2-dfet.inp`
5. `../runnable/09-energy-decomposition-analysis/h2o-almo-eda.inp`

This path collects implicit solvation, QMMM electrostatic embedding, RESP charge fitting, DFET,
and ALMO energy decomposition.

## Spectroscopy and Response

1. `../runnable/06-optical-spectroscopy/h2o-tddfpt.inp`
2. `../runnable/06-optical-spectroscopy/h2o-stda-tddfpt.inp`
3. `../runnable/08-x-ray-spectroscopy/co-xas-transition-potential.inp`
4. `../runnable/08-x-ray-spectroscopy/h2o-xastdp-gw2x.inp`
5. `../runnable/08-x-ray-spectroscopy/h2o-real-time-gaussian-field.inp`
6. `../runnable/10-finite-temperature-effects/h2o-linear-response-polarizability.inp`

This path walks through optical TDDFPT, sTDA, transition-potential XAS, XAS_TDP with GW2X, and a
short real-time Gaussian-field propagation before a small linear-response polarizability
calculation.

## Magnetic Response

1. `../runnable/05-magnetic-resonance/h2o-nmr-linear-response.inp`
2. `../runnable/05-magnetic-resonance/no2-epr-g-tensor.inp`
3. `../runnable/05-magnetic-resonance/h2o-hyperfine-coupling.inp`

This path covers NMR shielding, the EPR g-tensor, and EPR hyperfine coupling tensors.

## Finite-Temperature Methods

1. `../runnable/10-finite-temperature-effects/h2o-nnp-committee-md.inp`
2. `../runnable/10-finite-temperature-effects/h2o-nnp-biased-md.inp`
3. `../runnable/10-finite-temperature-effects/h2o-pint-nve.inp`
4. `../runnable/10-finite-temperature-effects/h2o-pint-pile.inp`
5. `../runnable/10-finite-temperature-effects/h2o-vibrational-analysis.inp`
6. `../runnable/10-finite-temperature-effects/h2o-periodic-efield.inp`
7. `../runnable/10-finite-temperature-effects/h2o-orbital-localization.inp`

This path covers committee neural-network potentials, a biased NNP trajectory, path-integral MD,
a static vibrational analysis, a periodic electric field, and orbital localization.
