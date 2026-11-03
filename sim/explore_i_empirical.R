# (i) 探索的：センサスを使わない実証版
# 種ごとの実際の λ（2015–2024 の年平均記録数、化石除く）を、努力量一定の T_detect 格子（方法 a）と比べ、
# 「100 年以内に検出できない」記載種の割合を、線虫から鳥類まで体重に沿って並べる。記録のない記載種は λ = 0
source("sim/explore_common.R")
grid <- readr::read_csv("sim/explore_const_grid.csv", show_col_types = FALSE)
thr <- grid |> group_by(decline) |> arrange(lambda0) |>
  summarise(lambda_never = { i <- max(which(is.infinite(T_a))); sqrt(lambda0[i] * lambda0[i + 1]) },   # 検出不能の上端（隣の格子との幾何平均）
            T_floor = min(T_a))
print(thr)

rec <- tar_read(group_recs); grp <- tar_read(tb_groups); S <- tar_read(p5_S); cm <- tar_read(census_main)
lam <- rec |> semi_join(grp, by = c("group_id", "variant")) |>
  filter(!is.na(specieskey), specieskey != "", year %in% 2015:2024, rtype != "fossil") |>
  group_by(group_id, specieskey) |> summarise(lambda = sum(n) / 10, .groups = "drop")
M <- cm |> filter(role == "main") |> transmute(group_id, log10M = log10(M_g_wet))
inv <- lam |> group_by(group_id) |> summarise(recorded = n(), lam = list(lambda)) |>
  mutate(S = S[group_id], unrecorded = pmax(S - recorded, 0)) |> left_join(M, by = "group_id")
share_below <- function(l, unrec, cut) (sum(l < cut) + unrec) / (length(l) + unrec)
med0 <- function(l, unrec) median(c(l, rep(0, unrec)))
inv_tab <- tidyr::expand_grid(inv, thr) |> rowwise() |>
  mutate(share_never = share_below(lam, unrecorded, lambda_never), median_lambda = med0(lam, unrecorded)) |>
  ungroup() |> select(group_id, log10M, S, recorded, unrecorded, median_lambda, decline, lambda_never, T_floor, share_never)

# 哺乳類（Greenspoon 4,795 種、COMBINE 体重）と鳥類（Callaghan 9,700 種、AVONET 体重）：種ごとの体重で階級化
tA <- function(sp, gy, label) {
  l <- gy |> filter(year %in% 2015:2024, rtype != "fossil") |> group_by(species) |> summarise(lambda = sum(n) / 10)
  sp |> filter(!is.na(M_g)) |> left_join(l, by = c("gbif_name" = "species")) |>
    mutate(lambda = coalesce(lambda, 0), group_id = label, log10M = log10(M_g))
}
vs <- bind_rows(tA(tar_read(mam_sp), tar_read(mam_gy), "mammals"), tA(tar_read(bird_sp), tar_read(bird_gy), "birds"))
vert_tab <- tidyr::expand_grid(vs |> mutate(bin = floor(log10M * 2) / 2 + 0.25), thr) |>
  group_by(group_id, bin, decline) |>
  summarise(n_species = n(), share_never = mean(lambda < first(lambda_never)), median_lambda = median(lambda), .groups = "drop") |>
  filter(n_species >= 20)
vert_all <- tidyr::expand_grid(vs, thr) |> group_by(group_id, decline) |>
  summarise(S = n(), median_lambda = median(lambda), share_never = mean(lambda < first(lambda_never)), .groups = "drop")
print(inv_tab, n = 30); print(vert_all)
readr::write_csv(inv_tab, "sim/explore_empirical_inverts.csv")
readr::write_csv(vert_tab, "sim/explore_empirical_vert_bins.csv")
readr::write_csv(vert_all, "sim/explore_empirical_vert_all.csv")

p <- ggplot2::ggplot() +
  ggplot2::geom_point(data = vert_tab, ggplot2::aes(bin, share_never, colour = group_id, size = n_species), alpha = 0.7) +
  ggplot2::geom_point(data = inv_tab, ggplot2::aes(log10M, share_never), shape = 17, size = 2.5) +
  ggplot2::geom_text(data = dplyr::filter(inv_tab, decline == "30%/10yr"), ggplot2::aes(log10M, share_never, label = group_id), size = 2.3, vjust = -1) +
  ggplot2::facet_wrap(~decline) + ggplot2::scale_y_continuous(labels = scales::percent, limits = c(0, 1)) +
  ggplot2::scale_size_area(max_size = 4) +
  ggplot2::labs(x = "log10 body mass (g)", y = "described species whose decline is undetectable within 100 yr",
                colour = NULL, size = "species in bin",
                caption = "EXPLORATORY (not preregistered). Observed GBIF λ 2015–2024; unrecorded described species λ = 0; method (a), constant effort, φ = 0.69.\nTriangles: invertebrate/small marine groups (group mass); circles: mammal and bird species binned by mass (0.5 log10).") +
  ggplot2::theme_bw(9)
ggplot2::ggsave("figs/explore_empirical_undetectable.pdf", p, width = 10, height = 5, device = grDevices::cairo_pdf)
