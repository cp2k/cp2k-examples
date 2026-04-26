# Optional CP2K Made Simple Workflows

Some snippets from the paper are better kept as fragments or larger workflows rather than compact
smoke-test inputs. The table records good candidates for future examples and the main reason they
were not folded into the small runnable set.

| topic | snippets | related material | dependency or size note | possible follow-up |
| --- | --- | --- | --- | --- |
| SIRIUS band-structure setup | 026, 027 | [`tests/SIRIUS/regtest-1/N2.inp`](https://github.com/cp2k/cp2k/blob/master/tests/SIRIUS/regtest-1/N2.inp) | requires a CP2K build with SIRIUS and its math/accelerator dependencies | add a minimal SIRIUS input with an explicit build-requirements note |
| Molecular GW | 028 | `../../gw/1_H2O_GW100/H2O_GW100_def2-QZVP.inp` | heavier than the water smoke tests and needs convergence choices that are method-specific | add a short bridge note from the paper snippet to the existing GW example |
| Periodic GW with k-points | 030, 031 | `../../gw/3_3-atom_unit_cell_2d_WSe2_loose_parameters/GW.inp` | larger convergence space and more expensive settings | add a reduced companion only if reviewers want one in this folder |
| BSE optical absorption | 060 | `../../rtbse/Ethene/rtbse.inp` | depends on a preceding excited-state setup and produces larger spectra | document as a staged workflow rather than a single smoke-test input |
| Real-time XAS propagation | 070 | `../../rtp_field_xas/tutorial_rtp.ipynb` and `../../rtp_field_xas/Data/RTP.inp` | the full workflow uses precomputed XAS_TDP states and a custom basis file | keep the small Gaussian-field input runnable and point advanced users to the full tutorial |
| Voronoi integration | 089 | `../paper-snippets/089-10-finite-temperature-effects-dft.inp` | useful output requires CP2K compiled with `__LIBVORI`; otherwise the `.voronoi` file is empty | keep as optional unless a LIBVORI-enabled smoke test is available |
| Surface hopping with NEWTON-X | 062, 063 | [`tests/QS/regtest-gpw-9/h2o_NEWTONX.inp`](https://github.com/cp2k/cp2k/blob/master/tests/QS/regtest-gpw-9/h2o_NEWTONX.inp) | needs an external trajectory driver workflow | keep as a method fragment unless a full external-workflow example is added |
| Bosonic quantum solvation | 083, 084, 085 | [`tests/Pimd/regtest-2/water_in_helium_nnp.inp`](https://github.com/cp2k/cp2k/blob/master/tests/Pimd/regtest-2/water_in_helium_nnp.inp) and [`tests/Pimd/regtest-1/he32_only.inp`](https://github.com/cp2k/cp2k/blob/master/tests/Pimd/regtest-1/he32_only.inp) | specialized helium/low-temperature setup, less compact than the water PINT cases | consider a separate advanced finite-temperature example |

The current runnable set favors examples that complete quickly with a standard CP2K data directory.
This optional list is a parking place for examples that are scientifically useful but need clearer
build, data, or workflow assumptions before becoming small standalone inputs.
