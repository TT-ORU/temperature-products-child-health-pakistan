# Paper II: statistical analysis finalisation plan

Date: 22 October 2026. Written before any of the outcome models below were run, and frozen with a
sha256 checksum. It follows inspection of the verification results
(PaperII_verification_note_2026-10-22.md) and of the CHIRTS exposure data. All analyses here are
therefore planned follow-up analyses and are reported as exploratory, not as originally
pre-specified confirmatory tests. Earlier plans for folder 05 and the verification addendum
(sha256 558f281f...) are unchanged.

## Primary objective

To assess whether temperature and child-health associations are consistent across four gridded
temperature products (TerraClimate, ERA5, CPC, CHIRTS) after appropriate adjustment for child age
and survey.

## 1. CHIRTS exposure (done before this plan was written: exposure data only, no outcomes)

- CHIRTS is rebuilt on the master district grid (141 districts) from the GEE district-daily
  extraction (data_raw/climate/chirts_daily_temperature, 1983-2016): daily maximum_temperature,
  then district-month and district-year means. This replaces the MICS-keyed file.
- Exclusion rule: a district's CHIRTS series is set to missing when its 2000-2016 mean Tmax is
  more than 5 °C below the lowest of the TerraClimate, ERA5 and CPC means for that district.
  This rule flags 4 coastal districts: Lasbela (-59 °C below TerraClimate), Gwadar (-27), Karachi
  West (-11) and Thatta (-7). In the other 137 districts CHIRTS is never more than 2.3 °C below
  all three. The pattern points to ocean pixels entering the polygon means in the GEE extraction.
- A corrected GEE script, with a land mask, is supplied. If the user re-runs it, all CHIRTS
  analyses are repeated with the re-extracted data, and both versions are reported.
- Validation, reported whatever it shows:
  (a) the range of district-month Tmax for every study district;
  (b) station anomaly correlations for all four products, computed from the district-month series
      of each station's district, on station-months common to all four products, with and without
      stations in flagged districts;
  (c) between-product correlations of district levels and district-year anomalies.

## 2. Undernutrition (stunting, underweight, wasting)

- Exposure: within-district anomaly of birth-year mean Tmax, baseline 2000-2016, standardised per
  SD within the analysis sample, for each product separately.
- **Primary model:** weighted logit with survey × completed-age-year fixed effects, with the
  controls of R_audit_01 (pm25, ndvi, drought, wealth_score, residence, mother_educ, age_mo, sex),
  survey weights, and SEs clustered by district (master_ids).
- **Primary sample:** children with all four product anomalies available. This means births up to
  2016, excluding children in the 4 flagged districts for every product, so that all products use
  the same children.
- **Secondary analyses:**
  (i) full sample, three products (TerraClimate, ERA5, CPC; births 2012-2019; baseline 2000-2019);
  (ii) survey × age-in-months fixed effects (flexible age adjustment);
  (iii) consensus exposures (accuracy-weighted and equal-weight, z then average then re-z);
  (iv) the primary sample including the 4 flagged districts, with CHIRTS set to missing there
       (three-product comparison on that sample);
  (v) survey fixed effects only, and survey + birth-year fixed effects (the earlier
      specifications), for transparency.

## 3. Between-product heterogeneity

- **Undernutrition:** paired cluster bootstrap. Districts are resampled with replacement within
  each survey, 500 replicates, seed 20261023. In each replicate all four product models are refit
  on the same resampled children. Reported:
  - percentile 95% CIs for the six pairwise differences in log-OR;
  - a joint Wald test that all four coefficients are equal (3 df), using the bootstrap covariance
    matrix.
  This is done for the primary model and outcome set. Secondary analysis (ii) gets the same test
  if computation allows.
- **Infant mortality:** a bootstrap is computationally infeasible (each model takes about 2
  minutes on 3.1 million person-months). Instead, the cross-product covariance of the four
  coefficients is estimated from district-level score contributions (equivalent to stacking the
  four regressions with cluster-robust SEs by district, as in Stata suest). Reported: the six
  pairwise differences with 95% CIs and the joint 3-df Wald test.

## 4. Infant mortality

- Retain the overlap-sample design of R_audit_02 (person-months, event × 1000 ~ Tmax |
  district × month-of-year + calendar month + age month, weights wmweight, cluster district).
- CHIRTS enters as the district-grid version aggregated to MICS districts through the crosswalk,
  in the same way as TerraClimate and CPC. Flagged districts are missing for CHIRTS, and therefore
  excluded from the overlap sample.
- Report the four coefficients with 95% CIs, the consensus exposures as a sensitivity analysis,
  and the range (no coefficient of variation as a headline statistic).
- Secondary: the earlier overlap sample built with the MICS-keyed CHIRTS file, for comparison.

## 5. Reporting

Results distinguish three things:
- exposure-product agreement (measurement);
- sensitivity to specification and product (model);
- causal interpretation, which these analyses do not establish.

No decision rule turns a result into a claim of heterogeneity other than the reported intervals
and tests. If the joint test is not significant, the paper describes differences as descriptive
sensitivity, not as demonstrated heterogeneity.
