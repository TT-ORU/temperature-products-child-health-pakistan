# Paper II, addendum 3 (ADDENDUM3_..._2026-10-22.md, sha256 d1e2aa52...), items 1-2, exposure only.
# CPC daily Tmax grids -> district-month means for all 141 districts (same cells as the two existing
# CPC files: terra::extract, mean over the cells of each district), then checks against both files.
a <- commandArgs(FALSE)
H <- if (any(grepl("--file=", a))) dirname(normalizePath(sub("--file=", "", a[grep("--file=", a)]))) else getwd()
B <- dirname(H)                                   # folder 05
ROOT <- dirname(dirname(B))                       # Pakistan_urbanization
library(terra)

dis <- vect(file.path(ROOT, "data_processed/pakistan_districts_gadm_level3.gpkg"))
res <- NULL
for (y in 1990:2019) {
  r <- rast(file.path(ROOT, sprintf("data_raw/climate/cpc_global_temp_pakistan/tmax_pak_%d.tif", y)))
  month <- as.integer(format(as.Date(sprintf("%d-01-01", y)) + 0:(nlyr(r) - 1), "%m"))   # layers are days
  mon <- tapp(r, month, mean, na.rm = TRUE)                                              # monthly mean per cell
  e <- terra::extract(mon, dis, fun = mean, na.rm = TRUE)
  res <- rbind(res, data.frame(district_id = rep(dis$district_id, 12), year = y,
                               month = rep(1:12, each = nrow(dis)), cpc_tmax = as.vector(as.matrix(e[, -1]))))
}
res$cmc <- (res$year - 1900) * 12 + res$month
dir.create(file.path(B, "outputs/cpc_district_month_complete"), showWarnings = FALSE, recursive = TRUE)
write.csv(res, file.path(B, "outputs/cpc_district_month_complete/cpc_tmax_district_month_1990_2019.csv"), row.names = FALSE)

# checks against the existing files
old_m <- read.csv(file.path(B, "data_raw/climate/cpc_global_temp_pakistan/cpc_tmax_by_district_month.csv"))
old_y <- read.csv(file.path(B, "data_raw/climate/cpc_global_temp_pakistan/cpc_tmax_by_district_year.csv"))
x <- merge(res, old_m[, c("district_id", "year", "month", "cpc_tmax")], by = c("district_id", "year", "month"))
yr <- aggregate(cpc_tmax ~ district_id + year, data = res, FUN = mean)       # mean of 12 monthly means
z <- merge(yr, old_y, by = c("district_id", "year"))
z16 <- z[z$year >= 2000 & z$year <= 2016, ]
an <- function(v, g) v - ave(v, g)
out <- data.frame(
  check = c("districts in rebuilt monthly series", "districts in existing monthly file",
            "max abs difference, rebuilt vs existing monthly file (common district-months)",
            "mean abs difference, mean of monthly means vs existing yearly file (annual mean of daily)",
            "max abs difference, same comparison",
            "correlation of district-year anomalies 2000-16, the two yearly constructions"),
  value = c(length(unique(res$district_id[!is.na(res$cpc_tmax)])), length(unique(old_m$district_id)),
            max(abs(x$cpc_tmax.x - x$cpc_tmax.y)), mean(abs(z$cpc_tmax - z$cpc_tmax_mean)),
            max(abs(z$cpc_tmax - z$cpc_tmax_mean)),
            cor(an(z16$cpc_tmax, z16$district_id), an(z16$cpc_tmax_mean, z16$district_id))))
write.csv(out, file.path(H, "out/g1_cpc_checks.csv"), row.names = FALSE)
print(out, row.names = FALSE)
