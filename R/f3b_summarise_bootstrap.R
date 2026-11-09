# Paper II finalisation, step 3b: summarise the paired bootstrap saved by f3_bootstrap_products.R.
# usage: Rscript f3b_summarise_bootstrap.R <fe>   (or sourced from f3 with fe_lab set)
if (!exists("H")) {
  a <- commandArgs(FALSE)
  H <- if (any(grepl("--file=", a))) dirname(normalizePath(sub("--file=", "", a[grep("--file=", a)]))) else getwd()   # Rscript, or source() from this folder
  O <- file.path(H, "out")
}
if (!exists("fe_lab")) { a <- commandArgs(trailingOnly = TRUE); fe_lab <- if (length(a) > 0) a[1] else "ageyr" }
prods <- c("tc", "era5", "cpc", "ch")
res <- readRDS(file.path(O, paste0("f3_boot_", fe_lab, ".rds")))

# pairwise differences in log-OR and the joint test that all four coefficients are equal
rows <- list()
for (x in res) {
  names(x$est) <- prods
  pr <- combn(prods, 2)
  for (j in seq_len(ncol(pr))) {
    a <- pr[1, j]; b <- pr[2, j]
    db <- x$B[, b] - x$B[, a]
    rows[[length(rows) + 1]] <- data.frame(outcome = x$outcome, comparison = paste(b, "-", a),
      diff_logOR = x$est[b] - x$est[a], lo = quantile(db, 0.025), hi = quantile(db, 0.975),
      boot_se = sd(db), row.names = NULL)
  }
  D3 <- x$B[, 2:4] - x$B[, 1]                 # differences from TerraClimate
  d3 <- x$est[2:4] - x$est[1]
  W <- as.numeric(t(d3) %*% solve(cov(D3)) %*% d3)
  rows[[length(rows) + 1]] <- data.frame(outcome = x$outcome, comparison = "joint: all four equal (Wald, 3 df)",
    diff_logOR = W, lo = NA, hi = NA, boot_se = pchisq(W, 3, lower.tail = FALSE), row.names = NULL)
  cat(x$outcome, "n =", x$n, " OR:", round(exp(x$est), 3), " joint chi2 =", round(W, 2),
      " p =", signif(pchisq(W, 3, lower.tail = FALSE), 2), "\n")
}
out <- do.call(rbind, rows)
names(out)[6] <- "boot_se_or_joint_p"
write.csv(out, file.path(O, paste0("f3_product_differences_", fe_lab, ".csv")), row.names = FALSE)
print(out, row.names = FALSE, digits = 3)
