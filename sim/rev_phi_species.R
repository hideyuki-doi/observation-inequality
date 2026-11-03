# 改訂（Reviewers 3, 4）：種ごとの NB-GLM（努力量オフセット＋傾向なし／線形／2 次）から φ と残差の自己相関を推定し、
# 分類群・データ源・記録の多さで要約する。大きな交互作用モデルは収束しないため、種ごとに当てはめる
source("sim/explore_common.R")
set.seed(20261103)
tar_load(c(bird_gy, mam_gy))
cells <- arrow::open_dataset("data/derived/gbif_cells/parts") |> filter(year >= 2000, year <= 2024, group_id != "mammals") |>
  group_by(set = group_id, sp = specieskey, year) |> summarise(y = sum(n)) |> collect() |> ungroup()
vert <- function(gy, label, filt = identity) gy |> filt() |> filter(year %in% 2000:2024, rtype != "fossil") |>
  group_by(sp = species, year) |> summarise(y = sum(n), .groups = "drop") |> mutate(set = label)
d <- bind_rows(cells, vert(mam_gy, "mammals"), vert(mam_gy, "mammals (no machine obs.)", \(x) filter(x, basisofrecord != "MACHINE_OBSERVATION")),
               vert(bird_gy, "birds (eBird)", \(x) filter(x, ds_class == "ebird")), vert(bird_gy, "birds (excluding eBird)", \(x) filter(x, ds_class != "ebird"))) |>
  group_by(set) |> complete(sp, year = 2000:2024, fill = list(y = 0)) |> ungroup()
G <- d |> group_by(set, year) |> summarise(G = sum(y), .groups = "drop")
d <- left_join(d, G, by = c("set", "year")) |> group_by(set, sp) |> mutate(m = mean(y)) |> ungroup() |>
  filter(m >= 1) |> mutate(stratum = cut(m, c(1, 10, 100, Inf), right = FALSE, labels = c("1-10", "10-100", ">=100")), t = year - 2012)
# 層ごとに最大 200 種（seed 固定）
keys <- d |> distinct(set, stratum, sp) |> group_by(set, stratum) |> slice_sample(n = 200) |> ungroup()
d <- semi_join(d, keys, by = c("set", "stratum", "sp"))
one <- function(x) {
  f <- function(form) tryCatch(suppressWarnings(MASS::glm.nb(form, data = x, control = glm.control(maxit = 100))), error = function(e) NULL)
  f0 <- f(y ~ 1 + offset(log(G))); f1 <- f(y ~ t + offset(log(G))); f2 <- f(y ~ t + I(t^2) + offset(log(G)))
  ac <- if (is.null(f1)) NA else { r <- residuals(f1, type = "pearson"); if (sd(r) > 0) cor(r[-1], r[-length(r)]) else NA }
  th <- function(m) if (is.null(m) || m$theta > 1e4) NA else m$theta
  tibble(phi_none = th(f0), phi_linear = th(f1), phi_quadratic = th(f2), ac1_linear = ac)
}
sp_list <- split(d, list(d$set, d$sp), drop = TRUE)
res <- parallel::mclapply(sp_list, function(x) bind_cols(distinct(x, set, sp, stratum, m), one(x)), mc.cores = 12, mc.preschedule = TRUE) |> bind_rows()
readr::write_csv(res, "sim/rev_phi_species.csv")
summ <- res |> group_by(set, stratum) |> summarise(n_species = n(), across(c(phi_none, phi_linear, phi_quadratic, ac1_linear), \(v) median(v, na.rm = TRUE)),
                                                 fail_linear = mean(is.na(phi_linear)), .groups = "drop")
print(summ, n = 60, width = 200)
readr::write_csv(summ, "sim/rev_phi_species_summary.csv")
