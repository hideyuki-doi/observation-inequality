# 探索的（2）：占有ベースの指標（種 × 年の占有 1° セル数）は、記録数より年変動が小さいか
# 同じ NB（species + year 固定効果）で、記録数と占有セル数の φ を、同じ種の標本で比べる
source("sim/explore_common.R")
set.seed(20261103)
d <- arrow::open_dataset("data/derived/gbif_cells/parts") |> filter(year >= 2000, year <= 2024) |>
  group_by(group_id, specieskey, year) |> summarise(rec = sum(n), occ = n_distinct(cell)) |> collect()
d <- d |> group_by(group_id) |> complete(specieskey, year = 2000:2024, fill = list(rec = 0L, occ = 0L)) |>
  group_by(group_id, specieskey) |> mutate(m = mean(rec)) |> ungroup() |>
  mutate(stratum = cut(m, c(0, 1, 10, Inf), right = FALSE, labels = c("<1", "1-10", ">=10")))
fit_phi <- function(x, y) tryCatch(MASS::glm.nb(as.formula(paste(y, "~ 0 + factor(specieskey) + factor(year)")), data = x)$theta, error = function(e) NA_real_)
res <- d |> group_by(group_id, stratum) |> group_modify(function(x, k) {
  sp <- unique(x$specieskey); if (length(sp) < 5) return(tibble())
  x <- filter(x, specieskey %in% sample(sp, min(300, length(sp))))
  tibble(n_species = n_distinct(x$specieskey), mean_rec = mean(x$rec), mean_occ = mean(x$occ),
         phi_rec = fit_phi(x, "rec"), phi_occ = fit_phi(x, "occ"))
}) |> ungroup()
print(res, n = 50)
readr::write_csv(res, "sim/explore_occupancy_phi.csv")
