# Addendum 2 to the Paper II finalisation plan: pre-submission checks

Written on 22 October 2026 (21:05 UTC), after the finalisation results (PaperII_finalisation_results_2026-10-22.md)
and the reviewer's comments on them, and before any of the checks below were run. All are
exploratory. The finalisation plan (sha256 68a04097...) is unchanged; its primary estimates stay the
primary estimates whatever these checks show.

1. **Bootstrap diagnostics.** Re-run the paired district bootstrap of the primary undernutrition
   model (same code, same seed 20261023, 500 replicates) with the convergence flag of every fit
   recorded. Report:
   - the number of non-converged fits;
   - whether the replicate coefficients are identical to the first run (a reproduction check);
   - the joint heterogeneity test computed (a) on replicates 1-250 and 251-500 separately,
     (b) excluding non-converged replicates, and (c) with bootstrap SEs compared with the
     analytic cluster-robust SEs.

2. **Exposure standardisation.** Report each product's SD of the birth-year anomaly in °C in the
   primary sample, the odds ratios per 1 °C (exp(beta / SD)), and the bootstrap joint test on the
   per-°C scale (same replicates, coefficients divided by each product's SD).

3. **Identifying variation.** For each product, the share of the anomaly's variance in the primary
   sample explained by (a) survey × age-year cells, (b) cells plus district, and (c) cells plus
   district plus the covariates. The residual share in (a) is the variation the primary model uses.
   Also report how much of that residual variation is between districts (district means of the
   residual) versus within district.

4. **District fixed effects sensitivity.** Refit the primary model for the three outcomes and four
   products adding district (master_ids) fixed effects, so that only within-district differences
   between birth cohorts, relative to other districts in the same survey and age group, identify
   the association. Report ORs per SD (primary-sample SD) and the paired bootstrap joint test for
   stunting (500 replicates, seed 20261024), if the computing time is under about two hours.

No decision rule: results are reported whatever they show. If the district fixed effects estimates
differ from the primary estimates, the manuscript reports both and discusses which variation each
uses.
