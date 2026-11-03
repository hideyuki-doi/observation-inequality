# (iii) 探索的：無脊椎動物ほかのグループでの φ（NB、species + year 固定効果、2000–2024）
# 平均記録数の層（<1, 1–10, ≥10 件/年）ごと、各層最大 300 種（seed 固定で抽出）
source("sim/explore_common.R")
set.seed(20261103)
rec <- tar_read(group_recs); grp <- tar_read(tb_groups)
d <- rec |> semi_join(grp, by = c("group_id", "variant")) |>
  filter(!is.na(specieskey), specieskey != "", year %in% 2000:2024, rtype != "fossil") |>
  group_by(group_id, specieskey, year) |> summarise(y = sum(n), .groups = "drop") |>
  group_by(group_id) |> complete(specieskey, year = 2000:2024, fill = list(y = 0)) |>
  group_by(group_id, specieskey) |> mutate(m = mean(y)) |> ungroup() |>
  mutate(stratum = cut(m, c(0, 1, 10, Inf), right = FALSE, labels = c("<1", "1-10", ">=10")))
res <- d |> group_by(group_id, stratum) |> group_modify(function(x, k) {
  sp <- unique(x$specieskey); if (length(sp) < 5) return(tibble())
  x <- filter(x, specieskey %in% sample(sp, min(300, length(sp))))
  f <- tryCatch(MASS::glm.nb(y ~ 0 + factor(specieskey) + factor(year), data = x), error = function(e) NULL)
  if (is.null(f)) return(tibble(n_species = n_distinct(x$specieskey), theta = NA, theta_se = NA))
  tibble(n_species = n_distinct(x$specieskey), theta = f$theta, theta_se = f$SE.theta)
}) |> ungroup()
print(res, n = 40)
readr::write_csv(res, "sim/explore_phi_inverts.csv")
