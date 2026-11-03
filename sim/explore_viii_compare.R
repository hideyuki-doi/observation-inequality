# 探索的：記録数ベースと占有ベースの検出年数（努力量一定、30%/10 年）。占有指標が個体数に比例して減ると仮定（楽観的）
source("sim/explore_common.R")
o <- readr::read_csv("sim/explore_occupancy_phi.csv", show_col_types = FALSE) |> filter(!is.na(phi_rec), !is.na(phi_occ))
e <- const_eff(); d <- -log(0.7) / 10
jobs <- bind_rows(o |> transmute(group_id, stratum, index = "records", lambda = mean_rec, phi = phi_rec),
                  o |> transmute(group_id, stratum, index = "occupied_cells", lambda = mean_occ, phi = phi_occ))
jobs$T_detect <- unlist(parallel::mclapply(seq_len(nrow(jobs)), \(i) t_detect_all(jobs$lambda[i], e$E_flat, e$G, d, jobs$phi[i])[["T_a"]],
                                           mc.cores = 20, mc.preschedule = FALSE))
out <- jobs |> select(group_id, stratum, index, T_detect) |> pivot_wider(names_from = index, values_from = T_detect)
print(out, n = 40); readr::write_csv(jobs, "sim/explore_occupancy_tdetect.csv")

# （3）グループ自身の φ での「100 年以内に検出不能な記載種の割合」
g <- readr::read_csv("sim/explore_group_phi_grid.csv", show_col_types = FALSE)
thr <- g |> group_by(group_id, decline) |> arrange(lambda0) |>
  summarise(lambda_never = { i <- suppressWarnings(max(which(is.infinite(T_a)))); if (is.finite(i)) sqrt(lambda0[i] * lambda0[min(i + 1, n())]) else 0 },
            T_floor = min(T_a), .groups = "drop")
inv <- readr::read_csv("sim/explore_empirical_inverts.csv", show_col_types = FALSE) |> filter(decline == "30%/10yr") |> select(group_id, log10M, S, recorded)
rec <- tar_read(group_recs); grp <- tar_read(tb_groups)
lam <- rec |> semi_join(grp, by = c("group_id", "variant")) |> filter(!is.na(specieskey), specieskey != "", year %in% 2015:2024, rtype != "fossil") |>
  group_by(group_id, specieskey) |> summarise(lambda = sum(n) / 10, .groups = "drop")
res <- inv |> left_join(thr, by = "group_id", relationship = "many-to-many") |> rowwise() |>
  mutate(share_never = { l <- lam$lambda[lam$group_id == group_id]; (sum(l < lambda_never) + max(S - length(l), 0)) / max(S, length(l)) }) |> ungroup()
print(res |> arrange(decline, log10M), n = 30)
readr::write_csv(res, "sim/explore_empirical_groupphi.csv")
