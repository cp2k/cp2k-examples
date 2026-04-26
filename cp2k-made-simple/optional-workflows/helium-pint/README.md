# Bosonic Helium PINT Workflows

The bosonic quantum-solvation snippets in the paper point beyond the compact water PINT examples in
`../../runnable/10-finite-temperature-effects/`. They require a more specialized low-temperature
helium setup and are therefore not part of the small runnable smoke-test set.

Useful CP2K regression-test references are:

- [`tests/Pimd/regtest-2/water_in_helium_nnp.inp`](https://github.com/cp2k/cp2k/blob/master/tests/Pimd/regtest-2/water_in_helium_nnp.inp)
- [`tests/Pimd/regtest-1/he32_only.inp`](https://github.com/cp2k/cp2k/blob/master/tests/Pimd/regtest-1/he32_only.inp)

A future standalone example should explain the helium model, the NNP data assumptions, and the
temperature/path-integral settings rather than just wrapping the snippets in a minimal input.
