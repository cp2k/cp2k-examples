# CP2K Made Simple Examples

This directory collects CP2K input material associated with the paper
["The CP2K Program Package Made Simple"](https://doi.org/10.1021/acs.jpcb.5c05851).

The directory has two parts:

- `runnable/` contains small, complete input files derived from selected paper snippets. They
  can be run directly with a CP2K binary and a standard CP2K data directory.
- `paper-snippets/` contains 91 CP2K input fragments extracted from the paper. Many of these
  fragments intentionally show only the method-specific section and contain placeholders such as
  `...`, so they are not standalone calculations.

The full list of extracted snippets is in `manifest.tsv`. The snippet numbering follows the order
of code blocks in the paper HTML source used for extraction.
The derived complete examples are listed in `runnable/manifest.tsv`.

## Running the Complete Examples

From this directory, run for example:

```bash
cp2k.psmp -i runnable/dft/h2o-gpw-pbe.inp -o h2o-gpw-pbe.out
cp2k.psmp -i runnable/gapw/h2o-gapw-all-electron.inp -o h2o-gapw-all-electron.out
```

If CP2K was built without a configured data directory, set `CP2K_DATA_DIR` to the CP2K `data`
directory before running.

The complete examples in `runnable/` are curated derived inputs. Each file header lists the
paper snippets it is based on; the raw extracted snippets remain unchanged in `paper-snippets/`.

See `runnable/README.md` for the full runnable-example table and local test results.
