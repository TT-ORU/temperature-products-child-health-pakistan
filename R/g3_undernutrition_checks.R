# Paper II, addendum 3, items 1 and 3: primary and district fixed-effects undernutrition models with
# (a) the harmonised CPC exposure, (b) no weights, (c) weights rescaled to provincial population.
# The baseline variant reproduces the finalisation results. Joint tests use the stacked covariance
# (district sums of influence functions), as in f5c.
a <- commandArgs(FALSE)
H <- if (any(grepl("--file=", a))) dirname(normalizePath(sub("--file=", "", a[grep("--file=", a)]))) else getwd()
library(sandwich)

d <- read.csv(file.path(H, "out/g2_child_exposures.csv"))
z <- function(x) (x - mean(x, na.rm = TRUE)) / sd(x, na.rm = TRUE)
P <- d[complete.cases(d[, paste0("anm16_", c("tc", "era5", "cpc", "ch"))]), ]
for (p in c("tc", "era5", "cpc", "ch", "cpch")) P[[paste0("z_", p)]] <- z(P[[paste0("anm16_", p)]])
P$cell <- paste(P$survey, P$age_yr)
P$district <- as.character(P$master_ids)
controls <- "pm25 + ndvi + drought + wealth_score + residence + mother_educ + age_mo + sex"

joint <- function(outcome, district, prods, wvar) {
  D <- P[complete.cases(P[, c(outcome, "pm25", "ndvi", "drought", "wealth_score", "residence",
                              "mother_educ", "age_mo", "sex")]), ]
  v <- tapply(D[[outcome]], D$cell, function(x) length(unique(x)))
  D <- D[D$cell %in% names(v)[v > 1], ]
  fe <- "factor(cell)"
  if (district) {
    v <- tapply(D[[outcome]], D$district, function(x) length(unique(x)))
    D <- D[D$district %in% names(v)[v > 1], ]
    fe <- "factor(cell) + factor(district)"
  }
  D$w <- D[[wvar]]
  b <- c(); se <- c(); IF <- NULL
  for (p in prods) {
    e <- paste0("z_", p)
    m <- suppressWarnings(glm(as.formula(paste(outcome, "~", e, "+", controls, "+", fe)),
                              family = binomial, weights = w, data = D))
    br <- bread(m)
    IF <- cbind(IF, rowsum(as.numeric((estfun(m)[, colnames(br)] %*% br[, e]) / nobs(m)), D$master_ids))
    b <- c(b, coef(m)[e])
    se <- c(se, sqrt(vcovCL(m, cluster = D$master_ids, type = "HC1")[e, e]))
  }
  G <- nrow(IF)
  V <- G / (G - 1) * crossprod(IF)
  C <- rbind(c(-1, 1, 0, 0), c(-1, 0, 1, 0), c(-1, 0, 0, 1))
  W <- as.numeric(t(C %*% b) %*% solve(C %*% V %*% t(C)) %*% (C %*% b))
  data.frame(outcome = outcome, model = if (district) "+ district FE" else "primary",
             product = c("tc", "era5", "cpc", "ch"), exposure = prods,
             OR = exp(b), lo = exp(b - 1.96 * se), hi = exp(b + 1.96 * se), p = 2 * pnorm(-abs(b / se)),
             joint_chi2 = W, joint_p = pchisq(W, 3, lower.tail = FALSE), n = sum(D$w > 0), row.names = NULL)
}

variants <- list(baseline = list(c("tc", "era5", "cpc", "ch"), "weight"),
                 cpc_harmonised = list(c("tc", "era5", "cpch", "ch"), "weight"),
                 unweighted = list(c("tc", "era5", "cpc", "ch"), "weight_one"),
                 population_weights = list(c("tc", "era5", "cpc", "ch"), "weight_pop"))
res <- list()
for (vn in names(variants)) {
  for (o in c("stunting", "underweight", "wasting")) {
    for (dfe in c(FALSE, TRUE)) {
      r <- joint(o, dfe, variants[[vn]][[1]], variants[[vn]][[2]])
      r$variant <- vn
      res[[length(res) + 1]] <- r
      cat(vn, o, if (dfe) "district" else "primary", sprintf("%.2f", r$OR), " joint p", signif(r$joint_p[1], 2), "\n")
    }
  }
}
out <- do.call(rbind, res)
write.csv(out, file.path(H, "out/g3_undernutrition_checks.csv"), row.names = FALSE)
