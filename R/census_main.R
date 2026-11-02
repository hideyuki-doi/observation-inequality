# Phase 1→2: 主解析用センサス表（docs/census_main_selection.csv の選択と換算係数を適用）
build_census_main <- function(census, selection_file) {
  sel <- readr::read_csv(selection_file, col_types = "ccccdc")
  num <- function(x) suppressWarnings(as.numeric(x))
  x <- sel |> dplyr::left_join(census, by = c("part", "group"), relationship = "many-to-many")
  # 同じラベルが単位違いで2行ある場合（トビムシ）は、換算の前提に合う単位の行を残す
  x <- x |> dplyr::filter(!(group_id == "springtails" & role == "main" & B_unit != "Mt C"),
                          !(group_id == "springtails" & role == "sens_rosenberg" & B_unit != "Mt dry weight"))
  stopifnot(nrow(x) == nrow(sel))
  x |> dplyr::transmute(group_id, role, part, group, method_class, verified,
                        N = num(N_est), N_lo = num(N_lo), N_hi = num(N_hi), N_interval_type,
                        B_g_wet = num(B_est) * to_g_wet, B_lo_g_wet = num(B_lo) * to_g_wet, B_hi_g_wet = num(B_hi) * to_g_wet,
                        B_interval_type, B_unit_source = B_unit, conversion_note,
                        M_g_wet = B_g_wet / N, n_described_species, citation, doi)
}
