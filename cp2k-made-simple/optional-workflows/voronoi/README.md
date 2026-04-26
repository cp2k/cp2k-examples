# Voronoi Integration

The Voronoi snippet is useful, but it depends on CP2K being compiled with LIBVORI support. With a
build that lacks `__LIBVORI`, CP2K can still complete the calculation while the `.voronoi` output
is empty, which makes it a poor default smoke test.

Related material:

- Paper snippet: [`paper-snippets/089-10-finite-temperature-effects-dft.inp`](../../paper-snippets/089-10-finite-temperature-effects-dft.inp)
- Nearby runnable inputs: [`h2o-periodic-efield.inp`](../../runnable/10-finite-temperature-effects/h2o-periodic-efield.inp) and [`h2o-linear-response-polarizability.inp`](../../runnable/10-finite-temperature-effects/h2o-linear-response-polarizability.inp)

A future runnable Voronoi input should either require a LIBVORI-enabled CP2K build explicitly or
include a test that verifies non-empty Voronoi output.
