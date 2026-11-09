# Addendum 3 to the Paper II finalisation plan: data-construction and survey-design checks

Written on 22 October 2026 (22:05 UTC), after the reviewer's comments on manuscript v1.0 and before any
outcome model below was run. Exploratory. The finalisation plan (sha256 68a04097...) and addenda 1-2
are unchanged, and the primary estimates stay primary whatever these checks show. The reviewer asked
for no further broad exploratory modelling; these checks only address exposure construction and the
survey design.

Already established before this note (exposure and weight data only, no outcomes):
- CPC yearly file = annual mean of daily Tmax per 0.5° cell, averaged over the cells of each district
  (terra::extract), reproduced to 1e-13 °C for all 141 districts and 2000-19. The CPC monthly file
  reproduces with the same cells to 1e-5 °C but contains only 109 of the 141 districts.
- The other products' district-years are means of 12 monthly means. For CPC the two constructions
  differ by 0.035 °C on average (max 0.09 °C); their anomalies correlate at 0.9996.
- The study's child weight equals the MICS child weight (chweight) in every survey: the weights
  have identical distributions, and each distinct weight value lies in one sampling stratum.
  Primary sampling units cannot be recovered for most children.

Checks to be run:

1. **Harmonised CPC exposure.** Rebuild CPC district-month means for all 141 districts from the daily
   grids (same cells as both files), and CPC district-years as the mean of the 12 monthly means (the
   construction used for the other products). Refit the primary and district fixed-effects
   undernutrition models with this CPC exposure, plus the joint tests of equal coefficients across
   the four products (stacked covariance).
2. **Complete CPC monthly series for infant mortality.** Rerun the four-product mortality models and
   their joint test on the overlap sample defined with the complete CPC monthly series.
3. **Weights.** Refit the primary and district fixed-effects undernutrition models (four products,
   three outcomes, joint tests) (a) unweighted, and (b) with child weights rescaled so that each
   province's total is proportional to its 2017 census population: Punjab 110,012,442; Sindh
   47,886,051; Khyber Pakhtunkhwa 30,523,371 + 5,001,676 (former FATA); Balochistan 12,335,129.
4. **Clustering** is documented, not re-estimated. In the MICS child files all 250 strata and all
   5,972 PSUs lie within a single district (and each stratum within urban or rural areas), and
   exposure varies at district level, so district clustering is the conservative choice.

No decision rule: results are reported whatever they show.
