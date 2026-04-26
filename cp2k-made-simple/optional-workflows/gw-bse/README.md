# GW and BSE Workflows

The CP2K Made Simple snippets for molecular GW, periodic GW, and BSE are useful pointers, but the
scientific workflow is less compact than a single small smoke-test input. These methods usually
need basis-set, empty-state, grid, and spectrum-convergence choices that should be made deliberately.

Related complete examples already exist in this repository:

- Molecular GW: [`gw/1_H2O_GW100/H2O_GW100_def2-QZVP.inp`](../../../gw/1_H2O_GW100/H2O_GW100_def2-QZVP.inp)
- Periodic GW: [`gw/3_3-atom_unit_cell_2d_WSe2_loose_parameters/GW.inp`](../../../gw/3_3-atom_unit_cell_2d_WSe2_loose_parameters/GW.inp)
- BSE optical absorption: [`rtbse/Ethene/rtbse.inp`](../../../rtbse/Ethene/rtbse.inp)

For this folder, these are better kept as workflow bridges rather than duplicated toy inputs.
Adding reduced teaching inputs would be valuable, but only with explicit convergence notes.
