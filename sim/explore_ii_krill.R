# (ii) 探索的：種数 1 のグループ（オキアミ）では SAD を外して H3 の写像をやり直す（主：方法 a、σ = 1.5）
source("sim/explore_common.R")
tar_load(c(tb_main, p5_grid_main, p5_eff, p5_S))
mp <- map_tdetect(tb_main, p5_grid_main, p5_eff, p5_S, sigma10 = 1.5, Tcol = "T_a", no_sad_single = TRUE)
h <- h3_summary(mp, tb_main$lnM_obs)
print(h$tercile); print(group_undetect(mp) |> filter(group_id == "krill"))
readr::write_csv(mutate(h$tercile, variant = "no_SAD_for_single_species"), "sim/explore_krill_noSAD.csv")
