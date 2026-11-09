# Temperature dataset choice and model specification influence climate–child-health associations: a multi-product analysis in Pakistan

R code, dated analysis plans, aggregate results and district-level temperature series for the article of the same title
(Taj T, submitted).

Tahir Taj, Department of Clinical Epidemiology and Biostatistics, Faculty of Medicine and Health, Örebro University,
Sweden (tahir.taj@oru.se)

The study held two child-health designs fixed (undernutrition and infant mortality in four provincial Multiple Indicator
Cluster Surveys, MICS6, Pakistan 2017–20) and varied only the temperature product: TerraClimate, ERA5-Land, CPC and
CHIRTS.

## Contents

| Folder | Contents |
|---|---|
| `R/` | R code for the undernutrition analyses: models (f2), paired district bootstrap (f3, f3b), variance decomposition and district fixed effects (f5a), bootstrap diagnostics (f5b), analytic joint tests (f5c), CPC and weighting checks (g3) |
| `R/out/` | The aggregate results these scripts write |
| `exposure/` | R code that rebuilds the complete CPC district-month series from the CPC daily grids (g1), with its checks |
| `plans/` | The dated analysis plans and addenda, each with its sha256 checksum file, frozen before the analyses they describe |
| `results/` | Aggregate results of the steps not written in R: station validation, product agreement, CHIRTS correction, infant-mortality estimates and checks |
| `data/` | District-level temperature series for each product, the station-product validation pairs and the MICS district linkage |
| `docs/` | The PubMed search and screening record for the article's Research in context panel |

The scripts are the versions that produced the published results, copied unchanged.

## Running the R code

The R scripts need two child-level input files in `R/out/`, which are built from the MICS6 microdata and cannot be shared
(see below):

- `f1_child_exposures.csv`: one row per child with anthropometry. Columns:
  - row, survey, master_ids (exposure unit: polygon ids in `data/`), weight (MICS child sample weight)
  - stunting, underweight, wasting (1 if the WHO Child Growth Standards z score, MICS variables HAZ2, WAZ2 and WHZ2,
    is below −2 SD; values flagged by MICS as implausible are missing)
  - pm25, ndvi, drought (district-level covariates); wealth_score, residence, mother_educ, age_mo, age_yr, sex, birth_year, flagged
  - anm16_tc, anm16_era5, anm16_cpc, anm16_ch: the birth-year mean Tmax minus the district's 2000–16 mean, in °C
  - anm19_tc, anm19_era5, anm19_cpc, anm19_ch: the same against the 2000–19 mean, for births 2012–19
- `g2_child_exposures.csv`: the same columns, plus anm16_cpch (CPC as the mean of monthly means), weight_pop (weights
  rescaled to provincial population) and weight_one (unweighted).

Then, from the `R/` folder:

```
Rscript f2_undernutrition.R              # undernutrition models
Rscript f3_bootstrap_products.R ageyr    # paired district bootstrap, 500 replicates (about 30 min); runs f3b
Rscript f5a_identification.R             # variance decomposition, district fixed effects
Rscript f5b_bootstrap_diagnostics.R      # bootstrap diagnostics
Rscript f5c_cross_product_covariance.R   # analytic joint tests
Rscript g3_undernutrition_checks.R       # CPC construction and weighting checks
```

Software: R 4.3.3 with the sandwich package (base R otherwise); `exposure/g1_cpc_rebuild.R` also needs terra. g1 was run
inside the original project folder. To rerun it, set the paths at the top of the script to the CPC daily grids, the
district polygons, and the existing CPC files (provided in `data/`).

## Not included

- **MICS6 microdata.** Available from UNICEF (https://mics.unicef.org) after registration, for Punjab 2017–18, Sindh
  2018–19, Khyber Pakhtunkhwa 2019 and Balochistan 2019–20. Files derived from them at the individual level (child
  exposure files, person-month files) are not shared; `.gitignore` excludes them.
- **Steps written in Python.** These are not included:
  - extraction of the district series from the gridded products, and the CHIRTS correction;
  - construction of the child-level exposure files;
  - the station validation;
  - the infant-mortality models;
  - the figures and manuscript.

  Their aggregate results are in `results/`.
- **District polygons.** GADM level 3, 141 polygons for Pakistan, from https://gadm.org under the GADM licence.

## Data files

All temperatures are monthly or yearly means of daily maximum temperature (°C). `district_id` is the polygon id (1–141).
MICS districts are identified by province and `hh7_code`. `data/mics_district_crosswalk.csv` links the 129 MICS districts
to the polygons.

- `district_month_4products.csv`: the four products by district and month, as used in the analyses.
- `chirts_tmax_district_month_1983_2016_corrected.csv`: CHIRTS after masking non-land and fill pixels (used).
- `chirts_tmax_district_month_1983_2016_first_extraction.csv`: CHIRTS before the correction (affects four coastal
  districts; kept for documentation).
- `cpc_tmax_district_month_1990_2019_complete.csv`: CPC rebuilt from the daily grids for all 141 districts (g1).
- `cpc_tmax_district_month_original_file.csv`, `cpc_tmax_district_year.csv`: the earlier CPC files (109 districts
  monthly; yearly means of daily Tmax).
- `terraclimate_tmax_district_month_1991_2019.csv`, `era5land_heat_metrics_district_month.csv`: TerraClimate and ERA5-Land
  by district and month.
- `era5land_mics_district_month_1992_2019.csv`, `chirts_mics_district_month_1983_2016.csv`: the same at MICS-district level.
- `station_product_validation.csv`: GHCN-Daily station-months paired with the product values of the station's district.

## Plans

Each plan was frozen with a checksum before the analyses it describes. To verify, run from `plans/`:
`shasum -a 256 -c *.sha256` (macOS) or `sha256sum -c *.sha256` (Linux).

## Licences and attribution

- Code: MIT (see `LICENSE`).
- Results and derived data: CC BY 4.0, subject to the terms of the original data providers.
- TerraClimate: Abatzoglou et al., Sci Data 2018.
- ERA5-Land: contains modified Copernicus Climate Change Service information (2026).
- CPC Global Unified Temperature data provided by the NOAA PSL, Boulder, Colorado, USA, from https://psl.noaa.gov.
- CHIRTS: Funk et al., J Clim 2019; Verdin et al., Sci Data 2020.
- GHCN-Daily: Menne et al., J Atmos Ocean Technol 2012.

## Version history

- **1.1 (Nov 2026).** The undernutrition outcomes are defined with the WHO Child Growth Standards z scores supplied in
  the MICS6 files (HAZ2, WAZ2, WHZ2; flagged values missing). Version 1.0 had used the older NCHS reference z scores
  (HAZ, WAZ, WHZ) by mistake. The R code is unchanged; the child-level input file was rebuilt and every undernutrition
  step was re-run, so all files in `R/out/` are new. The infant-mortality results in `results/` were re-run as a check
  and agree with version 1.0 to machine precision. `docs/` was added.
- **1.0 (23 Oct 2026).** First version.
