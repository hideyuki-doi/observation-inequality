# v4 の図：図の中の説明文は入れない（説明はすべて legend に書く）。Times New Roman で統一
theme_v4 <- function() ggplot2::theme_bw(10, base_family = "Times New Roman") + ggplot2::theme(panel.grid.minor = ggplot2::element_blank())
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
