# SIRIUS Band-Structure Setup

The SIRIUS snippets in the paper show the CP2K input sections needed for a SIRIUS-backed
band-structure calculation. A compact standalone example is not included in the runnable set
because it requires a CP2K build with SIRIUS and the corresponding math and accelerator
dependencies.

The closest CP2K regression-test reference is
[`tests/SIRIUS/regtest-1/N2.inp`](https://github.com/cp2k/cp2k/blob/master/tests/SIRIUS/regtest-1/N2.inp).

If this becomes a full example, it should state the required CP2K build features and avoid implying
that the input works with a default QUICKSTEP-only executable.
