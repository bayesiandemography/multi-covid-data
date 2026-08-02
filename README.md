# multi-covid-data

Pipeline for assembling multi-country COVID-era mortality data from HMD, STMF, and WPP.

<!-- TODO: overview, setup, how to build, data sources, output schema -->

## Large files (Git LFS)

Archives under `data/` (HMD, STMF, and WPP inputs) are stored with
[Git LFS](https://git-lfs.com/). A normal `git clone` with Git LFS installed
downloads them automatically (currently about **170 MB** total). To clone the
code without those payloads:

```bash
GIT_LFS_SKIP_SMUDGE=1 git clone https://github.com/bayesiandemography/multi-covid-data.git
```

Then fetch the data later with `git lfs pull` if needed. Without Git LFS, those
paths appear as small pointer files rather than the real archives.


## Country maps

HMD and STMF use different PopName / PopCode sets for some countries (Germany,
France, UK, New Zealand), so each has its own concordance and filtered map.
Targets should use the same study codes (typically ISO3). WPP is not filtered
by country; figures align via left-join to HMD.

| file | role |
|------|------|
| `data/hmd/countries.csv` | HMD PopName → study code (hand-edited) |
| `data/stmf/countries.csv` | STMF PopCode → study code (hand-edited) |
| `out/hmd/countries.rds` | Filtered HMD source → target map |
| `out/stmf/countries.rds` | Filtered STMF source → target map |

`src/hmd/countries.R` applies `data/hmd/countries.csv` and `YEAR_REQUIRED_HMD`,
and writes `out/hmd/countries.rds`. HMD deaths / population / lifeexp use that map
only.

`src/stmf/countries.R` applies `data/stmf/countries.csv` and keeps sources with
week coverage through `WEEK_REQUIRED_STMF` of `YEAR_REQUIRED_STMF`, writing
`out/stmf/countries.rds`. STMF deaths use that map only (plus a year window).

### Columns (`countries.csv`)

| column   | meaning                                      |
|----------|----------------------------------------------|
| `source` | Source PopName / PopCode (must be unique)    |
| `target` | Study country code after keep / rename / merge |

### Interpretation

- **Keep** — `target` equals `source` (e.g. `AUS`,`AUS`).
- **Rename** — `target` is a different non-empty code (e.g. `FRATNP`,`FRA`).
- **Merge** — two or more rows share the same non-empty `target` (e.g. HMD `DEUTE` and `DEUTW` both → `DEU`).
- **Drop** — `target` is empty (blank cell). That source is excluded.

Only rows with a non-empty `target` are kept. For HMD, targets whose last
observed year in deaths is before `YEAR_REQUIRED_HMD` are also dropped. For
STMF, sources lacking the required week in the required year are dropped.
