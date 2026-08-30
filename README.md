# photometry_roadmapv1_4

A minimal, standalone extraction of `CLASS_photometry_roadmapv1_4` — a MATLAB `handle` class used to build photometry/behavior session objects (commonly referred to as `sObj` or `statObj` in downstream code) from raw or pre-processed recording data.

This repo contains only the class and its actual runtime dependencies, pulled out of a much larger (~370-file) analysis pipeline (`Roadmap 1.4 Split By Signals`) via `matlab.codetools.requiredFilesAndProducts` — see `tools/generate_dependency_list.m` to reproduce the analysis.

## What is `sObj`?

An `sObj` (also seen named `statObj`) is an instance of `CLASS_photometry_roadmapv1_4`. It represents one (or a combined set of) recording session(s): cue/lick timestamps, a photometry or EMG/movement signal binned relative to behavioral events, and derived summary statistics (CTA/LTA-style trial-triggered averages).

Fields commonly relied on by downstream code:

| Field | Meaning |
|---|---|
| `sObj.iv.num_trials` | trial count for the session |
| `sObj.GLM.cue_s` | per-trial cue-onset timestamps (seconds) |
| `sObj.GLM.flick_s_wrtc` | per-trial first-lick time relative to cue |
| `sObj.GLM.gfit` | the fitted/processed signal (per the chosen `gfit` style) |
| `sObj.ts.BinParams.trials_in_each_bin` | trial indices grouped into bins |
| `sObj.iv.sessionCode` / `getSeshName(sObj)` | session identifier, for labeling |

## Repo layout

```
src/                          the class + its 18 required sibling .m files (flat, no subfolders needed)
data/sample/                  sample raw data (not committed — see data/fetch_sample_data.sh)
data/fetch_sample_data.sh     gdown-based fetch script for the sample data
tools/generate_dependency_list.m   reproduces the requiredFilesAndProducts analysis
QUICKSTART.md                usage guide
```

## Requirements

- MATLAB (tested with R2024a)
- **Statistics and Machine Learning Toolbox** (heavily used: `glmfit`, `anova1`/`anovan`, `pca`, `corrcoef`)
- **Signal Processing Toolbox** (`lowpass` — used in accelerometer/movement signal processing; note that `matlab.codetools.requiredFilesAndProducts` itself failed to flag this dependency, so it was confirmed manually)
- **Image Processing Toolbox** — flagged by `requiredFilesAndProducts`, but no Image Processing–specific function call could be confirmed by manual inspection; may be a false positive, listed here to be safe

## Known limitations (inherited from the original codebase, not fixed here)

- **The primary construction path (`'v3x'` mode) is interactive**, driven by MATLAB GUI dialogs (`msgbox`, `listdlg`, `uigetdir`, `uigetfile`) with no scripted/headless bypass. See `QUICKSTART.md` for the walkthrough.
- Some file-path handling uses hardcoded Windows-style backslash concatenation (e.g. `[path, file]`, `[folder, '\', name]`), which can misbehave on Linux/Mac.
- The class contains ~135 uses of `eval()` for dynamic struct-field access (a legacy idiom, not a hidden file dependency — confirmed none of these dynamically invoke additional `.m` files).

## Provenance

This class was used to process the dataset published alongside:

> Hamilos, A. E., Spedicato, G., Hong, Y., & Assad, J. A. (2020). *Original single session datasets from "Slowly evolving dopaminergic activity modulates the moment-to-moment probability of reward-related self-timed movements."* Zenodo. https://doi.org/10.5281/zenodo.4062749
