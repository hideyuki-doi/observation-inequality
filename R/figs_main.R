# Phase 7：主図（すべてコードから生成）
theme_main <- function() ggplot2::theme_bw(9) + ggplot2::theme(panel.grid.minor = ggplot2::element_blank())
lab_group <- c(soil_nematodes = "Soil nematodes", mites = "Mites", copepods = "Copepods", springtails = "Springtails",
               enchytraeids = "Enchytraeids", ants = "Ants", pteropods = "Pteropods", jellyfish = "Jellyfish",
               krill = "Antarctic krill", mesopelagic_fish = "Mesopelagic fish", birds_callaghan = "Birds*",
               mammals_greenspoon_all = "Land mammals*", bacteria = "Bacteria†", archaea = "Archaea†")

# 図1：全記録の r–M スケーリング（主10グループ + 主解析外の点）と、記録の種類別の β の事後分布
fig_main1 <- function(res, pts, vert = NULL, out = "figs/main_1_scaling.pdf") {
  d <- dplyr::filter(pts, analysis == "main", type == "all")
  ex <- dplyr::filter(pts, type == "all", (analysis == "S9_add_birds_mammals" & label %in% c("birds_callaghan", "mammals_greenspoon_all")) |
                                          (analysis == "S12_add_prokaryotes" & label %in% c("bacteria", "archaea")))
  dr <- res$draws; c0 <- res$data$lnM_c; k <- match("all", res$types)
  grid <- seq(-14.5, if (is.null(vert)) 5 else 8.5, length.out = 150)
  m <- sapply(grid * log(10), \(x) dr[[sprintf("a[%d]", k)]] + dr[[sprintf("b[%d]", k)]] * (x - c0)) / log(10)
  band <- tibble::tibble(x = grid, med = apply(m, 2, median), lo = apply(m, 2, quantile, .025), hi = apply(m, 2, quantile, .975),
                         inrange = grid >= min(d$log10M_lo) & grid <= max(d$log10M_hi))
  opt <- tibble::tibble(x = grid, y = median(dr[[sprintf("a[%d]", k)]]) / log(10) + 2/3 * (grid - c0 / log(10)))
  pa <- ggplot2::ggplot() +
    ggplot2::geom_ribbon(data = band, ggplot2::aes(x, ymin = lo, ymax = hi), alpha = 0.15) +
    ggplot2::geom_line(data = band, ggplot2::aes(x, med, linetype = inrange), show.legend = FALSE) +
    ggplot2::scale_linetype_manual(values = c(`TRUE` = 1, `FALSE` = 3)) +
    ggplot2::geom_line(data = opt, ggplot2::aes(x, y), colour = "grey50", linetype = 2) +
    ggplot2::geom_errorbar(data = d, ggplot2::aes(x = log10M_med, ymin = log10r_lo, ymax = log10r_hi), width = 0, colour = "grey40") +
    ggplot2::geom_point(data = d, ggplot2::aes(log10M_med, log10r_med), size = 1.8) +
    ggplot2::geom_text(data = d, ggplot2::aes(log10M_med, log10r_med, label = lab_group[label]), size = 2.4, hjust = -0.1, vjust = 1.4) +
    { if (!is.null(vert)) ggplot2::geom_point(data = vert, ggplot2::aes(log10M, log10r, colour = set), size = 0.9, alpha = 0.6) } +
    { if (!is.null(vert)) ggplot2::scale_colour_manual(values = c(census_independent = "#1f78b4", report_land = "#a6cee3"),
        labels = c("Marine mammals & megafauna, survey census", "Land mammals, reported populations"), name = "Species (exploratory)") } +
    ggplot2::geom_point(data = ex, ggplot2::aes(log10M_med, log10r_med), shape = 1, colour = "firebrick", size = 2) +
    ggplot2::geom_text(data = ex, ggplot2::aes(log10M_med, log10r_med, label = lab_group[label]), size = 2.4, colour = "firebrick", vjust = -0.9) +
    ggplot2::labs(x = expression(log[10]~"body mass (g)"), y = expression(log[10]~"GBIF records per individual, 2000–2024"), tag = "a") + theme_main() + ggplot2::theme(legend.position = c(0.3, 0.82), legend.background = ggplot2::element_blank())
  bd <- purrr::map(res$types, \(t) tibble::tibble(type = t, b = dr[[sprintf("b[%d]", match(t, res$types))]])) |> purrr::list_rbind() |>
    dplyr::mutate(type = factor(type, c("all", "human_obs", "specimen", "dna"), c("All records", "Human observation", "Specimen", "DNA-derived")))
  pb <- ggplot2::ggplot(bd, ggplot2::aes(b, type)) + ggplot2::geom_violin(fill = "grey85", scale = "width") +
    ggplot2::stat_summary(fun = median, geom = "point") + ggplot2::geom_vline(xintercept = 2/3, linetype = 2, colour = "grey50") +
    ggplot2::labs(x = expression("scaling exponent"~beta), y = NULL, tag = "b") + theme_main()
  p <- patchwork::wrap_plots(pa, pb, widths = c(2.2, 1)) +
    patchwork::plot_annotation(caption = "Black: ten groups with census N independent of occurrence data (main fit, 95% CrI). Dashed grey: slope 2/3 (optical expectation).\nRed open, not fitted: *census derived from occurrence data or allometry (sensitivity S9); †DNA-only records (S12).\nBlue: individual mammal species with census independent of occurrence data (exploratory; Greenspoon 2025 surveys, rhino/elephant counts, IUCN reports).")
  ggplot2::ggsave(out, p, width = 10, height = 4.8, device = grDevices::cairo_pdf); out
}

# 図2：検出の下限（a）と、検出不能な種の体サイズ勾配（b、探索的・センサス不要）
fig_main2 <- function(const_grid, inv_tab, vert_bins, out = "figs/main_2_detection.pdf") {
  g <- const_grid |> dplyr::mutate(T = pmin(T_a, 105))
  pa <- ggplot2::ggplot(g, ggplot2::aes(log10(lambda0), T, colour = decline)) + ggplot2::geom_step(direction = "mid") +
    ggplot2::geom_hline(yintercept = 25, linetype = 3) +
    ggplot2::annotate("text", x = -1.9, y = 103, label = "not detectable within 100 yr", hjust = 0, size = 2.4) +
    ggplot2::scale_colour_manual(values = c("black", "grey55")) +
    ggplot2::labs(x = expression(log[10]~"records per species-year"~(lambda[0])), y = "years to detect decline (power 0.8)",
                  colour = NULL, tag = "a") + theme_main() + ggplot2::theme(legend.position = c(0.7, 0.75))
  inv <- dplyr::filter(inv_tab, decline == "30%/10yr"); vb <- dplyr::filter(vert_bins, decline == "30%/10yr")   # inv_tab は各グループ自身の φ
  pb <- ggplot2::ggplot() +
    ggplot2::geom_point(data = vb, ggplot2::aes(bin, share_never, colour = group_id, size = n_species), alpha = 0.75) +
    ggplot2::geom_point(data = inv, ggplot2::aes(log10M, share_never), shape = 17, size = 2.2) +
    ggplot2::geom_text(data = inv, ggplot2::aes(log10M, share_never, label = lab_group[group_id]), size = 2.3, vjust = -1) +
    ggplot2::scale_colour_manual(values = c(birds = "#d95f02", mammals = "#1b9e77"), labels = c("Bird species (binned)", "Mammal species (binned)")) +
    ggplot2::scale_size_area(max_size = 3.5, guide = "none") +
    ggplot2::scale_y_continuous(labels = scales::percent, limits = c(0, 1)) +
    ggplot2::labs(x = expression(log[10]~"body mass (g)"), y = "described species whose 30%/10-yr decline\nis undetectable within 100 yr", colour = NULL, tag = "b") +
    theme_main() + ggplot2::theme(legend.position = c(0.75, 0.85))
  p <- patchwork::wrap_plots(pa, pb, widths = c(1, 1.4)) +
    patchwork::plot_annotation(caption = "(a) NB-GLM with effort offset, constant effort, φ = 0.69 (mammal species-year records). (b) Exploratory: observed GBIF λ (2015–2024 mean),\ndescribed species without records λ = 0; triangles use each group's own φ (by record-rate stratum), mammals and birds use φ = 0.69.")
  ggplot2::ggsave(out, p, width = 10, height = 4.6, device = grDevices::cairo_pdf); out
}

# 図3：帰結（H5 と LPI の体重バイアス、いずれも探索的／暫定）
fig_main3 <- function(h5, lpd_bins, out = "figs/main_3_consequences.pdf") {
  d <- dplyr::filter(h5, sigma10 == 1.5)
  pa <- ggplot2::ggplot(d, ggplot2::aes(log10M)) +
    ggplot2::geom_pointrange(ggplot2::aes(y = pred_never_recorded_med, ymin = pred_lo, ymax = pred_hi, colour = factor(T_years)),
                             position = ggplot2::position_dodge(width = 0.35), size = 0.25) +
    ggplot2::geom_point(ggplot2::aes(y = lit_undescribed_frac), shape = 4, size = 2.5) +
    ggplot2::geom_text(ggplot2::aes(y = lit_undescribed_frac, label = lab_group[group_id]), size = 2.3, vjust = -1.1) +
    ggplot2::scale_colour_manual(values = c(`25` = "black", `250` = "grey55"), labels = c("25 yr", "250 yr")) +
    ggplot2::scale_y_continuous(labels = scales::percent, limits = c(0, 1)) +
    ggplot2::labs(x = expression(log[10]~"body mass (g)"), y = "share of species", colour = "predicted never recorded", tag = "a") +
    theme_main() + ggplot2::theme(legend.position = c(0.3, 0.2))
  pb <- ggplot2::ggplot(dplyr::filter(lpd_bins, n_species >= 10), ggplot2::aes(bin + 0.5, share_in_lpd, colour = class)) +
    ggplot2::geom_line() + ggplot2::geom_point() + ggplot2::scale_y_continuous(labels = scales::percent) +
    ggplot2::scale_colour_manual(values = c(Aves = "#d95f02", Mammalia = "#1b9e77"), labels = c("Birds", "Mammals")) +
    ggplot2::labs(x = expression(log[10]~"body mass (g)"), y = "species with ≥1 Living Planet population", colour = NULL, tag = "b") +
    theme_main() + ggplot2::theme(legend.position = c(0.2, 0.85))
  p <- patchwork::wrap_plots(pa, pb) +
    patchwork::plot_annotation(caption = "Exploratory. (a) ×: literature share undescribed (1 − described/estimated total; Chapman 2009, Appeltans 2012, Oberski 2025).\n(b) Living Planet Database, 2016 public release (rlpi repository).")
  ggplot2::ggsave(out, p, width = 10, height = 4.6, device = grDevices::cairo_pdf); out
}

# 補足図：記録数ベースと占有ベース（1° セル）の検出年数
fig_occupancy <- function(occ, out = "figs/supp_occupancy_vs_records.pdf") {
  d <- occ |> dplyr::mutate(T = pmin(T_detect, 105), index = factor(index, c("records", "occupied_cells"), c("Record counts", "Occupied 1° cells")),
                            stratum = factor(stratum, c("<1", "1-10", ">=10"), c("<1 rec/yr", "1–10", "≥10")))
  p <- ggplot2::ggplot(d, ggplot2::aes(stratum, T, colour = index, group = index)) +
    ggplot2::geom_point(position = ggplot2::position_dodge(width = 0.4)) +
    ggplot2::facet_wrap(~ lab_group[ifelse(group_id == "mammals", "mammals_greenspoon_all", group_id)] |> sub("\\*", "", x = _), nrow = 2) +
    ggplot2::geom_hline(yintercept = 100, linetype = 3) +
    ggplot2::scale_colour_manual(values = c("black", "#1f78b4")) +
    ggplot2::labs(x = "species stratum by mean GBIF records per year", y = "years to detect 30%/10-yr decline (105 = never)", colour = NULL,
                  caption = "Exploratory. φ estimated separately for each index (NB, species + year effects). Occupancy index assumed to decline in proportion to abundance (optimistic).") +
    theme_main()
  ggplot2::ggsave(out, p, width = 10, height = 5, device = grDevices::cairo_pdf); out
}
