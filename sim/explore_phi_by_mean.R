# 探索的（PREREG 外）：φ が種の平均記録数によって変わるかの診断。報告ベースの哺乳類、2000–2024
library(targets); library(dplyr)
tar_load(c(mam_sp, mam_gy))
sp <- unique(mam_sp$gbif_name[mam_sp$report_based & !is.na(mam_sp$gbif_name)])
d <- mam_gy |> filter(species %in% sp, year %in% 2000:2024, rtype != "fossil") |>
  group_by(species, year) |> summarise(y = sum(n), .groups = "drop") |>
  tidyr::complete(species = sp, year = 2000:2024, fill = list(y = 0)) |>
  group_by(species) |> mutate(m = mean(y)) |> ungroup() |> filter(m > 0)
d$stratum <- cut(log10(d$m), c(-Inf, 0, 1, 2, 3, Inf), labels = c("<1", "1-10", "10-100", "100-1000", ">1000"))
res <- d |> group_by(stratum) |> group_modify(function(x, k) {
  f <- MASS::glm.nb(y ~ 0 + factor(species) + factor(year), data = x)
  tibble(n_species = n_distinct(x$species), theta = f$theta, theta_se = f$SE.theta)
})
print(res)
write.csv(res, "sim/explore_phi_by_mean.csv", row.names = FALSE)
