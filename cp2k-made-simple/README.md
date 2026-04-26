# CP2K Made Simple Examples

This directory collects CP2K input material associated with the paper
["The CP2K Program Package Made Simple"](https://doi.org/10.1021/acs.jpcb.5c05851).

The directory has four parts:

- `runnable/` contains small, complete input files derived from selected paper snippets. They
  can be run directly with a CP2K binary and a standard CP2K data directory. The inputs are
  grouped by the corresponding paper chapters.
- `paper-snippets/` contains 91 CP2K input fragments extracted from the paper. Many of these
  fragments intentionally show only the method-specific section and contain placeholders such as
  `...`, so they are not standalone calculations.
- `guided-workflows/` groups runnable inputs into short learning paths.
- `optional-workflows/` records larger, dependency-sensitive, or multi-stage workflows that are
  better documented separately from the compact smoke-test inputs.

The full list of extracted snippets is in `manifest.tsv`. The snippet numbering follows the order
of code blocks in the paper HTML source used for extraction.
The derived complete examples are listed in `runnable/manifest.tsv`.

## Running the Complete Examples

From this directory, run for example:

```bash
export OMP_NUM_THREADS=1
cp2k.psmp -i runnable/02-total-energy-and-force-methods/h2o-gpw-pbe.inp -o h2o-gpw-pbe.out
cp2k.psmp -i runnable/09-energy-decomposition-analysis/h2o-almo-eda.inp -o h2o-almo-eda.out
```

If CP2K was built without a configured data directory, set `CP2K_DATA_DIR` to the CP2K `data`
directory before running. For quick local checks, prefer a single OpenMP thread and a separate
work directory or output file for each calculation. The runnable examples are intentionally small;
larger GW, BSE, SIRIUS, real-time XAS, and LIBVORI-dependent workflows are tracked separately in
`optional-workflows/`.

The complete examples in `runnable/` are curated derived inputs. Each file header lists the
paper snippets it is based on; the raw extracted snippets remain unchanged in `paper-snippets/`.

For a quick local smoke test of representative inputs:

```bash
python3 runnable/run_smoke_tests.py --cp2k /path/to/cp2k.psmp --data-dir /path/to/cp2k/data --quick
```

See `runnable/README.md` for the full runnable-example table and local test results.
That table is generated from `runnable/manifest.tsv` with `runnable/generate_readme.py`.
The `guided-workflows/` directory groups runnable examples into short learning paths, while
`optional-workflows/` records larger or dependency-sensitive candidates for future examples.
