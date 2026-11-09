# Paper II, v1.3 addendum: district linkage and clustering check for infant mortality (23 October 2026)

Written before the check is run. Exploratory follow-up; it does not replace any reported result.

## Inconsistency found during v1.3 preparation

- The undernutrition analysis identifies districts by exposure polygon (master district ids from the child file):
  117 units. The mortality analysis identifies districts by MICS district code: 128 MICS districts (129 in the
  surveys; Sheerani is not linked by the mortality crosswalk).
- The 128 MICS districts map to 116 distinct polygon sets: 12 pairs of MICS districts (districts split after the
  polygons were drawn) share one exposure series. The mortality SEs are clustered by MICS district, which is finer
  than the unit at which exposure varies for these 12 pairs.
- The two analyses link three MICS districts differently: Sheerani (undernutrition: polygon 40, Largha Shirani;
  mortality: not linked) and Gujrat and Mandi Bahauddin (undernutrition: polygon 90; mortality: mean of polygons 87
  and 90).

## Check (mortality only; complete-CPC primary analysis, corrected CHIRTS, same model and weights)

1. Clustering: SEs and the joint test clustered by exposure unit (polygon set; 116 clusters) instead of MICS district.
2. Linkage: the four product estimates with the undernutrition linkage (Sheerani to polygon 40; Gujrat and Mandi
   Bahauddin to polygon 90), all four exposures rebuilt from the district-month product series, clustered by
   exposure unit. Before this, the rebuild is validated by reproducing the primary exposures for all other districts.

## Decision rule, fixed now

The primary mortality results stay as reported. The check is reported in the appendix. If any product's estimate
changes by more than 0.01 deaths per 1,000 child-months per °C, or a 95% CI or the joint test changes the
conclusion (a CI excluding 0, or joint p crossing 0.05), the change is reported in the main text as well.
