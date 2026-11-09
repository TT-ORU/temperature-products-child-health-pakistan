# Paper II finalisation, step 3 (PLAN_PaperII_finalisation_2026-10-22.md, sha256 68a04097...).
# Paired cluster bootstrap of the product-specific coefficients (primary undernutrition model).
# Districts are resampled with replacement within each survey; in every replicate all four
# product models are refitted on the same resampled children. 500 replicates, seed 20261023.
# usage: Rscript f3_bootstrap_products.R <fe>   fe = ageyr (primary) | agemo (secondary ii)
#        | ageyr_district (addendum 2, item 4: adds district fixed effects; seed 20261024)
# The convergence flag of every fit is kept (addendum 2, item 1).
# folder of this script; inputs are in its parent folder (05_fragility_audit), outputs in ./out
a <- commandArgs(FALSE)
H <- if (any(grepl("--file=", a))) dirname(normalizePath(sub("--file=", "", a[grep("--file=", a)]))) else getwd()   # Rscript, or source() from this folder
O <- file.path(H, "out")
library(parallel)

args <- commandArgs(trailingOnly = TRUE)
fe_lab <- if (length(args) > 0) args[1] else "ageyr"
d <- read.csv(file.path(O, "f1_child_exposures.csv"))
z <- function(x) (x - mean(x, na.rm = TRUE)) / sd(x, na.rm = TRUE)
prods <- c("tc", "era5", "cpc", "ch")
P <- d[complete.cases(d[, paste0("anm16_", prods)]), ]
for (p in prods) P[[paste0("z_", p)]] <- z(P[[paste0("anm16_", p)]])
P$cell <- paste(P$survey, if (fe_lab == "agemo") P$age_mo else P$age_yr)
R <- 500

boot_outcome <- function(o) {
  vars <- c(o, "pm25", "ndvi", "drought", "wealth_score", "residence", "mother_educ", "age_mo", "sex",
            "weight", "master_ids", "survey", "cell", paste0("z_", prods))
  D <- P[complete.cases(P[, vars]), vars]
  # as fixest::feglm: drop fixed-effect cells where the outcome does not vary
  v <- tapply(D[[o]], D$cell, function(x) length(unique(x)))
  D <- D[D$cell %in% names(v)[v > 1], ]
  if (fe_lab == "ageyr_district") {
    v <- tapply(D[[o]], D$master_ids, function(x) length(unique(x)))
    D <- D[D$master_ids %in% names(v)[v > 1], ]
  }
  # design matrix without the exposure; the exposure column is added per product
  # age_mo is absorbed by the survey x age-in-months cells in the secondary specification
  fx <- if (fe_lab == "ageyr_district") ~ pm25 + ndvi + drought + wealth_score + residence + mother_educ + age_mo + sex + factor(cell) + factor(master_ids) - 1 else
    if (fe_lab == "ageyr") ~ pm25 + ndvi + drought + wealth_score + residence + mother_educ + age_mo + sex + factor(cell) - 1 else
    ~ pm25 + ndvi + drought + wealth_score + residence + mother_educ + sex + factor(cell) - 1
  X0 <- model.matrix(fx, data = D)
  y <- D[[o]]
  w <- D$weight
  fit_all <- function(idx) {
    sapply(prods, function(p) {
      X <- cbind(expo = D[[paste0("z_", p)]][idx], X0[idx, , drop = FALSE])
      f <- suppressWarnings(glm.fit(X, y[idx], weights = w[idx], family = binomial()))
      c(f$coefficients[1], f$converged)
    })
  }
  est <- fit_all(seq_len(nrow(D)))[1, ]
  names(est) <- prods
  # clusters (districts) within each survey
  cl <- split(seq_len(nrow(D)), D$master_ids)
  cl_survey <- sapply(cl, function(i) D$survey[i[1]])
  set.seed(if (fe_lab == "ageyr_district") 20261024 else 20261023)
  B <- matrix(NA, R, 4, dimnames = list(NULL, prods))
  conv <- B
  for (r in 1:R) {
    pick <- unlist(lapply(split(names(cl), cl_survey), function(k) sample(k, length(k), replace = TRUE)))
    f <- fit_all(unlist(cl[pick], use.names = FALSE))
    B[r, ] <- f[1, ]
    conv[r, ] <- f[2, ]
  }
  list(outcome = o, est = est, B = B, conv = conv, n = nrow(D))
}

outs <- if (fe_lab == "ageyr_district") "stunting" else c("stunting", "underweight", "wasting")
res <- mclapply(outs, boot_outcome, mc.cores = 2)
saveRDS(res, file.path(O, paste0("f3_boot_", fe_lab, ".rds")))

source(file.path(H, "f3b_summarise_bootstrap.R"))
