# Paper II, addendum 2, item 4 (joint test for the district fixed effects model).
# The paired bootstrap would take well over two hours with district fixed effects, so the
# cross-product covariance is computed analytically instead: the four product models are fitted on
# the same children, and the covariance of their exposure coefficients comes from the district sums
# of each model's influence functions (stacked sandwich, as in Stata suest). The same method is
# applied to the primary model so that it can be checked against the paired bootstrap.
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

joint <- function(outcome, district) {
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
  b <- c(); IF <- NULL; se_cl <- c()
  for (p in prods) {
    e <- paste0("z_", p)
    m <- suppressWarnings(glm(as.formula(paste(outcome, "~", e, "+", controls, "+", fe)),
                              family = binomial, weights = weight, data = D))
    # influence of each child on the exposure coefficient (aliased columns removed)
    br <- bread(m)
    inf <- (estfun(m)[, colnames(br)] %*% br[, e]) / nobs(m)
    IF <- cbind(IF, rowsum(as.numeric(inf), D$master_ids))
    b <- c(b, coef(m)[e])
    se_cl <- c(se_cl, sqrt(vcovCL(m, cluster = D$master_ids, type = "HC1")[e, e]))
  }
  G <- nrow(IF)
  V <- G / (G - 1) * crossprod(IF)
  C <- rbind(c(-1, 1, 0, 0), c(-1, 0, 1, 0), c(-1, 0, 0, 1))
  W <- as.numeric(t(C %*% b) %*% solve(C %*% V %*% t(C)) %*% (C %*% b))
  data.frame(outcome = outcome, model = if (district) "+ district FE" else "primary",
             OR_tc = exp(b[1]), OR_era5 = exp(b[2]), OR_cpc = exp(b[3]), OR_ch = exp(b[4]),
             se_analytic = paste(round(sqrt(diag(V)), 4), collapse = " / "),
             se_vcovCL = paste(round(se_cl, 4), collapse = " / "),
             chi2 = W, p = pchisq(W, 3, lower.tail = FALSE), n = nrow(D), districts = G)
}
res <- rbind(joint("stunting", FALSE), joint("underweight", FALSE), joint("wasting", FALSE),
             joint("stunting", TRUE), joint("underweight", TRUE), joint("wasting", TRUE))
write.csv(res, file.path(O, "f5c_cross_product_tests.csv"), row.names = FALSE)
print(res, digits = 3, row.names = FALSE)
