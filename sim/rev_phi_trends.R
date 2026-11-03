# 改訂用：φ の推定に種ごとの傾向（線形・2次）を入れても過分散は残るか（本当の個体数変化と雑音の分離）
# 哺乳類（報告ベース）と無脊椎動物グループ（各層最大 300 種、seed 固定）
source("sim/explore_common.R")
set.seed(20261103)
fitphi <- function(x, form) tryCatch(MASS::glm.nb(form, data = x, control = glm.control(maxit = 100))$theta, error = function(e) NA_real_)
forms <- list(base = y ~ 0 + factor(sp) + factor(year),
              linear = y ~ 0 + factor(sp) + factor(year) + factor(sp):t,
              quadratic = y ~ 0 + factor(sp) + factor(year) + factor(sp):t + factor(sp):I(t^2))
# 哺乳類
tar_load(c(mam_sp, mam_gy))
spn <- unique(mam_sp$gbif_name[mam_sp$report_based & !is.na(mam_sp$gbif_name)])
dm <- mam_gy |> filter(species %in% spn, year %in% 2000:2024, rtype != "fossil") |> group_by(sp = species, year) |>
  summarise(y = sum(n), .groups = "drop") |> complete(sp = spn, year = 2000:2024, fill = list(y = 0)) |>
  group_by(sp) |> filter(sum(y) > 0) |> mutate(m = mean(y)) |> ungroup() |> mutate(group_id = "mammals", t = (year - 2012) / 12)
# 無脊椎動物（集計済み細胞データから種×年の記録数）
di <- arrow::open_dataset("data/derived/gbif_cells/parts") |> filter(year >= 2000, year <= 2024, group_id != "mammals") |>
  group_by(group_id, sp = specieskey, year) |> summarise(y = sum(n)) |> collect() |>
  group_by(group_id) |> complete(sp, year = 2000:2024, fill = list(y = 0L)) |> group_by(group_id, sp) |> mutate(m = mean(y)) |> ungroup() |>
  mutate(t = (year - 2012) / 12)
d <- bind_rows(dm, di) |> mutate(stratum = cut(m, c(0, 1, 10, Inf), right = FALSE, labels = c("<1", "1-10", ">=10")))
res <- d |> group_by(group_id, stratum) |> group_modify(function(x, k) {
  s <- unique(x$sp); if (length(s) < 5) return(tibble())
  x <- filter(x, sp %in% sample(s, min(300, length(s))))
  tibble(n_species = n_distinct(x$sp), phi_base = fitphi(x, forms$base), phi_linear = fitphi(x, forms$linear), phi_quadratic = fitphi(x, forms$quadratic))
}) |> ungroup()
print(res, n = 50)
readr::write_csv(res, "sim/rev_phi_trends.csv")
