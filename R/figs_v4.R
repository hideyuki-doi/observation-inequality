# v4 の図：図の中の説明文は入れない（説明はすべて legend に書く）。フォントは Helvetica
theme_v4 <- function() ggplot2::theme_bw(10, base_family = "Helvetica") + ggplot2::theme(panel.grid.minor = ggplot2::element_blank())
save_v4 <- function(p, out, w, h) { ggplot2::ggsave(out, p, width = w, height = h, device = grDevices::cairo_pdf)
  ggplot2::ggsave(sub("pdf$", "png", out), p, width = w, height = h, dpi = 200); out }

# 図1：解析に使った GBIF 記録の世界分布（1° セル、2000–2024）
fig_v4_map <- function(out = "figs/v4_fig1_map.pdf") {
  coast <- readr::read_csv("docs/ne_coastline_110m.csv", show_col_types = FALSE)
  d <- arrow::open_dataset("data/derived/gbif_cells/parts") |> dplyr::filter(year >= 2000, year <= 2024) |>
    dplyr::mutate(set = ifelse(group_id == "mammals", "Mammals", "Ten invertebrate and fish groups")) |>
    dplyr::group_by(set, cell) |> dplyr::summarise(n = sum(n)) |> dplyr::collect() |>
    tidyr::separate(cell, c("lat", "lon"), sep = "_", convert = TRUE) |> dplyr::mutate(lat = lat + 0.5, lon = lon + 0.5)
  d$set <- factor(d$set, c("Ten invertebrate and fish groups", "Mammals"))
  p <- ggplot2::ggplot(d, ggplot2::aes(lon, lat)) + ggplot2::geom_tile(ggplot2::aes(fill = log10(n)), width = 1, height = 1) +
    ggplot2::geom_path(data = coast, ggplot2::aes(lon, lat, group = id), colour = "grey35", linewidth = 0.15) +
    ggplot2::scale_fill_viridis_c(name = expression(log[10]~records), option = "viridis") +
    ggplot2::coord_equal(xlim = c(-180, 180), ylim = c(-80, 85), expand = FALSE) +
    ggplot2::facet_wrap(~set, ncol = 1) + ggplot2::labs(x = NULL, y = NULL) + theme_v4() +
    ggplot2::theme(strip.background = ggplot2::element_blank(), strip.text = ggplot2::element_text(face = "bold", hjust = 0))
  save_v4(p, out, 8, 8.2)
}

# 図3（改）：DNA 由来記録と人の観察記録の比。土壌と海洋で色分け、体重の 95% 信用区間、回帰の信頼帯、重ならないラベル
fig_v4_dna <- function(tab, pts, h4, out = "figs/v4_fig3_dna.pdf") {
  soil <- c("soil_nematodes", "mites", "springtails", "enchytraeids", "ants")
  lab <- c(soil_nematodes = "Nematodes", mites = "Mites", copepods = "Copepods", springtails = "Springtails", enchytraeids = "Enchytraeids",
           ants = "Ants", pteropods = "Pteropods", jellyfish = "Jellyfish", krill = "Antarctic krill", mesopelagic_fish = "Mesopelagic fishes")
  m <- dplyr::filter(pts, analysis == "main", type == "all") |> dplyr::select(group_id = label, log10M_med, log10M_lo, log10M_hi)
  d <- tab |> dplyr::left_join(m, by = "group_id") |>
    dplyr::mutate(`Metabarcoding and environmental DNA` = log10((dna_metabarcoding + 0.5) / (human_obs + 0.5)),
                  `Specimen barcodes (iBOL)` = log10((dna_barcode + 0.5) / (human_obs + 0.5)),
                  habitat = ifelse(group_id %in% soil, "Soil", "Marine")) |>
    tidyr::pivot_longer(c(`Metabarcoding and environmental DNA`, `Specimen barcodes (iBOL)`), names_to = "type", values_to = "y")
  sl <- h4 |> dplyr::filter(grepl("metabarcoding|barcode", contrast)) |>
    dplyr::mutate(type = ifelse(grepl("metabarcoding", contrast), "Metabarcoding and environmental DNA", "Specimen barcodes (iBOL)"),
                  txt = sprintf("slope %.2f (95%% CI %.2f to %.2f)", slope, lo, hi))
  p <- ggplot2::ggplot(d, ggplot2::aes(log10M_med, y)) +
    ggplot2::geom_hline(yintercept = 0, colour = "grey75", linewidth = 0.4) +
    ggplot2::geom_smooth(method = "lm", formula = y ~ x, colour = "grey20", fill = "grey80", linewidth = 0.7) +
    ggplot2::geom_errorbarh(ggplot2::aes(xmin = log10M_lo, xmax = log10M_hi, colour = habitat), height = 0, alpha = 0.6, linewidth = 0.5) +
    ggplot2::geom_point(ggplot2::aes(fill = habitat), shape = 21, size = 3.2, colour = "white", stroke = 0.5) +
    ggrepel::geom_text_repel(ggplot2::aes(label = lab[group_id]), size = 3.3, family = "Helvetica", seed = 1, min.segment.length = 0.2,
                             box.padding = 0.45, max.overlaps = Inf, colour = "grey15") +
    ggplot2::geom_text(data = sl, ggplot2::aes(x = -Inf, y = Inf, label = txt), hjust = -0.04, vjust = 1.6, size = 3.4, family = "Helvetica", inherit.aes = FALSE) +
    ggplot2::scale_fill_manual(values = c(Soil = "#a6611a", Marine = "#2c7bb6"), name = NULL) +
    ggplot2::scale_colour_manual(values = c(Soil = "#a6611a", Marine = "#2c7bb6"), guide = "none") +
    ggplot2::scale_x_continuous(expand = ggplot2::expansion(mult = 0.08)) +
    ggplot2::facet_wrap(~type, ncol = 2) +
    ggplot2::labs(x = expression(Typical~body~mass~(log[10]~g)), y = expression(DNA*"-"*derived~"/"~human~observation~records~(log[10]))) +
    ggplot2::theme_bw(12, base_family = "Helvetica") +
    ggplot2::theme(panel.grid.minor = ggplot2::element_blank(), strip.background = ggplot2::element_blank(),
                   strip.text = ggplot2::element_text(face = "bold", hjust = 0, size = 12), legend.position = "bottom")
  save_v4(p, out, 10, 5.2)
}
