# Paper II finalisation, step 2 (PLAN_PaperII_finalisation_2026-10-22.md, sha256 68a04097...).
# Undernutrition: primary model (survey x age-year FE, common four-product sample) and the
# secondary analyses (i)-(v). Base R glm, cluster-robust SEs by district.
# folder of this script; inputs are in its parent folder (05_fragility_audit), outputs in ./out
a <- commandArgs(FALSE)
H <- if (any(grepl("--file=", a))) dirname(normalizePath(sub("--file=", "", a[grep("--file=", a)]))) else getwd()   # Rscript, or source() from this folder
O <- file.path(H, "out")
library(sandwich)

d <- read.csv(file.path(O, "f1_child_exposures.csv"))
z <- function(x) (x - mean(x, na.rm = TRUE)) / sd(x, na.rm = TRUE)
controls <- "pm25 + ndvi + drought + wealth_score + residence + mother_educ + age_mo + sex"
prods <- c("tc", "era5", "cpc", "ch")
fes <- c(survey_x_ageyr = "factor(survey):factor(age_yr)",
         survey_x_agemo = "factor(survey):factor(age_mo)",
         survey_only = "factor(survey)",
         survey_birthyear = "factor(survey) + factor(birth_year)")

# one weighted logit; returns log-OR, SE, OR, CI, p, n
fit <- function(outcome, expo, fe, data) {
  # as fixest::feglm: drop fixed-effect cells where the outcome does not vary; age_mo is absorbed
  # by survey x age-in-months cells, so it is left out of that specification
  cell <- if (grepl("age_mo", fe)) paste(data$survey, data$age_mo) else if (grepl("age_yr", fe)) paste(data$survey, data$age_yr) else data$survey
  v <- tapply(data[[outcome]], cell, function(x) length(unique(na.omit(x))))
  data <- data[cell %in% names(v)[v > 1], ]
  ctl <- if (grepl("age_mo", fe)) sub(" \\+ age_mo", "", controls) else controls
  f <- as.formula(paste(outcome, "~", expo, "+", ctl, "+", fe))
  m <- suppressWarnings(glm(f, family = binomial, weights = weight, data = data))
  used <- data[rownames(model.frame(m)), ]
  se <- sqrt(vcovCL(m, cluster = used$master_ids, type = "HC1")[expo, expo])
  b <- unname(coef(m)[expo])
  data.frame(b = b, se = se, OR = exp(b), lo = exp(b - 1.96 * se), hi = exp(b + 1.96 * se),
             p = 2 * pnorm(-abs(b / se)), n = nobs(m))
}

res <- list()
add <- function(r, analysis, outcome, fe, product) {
  res[[length(res) + 1]] <<- cbind(data.frame(analysis = analysis, outcome = outcome, fe = fe, product = product), r)
}

# primary sample: all four anomalies present (births to 2016, flagged districts excluded)
P <- d[complete.cases(d[, paste0("anm16_", prods)]), ]
for (p in prods) P[[paste0("z_", p)]] <- z(P[[paste0("anm16_", p)]])
P$z_cons <- z((0.58 * P$z_tc + 0.67 * P$z_era5 + 0.69 * P$z_cpc + 0.74 * P$z_ch) / 2.68)
P$z_eq <- z((P$z_tc + P$z_era5 + P$z_cpc + P$z_ch) / 4)
cat("primary sample:", nrow(P), "children\n")

for (o in c("stunting", "underweight", "wasting")) {
  for (p in prods) {
    add(fit(o, paste0("z_", p), fes["survey_x_ageyr"], P), "primary", o, "survey_x_ageyr", p)
    add(fit(o, paste0("z_", p), fes["survey_x_agemo"], P), "ii age in months", o, "survey_x_agemo", p)
    add(fit(o, paste0("z_", p), fes["survey_only"], P), "v earlier specs", o, "survey_only", p)
    add(fit(o, paste0("z_", p), fes["survey_birthyear"], P), "v earlier specs", o, "survey_birthyear", p)
  }
  for (e in c("z_cons", "z_eq")) add(fit(o, e, fes["survey_x_ageyr"], P), "iii consensus", o, "survey_x_ageyr", e)
}

# (i) full sample, three products, births 2012-2019, baseline 2000-2019
Fu <- d[complete.cases(d[, paste0("anm19_", c("tc", "era5", "cpc"))]), ]
for (p in c("tc", "era5", "cpc")) Fu[[paste0("z_", p)]] <- z(Fu[[paste0("anm19_", p)]])
cat("full sample:", nrow(Fu), "children\n")
for (o in c("stunting", "underweight", "wasting")) {
  for (p in c("tc", "era5", "cpc")) add(fit(o, paste0("z_", p), fes["survey_x_ageyr"], Fu), "i full sample", o, "survey_x_ageyr", p)
}

# (iv) births to 2016 including flagged districts: three products
S4 <- d[complete.cases(d[, paste0("anm16_", c("tc", "era5", "cpc"))]), ]
for (p in c("tc", "era5", "cpc")) S4[[paste0("z_", p)]] <- z(S4[[paste0("anm16_", p)]])
cat("sample (iv):", nrow(S4), "children\n")
for (o in c("stunting", "underweight", "wasting")) {
  for (p in c("tc", "era5", "cpc")) add(fit(o, paste0("z_", p), fes["survey_x_ageyr"], S4), "iv incl flagged districts", o, "survey_x_ageyr", p)
}

out <- do.call(rbind, res)
write.csv(out, file.path(O, "f2_undernutrition.csv"), row.names = FALSE)
out$cell <- paste0(sprintf("%.2f", out$OR), " (", sprintf("%.2f", out$lo), "-", sprintf("%.2f", out$hi), ") p=", signif(out$p, 2))
print(out[, c("analysis", "outcome", "fe", "product", "cell", "n")], row.names = FALSE)
