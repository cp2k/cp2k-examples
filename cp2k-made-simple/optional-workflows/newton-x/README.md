# NEWTON-X Surface-Hopping Workflow

The surface-hopping snippets in the paper are method fragments for a coupled CP2K/NEWTON-X
workflow. A self-contained CP2K input is not enough to demonstrate the complete calculation because
the trajectory driver and file exchange are external to a normal single CP2K run.

The closest CP2K-side regression-test reference is
[`tests/QS/regtest-gpw-9/h2o_NEWTONX.inp`](https://github.com/cp2k/cp2k/blob/master/tests/QS/regtest-gpw-9/h2o_NEWTONX.inp).

This is a good candidate for a workflow document if a future example can include the external
driver steps and expected file handoff explicitly.
