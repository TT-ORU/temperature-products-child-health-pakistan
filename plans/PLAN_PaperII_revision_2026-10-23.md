# Paper II revision: CHIRTS land-masked rerun (23 October 2026)

## Purpose

Review of manuscript v1.1, point 4: replace the CHIRTS extraction that let invalid coastal pixels into
the district means, and re-run the finalisation (f) and addendum 3 (g) analyses on the corrected data.
Review points 1 (mortality sample) and 5 (variance decomposition) are covered by r1 and r2 below.

## What changes

Only the CHIRTS input. District-month Tmax is rebuilt from
Pakistan_urbanization/data_raw/climate/chirts_daily_temperature_landmask/, extracted with
chirts_daily_landmask_v2_GEE.js (each band masked to physically plausible values before the district
means, which removes fill and ocean pixels). Models, covariates, weights, fixed effects, sample rules
and the coastal exclusion rule are unchanged. finalisation_2026-10-22 and presubmission_2026-10-22 stay
frozen and are only read; their outputs are the reference.

Patched copies (first line of each file states the change): f0 (input folder; output to out/), f1
(reads the new CHIRTS file), g2 and g4 (read f1/f4a outputs from this folder). All other scripts are
unchanged copies.

The earlier land-mask script (chirts_daily_landmask_v1_GEE_not_used.js) was not run. Its JRC water
mask, read at the 5.5 km CHIRTS scale, can drop inland cells that contain rivers or reservoirs, and
may not cover open sea.

## Check already done, before any outcome model

chirts_clean_check_20000701.csv (1 July 2000): only Lasbela (9 of 651 pixels removed), Gwadar (14 of
577), Thatta (6 of 683) and Karachi West (2 of 61) changed. Mean Tmax there rose from -21.9, 6.6, 28.7
and 24.2 C to 36.5, 34.0, 37.7 and 35.2 C. The other 137 districts were identical.

## Expectations, written before running

1. r0: district-month CHIRTS identical (within 0.01 C) to the original extraction in every district
   except the four above.
2. f1: the coastal exclusion rule flags no districts.
3. Station validation and product rankings (f1): compared with the frozen results; changes reported.
4. Stunting (f2, f3, f5a-c, g3): primary estimates, joint heterogeneity test and district
   fixed-effects results compared with the frozen results.
5. Mortality (f4, g4): the four-product overlap sample can gain up to four districts. The primary
   mortality analysis is g4 on the new overlap sample; the frozen 123-district result is the reference.
6. No model, covariate, weight or exclusion rule is changed in response to these results. A changed
   conclusion is reported as such.

## Added analyses (written to this specification before they are run)

- r1 (review point 1), on the frozen finalisation and addendum 3 inputs (read only): TerraClimate
  infant-mortality estimate on (A) the planned f4 sample, (B) the complete-CPC data restricted to the
  districts in A, (C) the full complete-CPC g4 sample, (D) the districts added in C only; and a
  temperature x added-district interaction in C. Same model as g4. Shows whether the change from 0.185
  to 0.110 comes from the added districts or from changed data within the original districts.
- r2 (review point 5), on the rerun data: the f5a variance decomposition to five significant digits,
  with the covariate increment shown separately; correlations between products of the exposure
  residualised on survey x age-year and district fixed effects.

## Run

sh run_all.sh (f0 stops unless all 34 yearly CHIRTS files are present).
