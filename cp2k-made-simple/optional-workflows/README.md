# Optional CP2K Made Simple Workflows

Some snippets from the paper are better kept as fragments, larger workflows, or dependency-aware
notes rather than compact smoke-test inputs. The table records good candidates for future examples
and the main reason they were not folded into the small runnable set.

| topic | snippets | details | dependency or size note | possible follow-up |
| --- | --- | --- | --- | --- |
| SIRIUS band-structure setup | 026, 027 | [`sirius/`](sirius/) | requires a CP2K build with SIRIUS and its math/accelerator dependencies | add a minimal SIRIUS input with an explicit build-requirements note |
| GW and BSE workflows | 028, 030, 031, 060 | [`gw-bse/`](gw-bse/) | heavier than the water smoke tests and needs convergence choices that are method-specific | keep bridges to existing examples unless a reduced teaching input is requested |
| Real-time XAS propagation | 070 | [`real-time-xas/`](real-time-xas/) | the full workflow uses precomputed XAS_TDP states and a custom basis file | keep the small Gaussian-field input runnable and point advanced users to the full tutorial |
| Voronoi integration | 089 | [`voronoi/`](voronoi/) | useful output requires CP2K compiled with `__LIBVORI`; otherwise the `.voronoi` file is empty | keep as optional unless a LIBVORI-enabled smoke test is available |
| Surface hopping with NEWTON-X | 062, 063 | [`newton-x/`](newton-x/) | needs an external trajectory driver workflow | keep as a method fragment unless a full external-workflow example is added |
| Bosonic quantum solvation | 083, 084, 085 | [`helium-pint/`](helium-pint/) | specialized helium/low-temperature setup, less compact than the water PINT cases | consider a separate advanced finite-temperature example |

The current runnable set favors examples that complete quickly with a standard CP2K data directory.
This optional list is a parking place for examples that are scientifically useful but need clearer
build, data, or workflow assumptions before becoming small standalone inputs.
