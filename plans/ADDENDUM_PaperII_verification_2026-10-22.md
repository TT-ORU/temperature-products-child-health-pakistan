# Paper II (fragility audit): verification checks, 22 October 2026

Written on 22 October 2026 during the verification requested by the reviewer, before item 4 below
was run. All items are exploratory and are labelled as such in any manuscript. No earlier analysis
plan for folder 05 is changed.

Already run on 22 October 2026, before this note was written (reported whatever they showed):

1. Re-run of R_audit_01 (level and anomaly grids, survey FE with and without birth-year FE) with
   base R glm and cluster-robust SEs by district (fixest unavailable in the workspace).
2. Comparability check: the same anomaly models on the sample where all four products are
   available (births up to 2016, anomaly baseline 2000-2016), and the three-product models
   restricted to births up to 2016.
3. Re-run of R_audit_02 (infant mortality, four products and consensus) with pyfixest, and the
   station-accuracy weights recomputed from station_product_validation.csv.

To be run after this note (written before running):

4. Age-versus-period diagnostic. In surveys conducted in a single year, birth-year fixed effects
   within a survey are equivalent to fixed effects for completed years of age. To separate the two,
   for stunting, underweight and wasting and each product, fit the anomaly model with
   (a) survey FE only; (b) survey + birth-year FE (as in R_audit_01); (c) survey + completed-age-year
   FE, no birth-year FE; (d) survey x completed-age-year FE (children of the same age in the same
   survey). Full sample (three products) and the common four-product sample. Same controls,
   weights and clustering as R_audit_01. No decision rule; results reported whatever they show.
