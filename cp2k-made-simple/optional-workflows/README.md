# Optional CP2K Made Simple Workflows

Some snippets from the paper are better kept as fragments or larger workflows rather than compact
smoke-test inputs. The table records good candidates for future examples and the main reason they
were not folded into the small runnable set.

| topic | snippets | dependency or size note | possible follow-up |
| --- | --- | --- | --- |
| SIRIUS band-structure setup | 026, 027 | requires a CP2K build with SIRIUS and its accelerator/math stack | add a minimal SIRIUS input with an explicit build-requirements note |
| Molecular GW | 028 | methodologically heavier than the water smoke tests | connect to the existing `../../gw/1_H2O_GW100/` example |
| Periodic GW with k-points | 030, 031 | larger convergence space and more expensive settings | add a reduced companion to the existing GW examples if reviewers want one here |
| BSE optical absorption | 060 | depends on a preceding GW-style setup and produces larger spectra | document as a staged workflow rather than a single smoke-test input |
| Surface hopping with NEWTON-X | 062, 063 | needs an external trajectory driver workflow | keep as a method fragment unless a full external-workflow example is added |
| Bosonic quantum solvation | 083, 084, 085 | specialized helium/low-temperature setup, less compact than the water PINT cases | consider a separate advanced finite-temperature example |

The current runnable set favors examples that complete quickly with a standard CP2K data directory.
This optional list is a parking place for examples that are scientifically useful but need clearer
build, data, or workflow assumptions before becoming small standalone inputs.
