# Paper II, addendum 2, items 1 and 2: bootstrap diagnostics and exposure standardisation.
# usage: Rscript f5b_bootstrap_diagnostics.R [first-run rds]
# The optional argument is the replicate file of the first bootstrap run, for the reproduction check.
a <- commandArgs(FALSE)
H <- if (any(grepl("--file=", a))) dirname(normalizePath(sub("--file=", "", a[grep("--file=", a)]))) else getwd()   # Rscript, or source() from this folder
O <- file.path(H, "out")
first <- commandArgs(trailingOnly = TRUE)

prods <- c("tc", "era5", "cpc", "ch")
res <- readRDS(file.path(O, "f3_boot_ageyr.rds"))
f2 <- read.csv(file.path(O, "f2_undernutrition.csv"))
d <- read.csv(file.path(O, "f1_child_exposures.csv"))
P <- d[complete.cases(d[, paste0("anm16_", prods)]), ]
sds <- sapply(prods, function(p) sd(P[[paste0("anm16_", p)]]))   # SD used to standardise each product

# joint Wald test that all four coefficients are equal, from point estimates and replicates
wald <- function(est, B) {
  C <- rbind(c(-1, 1, 0, 0), c(-1, 0, 1, 0), c(-1, 0, 0, 1))
  dd <- C %*% est
  W <- as.numeric(t(dd) %*% solve(C %*% cov(B) %*% t(C)) %*% dd)
  c(chi2 = W, p = pchisq(W, 3, lower.tail = FALSE))
}

rows <- list()
for (x in res) {
  names(x$est) <- prods
  ok <- rowSums(x$conv) == 4
  an <- f2[f2$analysis == "primary" & f2$outcome == x$outcome, ]
  an <- an[match(prods, an$product), ]
  full <- wald(x$est, x$B)
  h1 <- wald(x$est, x$B[1:250, ])
  h2 <- wald(x$est, x$B[251:500, ])
  cv <- wald(x$est, x$B[ok, ])
  # per 1 degree C: divide each product's coefficient (and replicates) by its SD
  Bc <- sweep(x$B, 2, sds, "/")
  ec <- x$est / sds
  pc <- wald(ec, Bc)
  rows[[x$outcome]] <- data.frame(
    outcome = x$outcome, replicates = nrow(x$B), nonconverged_fits = sum(x$conv == 0),
    replicates_all_converged = sum(ok), extreme_replicates = sum(abs(x$B) > 2),
    joint_p_all = full["p"], joint_p_1_250 = h1["p"], joint_p_251_500 = h2["p"],
    joint_p_converged_only = cv["p"], joint_p_per_degree = pc["p"],
    boot_se = paste(round(apply(x$B, 2, sd), 4), collapse = " / "),
    analytic_se = paste(round(an$se, 4), collapse = " / "),
    sd_anomaly_C = paste(round(sds, 3), collapse = " / "),
    OR_per_SD = paste(round(exp(x$est), 3), collapse = " / "),
    OR_per_degree = paste(round(exp(ec), 3), collapse = " / "),
    row.names = NULL)
}
out <- do.call(rbind, rows)
if (length(first) > 0) {
  old <- readRDS(first[1])
  out$identical_to_first_run <- sapply(seq_along(res), function(i) isTRUE(all.equal(unname(res[[i]]$B), unname(old[[i]]$B))))
}
write.csv(out, file.path(O, "f5b_bootstrap_diagnostics.csv"), row.names = FALSE)
print(t(out))
