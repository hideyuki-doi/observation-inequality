# Phase 6：LPI の種構成と体サイズ（暫定：LPD 2016 公開版。2026.1 を入手したら差し替え）
lpd_read <- function(file) readr::read_csv(file, show_col_types = FALSE, guess_max = 20000, locale = readr::locale(encoding = "latin1")) |>
  dplyr::mutate(species = gsub("_", " ", Binomial))

# 哺乳類・鳥類：LPD の種と全種の体重分布の比較（COMBINE / AVONET BirdLife）
lpd_mass_bias <- function(lpd, combine = "data/raw/combine/trait_data_reported.csv", avonet = "data/raw/avonet/AVONET_Supplementary_dataset_1.xlsx") {
  cb <- readr::read_csv(combine, show_col_types = FALSE) |> dplyr::filter(!is.na(adult_mass_g)) |>
    dplyr::distinct(species = iucn2020_binomial, .keep_all = TRUE) |> dplyr::transmute(species, M = adult_mass_g, class = "Mammalia")
  av <- readxl::read_excel(avonet, sheet = "AVONET1_BirdLife") |> dplyr::filter(!is.na(Mass)) |>
    dplyr::transmute(species = Species1, M = Mass, class = "Aves")
  all <- dplyr::bind_rows(cb, av)
  pops <- lpd |> dplyr::filter(Class %in% c("Mammalia", "Aves")) |> dplyr::count(species, name = "n_pop")
  all <- dplyr::left_join(all, pops, by = "species") |> dplyr::mutate(in_lpd = !is.na(n_pop), n_pop = dplyr::coalesce(n_pop, 0L))
  summ <- all |> dplyr::group_by(class) |>
    dplyr::summarise(n_all = dplyr::n(), n_lpd = sum(in_lpd),
                     median_M_all = median(M), median_M_lpd_species = median(M[in_lpd]),
                     median_M_lpd_popweighted = { x <- rep(M[in_lpd], n_pop[in_lpd]); median(x) },
                     ratio_species = median_M_lpd_species / median_M_all,
                     ks_p = suppressWarnings(ks.test(log(M[in_lpd]), log(M[!in_lpd]))$p.value), .groups = "drop")
  bins <- all |> dplyr::mutate(bin = floor(log10(M))) |> dplyr::group_by(class, bin) |>
    dplyr::summarise(n_species = dplyr::n(), share_in_lpd = mean(in_lpd), pops = sum(n_pop), .groups = "drop")
  list(summary = summ, bins = bins)
}

# 綱ごとの LPD 個体群の割合と、センサスの個体数・バイオマスの割合（Bar-On 2018 などの動物グループ）
lpd_class_shares <- function(lpd) {
  lpd |> dplyr::count(Class, name = "n_pop") |> dplyr::mutate(share_pop = n_pop / sum(n_pop)) |>
    dplyr::left_join(lpd |> dplyr::distinct(Class, species) |> dplyr::count(Class, name = "n_species"), by = "Class") |>
    dplyr::arrange(dplyr::desc(n_pop))
}

fig_lpd_mass <- function(mb, out = "figs/phase6_lpd_mass_bias.pdf") {
  p <- ggplot2::ggplot(mb$bins |> dplyr::filter(n_species >= 10), ggplot2::aes(bin + 0.5, share_in_lpd, colour = class)) +
    ggplot2::geom_line() + ggplot2::geom_point(ggplot2::aes(size = n_species)) +
    ggplot2::scale_y_continuous(labels = scales::percent) + ggplot2::scale_size_area(max_size = 3) +
    ggplot2::labs(x = "log10 body mass (g)", y = "share of species with ≥1 LPD population", colour = NULL, size = "species",
                  caption = "PROVISIONAL: LPD 2016 public release (rlpi repository). To be replaced by LPD 2026.1.") +
    ggplot2::theme_bw(9)
  ggplot2::ggsave(out, p, width = 6.5, height = 4.5, device = grDevices::cairo_pdf); out
}
