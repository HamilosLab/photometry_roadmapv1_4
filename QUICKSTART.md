# Quickstart

## 1. Set up the MATLAB path

```matlab
addpath(genpath('src'))
```

That's the entire setup — all 18 files in `src/` are flat siblings, no subfolders or package structure to worry about.

## 2. Get sample data (optional, for trying the workflow below)

```bash
cd data
./fetch_sample_data.sh   # requires `pip install gdown`; needs the real Drive link filled in — see note in the script
```

This downloads 5 sample files (~151 MB) into `data/sample/`: a VTAred photometry recording (day 10 and day 11) and an EMG recording (day 10), each with a matching pre-computed `gfit` file, from mouse "H6".

## 3. Constructing an `sObj` — the real, interactive workflow

**Important:** the standard construction path (`'v3x'` mode) is driven by MATLAB GUI dialogs. There is no headless/scripted equivalent — this is a limitation of the original codebase, not something this extraction changes. You need a MATLAB session with a display.

The call, as used elsewhere in the original pipeline:

```matlab
obj = CLASS_photometry_roadmapv1_4('v3x', 'times', 17, {'multibaseline', 10}, 30000, [], [], 'off');
```

What happens, step by step:

1. A `msgbox` appears with instructions — click OK / press Enter.
2. A `listdlg` ("Select data type(s) to include...") lists signal names: `SNc, DLS, VTA, DLSright, DLSleftD, SNcred, VTAred, DLSred, EMG, X, Y, Z, CamO, SNcnovir, VTAnovir, SNcgreen, VTAgreen, DLSgreen, NAc, NAcred, none, VLS, VLSred, red, ChR2`. To use the sample data, select **`VTAred`** (single selection → treated as a photometry signal).
3. A `uigetdir` ("Select host folder") prompt appears. This must point to a folder containing **one subfolder per session** — not a flat folder of files. So before running the above, reorganize the sample data like this:
   ```
   my_host_folder/
     H6_day10/
       VTAred_H6_day10_header1_roadmapv1_4_12_13_17.mat
       VTAred_gfit_H6_day10_header1_roadmapv1_4_12_13_17.mat
   ```
   (Repeat with a second subfolder for `H6_day11` if you want a multi-session example — note that file only has the raw data, no matching gfit file bundled.)
4. For each subfolder, the class checks for an existing `sObj`/`statObj`/`REVISED`-named file first; failing that, it looks for a `gfit`-named file in the subfolder and a "gfit style" match; depending on what it finds, it may prompt further `uigetfile` dialogs (e.g. "Select the gfit structure to use").
5. Once done, `obj` is a fully-populated `CLASS_photometry_roadmapv1_4` instance — see the field table in `README.md` for what to inspect first (`obj.iv.num_trials`, `obj.GLM.cue_s`, `obj.GLM.flick_s_wrtc`, ...).

Other constructor modes you'll see referenced in the class header comments:
- `CLASS_photometry_roadmapv1_4('empty')` — returns an uninitialized object (useful for calling static-ish helper methods without a full construction).
- `CLASS_photometry_roadmapv1_4('stimNphot', 'times', 1, {gfitStyle}, timePad, [], [], stimMode)` — for combined stimulation + photometry objects; also interactive.

## 4. Non-interactive / programmatic construction (advanced, not demoed here)

There is a third, non-interactive constructor branch — call with anything other than `'empty'`, `'3.x'`/`'v3x'`, or `'stimNphot'` as the first argument, and pass a pre-built `data` struct directly:

```matlab
obj = CLASS_photometry_roadmapv1_4(data, Mode, nbins, gfit, gtimes, xRaw, xTimes);
```

This path has no GUI dialogs, but `data` must already have the shape the class expects:
- `data.init_variables.time_parameters...` (sample rates, event positions, CTA/LTA time arrays — see `getPlot` in the class file for the exact fields read)
- `data.lick_data_struct` (`all_ex_first_licks`, `f_ex_lick_rxn`, `f_ex_lick_operant_no_rew`, `f_ex_lick_operant_rew`, `f_ex_lick_ITI`, ...)
- `data.exclusions_struct`

The sample `.mat` files bundled here do **not** match this shape out of the box (their top-level fields are `init_variables`, `gfit_signal`, `signal_values_by_trial`, ... — a different, flatter schema). Building an adapter to bridge that gap was out of scope for this extraction; if you need a fully scripted/headless construction path, you'll need to either write that adapter yourself against the field list above, or use the interactive `'v3x'` path in section 3.

## Troubleshooting

- **"Undefined function" errors**: confirm `addpath(genpath('src'))` ran in the current MATLAB session.
- **Path-separator errors on Linux/Mac** (e.g. a load/save call failing on a literal `\`): this is a known Windows-path assumption in a few places in the original code — see `README.md`.
