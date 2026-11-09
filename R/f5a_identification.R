# Paper II, addendum 2 (ADDENDUM2_PaperII_presubmission_checks_2026-10-22.md, sha256 510b9ad9...),
# items 3 and 4: which variation identifies the primary model, and district fixed effects.
# Base R glm, cluster-robust SEs by district.
a <- commandArgs(FALSE)
H <- if (any(grepl("--file=", a))) dirname(normalizePath(sub("--file=", "", a[grep("--file=", a)]))) else getwd()   # Rscript, or source() from this folder
O <- file.path(H, "out")
library(sandwich)

d <- read.csv(file.path(O, "f1_child_exposures.csv"))
z <- function(x) (x - mean(x, na.rm = TRUE)) / sd(x, na.rm = TRUE)
prods <- c("tc", "era5", "cpc", "ch")
P <- d[complete.cases(d[, paste0("anm16_", prods)]), ]
for (p in prods) P[[paste0("z_", p)]] <- z(P[[paste0("anm16_", p)]])
P$cell <- paste(P$survey, P$age_yr)
P$district <- as.character(P$master_ids)
controls <- "pm25 + ndvi + drought + wealth_score + residence + mother_educ + age_mo + sex"

# ---------------------------------------------------------------- item 3: variance decomposition
# children with complete covariates (stunting sample)
V <- P[complete.cases(P[, c("stunting", "pm25", "ndvi", "drought", "wealth_score", "residence",
                            "mother_educ", "age_mo", "sex")]), ]
rows <- list()
for (p in prods) {
  x <- V[[paste0("z_", p)]]
  r2a <- summary(lm(x ~ factor(cell), data = V))$r.squared
  r2b <- summary(lm(x ~ factor(cell) + factor(district), data = V))$r.squared
  r2c <- summary(lm(as.formula(paste("x ~ factor(cell) + factor(district) +", controls)), data = V))$r.squared
  r2d <- summary(lm(as.formula(paste("x ~ factor(cell) +", controls)), data = V))$r.squared
  # residual after cells: how much of it is between districts
  e <- resid(lm(x ~ factor(cell), data = V))
  between <- var(ave(e, V$district)) / var(e)
  rows[[p]] <- data.frame(product = p, n = nrow(V),
    share_cells = r2a, share_cells_district = r2b, share_cells_covariates = r2d,
    share_cells_district_covariates = r2c,
    residual_after_cells = 1 - r2a, residual_between_district_share = between,
    residual_within_district_share = 1 - between)
}
vd <- do.call(rbind, rows)
write.csv(vd, file.path(O, "f5a_variance_decomposition.csv"), row.names = FALSE)
print(vd, digits = 3, row.names = FALSE)

# ---------------------------------------------------------------- item 4: district fixed effects
fit <- function(outcome, expo, data, district) {
  # as fixest::feglm: drop cells (and districts, when they are fixed effects) without outcome variation
  data <- data[!is.na(data[[outcome]]), ]
  v <- tapply(data[[outcome]], data$cell, function(x) length(unique(x)))
  data <- data[data$cell %in% names(v)[v > 1], ]
  fe <- "factor(cell)"
  if (district) {
    v <- tapply(data[[outcome]], data$district, function(x) length(unique(x)))
    data <- data[data$district %in% names(v)[v > 1], ]
    fe <- "factor(cell) + factor(district)"
  }
  m <- suppressWarnings(glm(as.formula(paste(outcome, "~", expo, "+", controls, "+", fe)),
                            family = binomial, weights = weight, data = data))
  used <- data[rownames(model.frame(m)), ]
  se <- sqrt(vcovCL(m, cluster = used$master_ids, type = "HC1")[expo, expo])
  b <- unname(coef(m)[expo])
  data.frame(b = b, se = se, OR = exp(b), lo = exp(b - 1.96 * se), hi = exp(b + 1.96 * se),
             p = 2 * pnorm(-abs(b / se)), n = nobs(m))
}
res <- list()
for (o in c("stunting", "underweight", "wasting")) {
  for (p in prods) {
    t0 <- Sys.time()
    r <- fit(o, paste0("z_", p), P, TRUE)
    res[[length(res) + 1]] <- cbind(data.frame(outcome = o, product = p, model = "survey x age-year + district FE"), r)
    cat(o, p, sprintf("OR %.2f (%.2f-%.2f) p=%.2g n=%d", r$OR, r$lo, r$hi, r$p, r$n),
        " seconds:", round(as.numeric(Sys.time() - t0, units = "secs")), "\n")
  }
}
out <- do.call(rbind, res)
write.csv(out, file.path(O, "f5a_district_fe.csv"), row.names = FALSE)
