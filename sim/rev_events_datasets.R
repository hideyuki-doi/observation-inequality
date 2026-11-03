# 改訂（Reviewers 1, 2, 3）：イベント単位の応答、データセットの偏り、DNA の内訳を一度に確認する
source("sim/explore_common.R")
tar_load(c(tb_obs, p5_S, tb_R))
meta <- readr::read_csv("data/derived/dna_dataset_types.csv", show_col_types = FALSE) |>
  mutate(dna_type = ifelse(grepl("EUKARYOME|reference database", title), "reference_db", dna_type))
grp <- c("soil_nematodes", "springtails", "mites", "ants", "enchytraeids", "copepods", "pteropods", "jellyfish", "mesopelagic_fish", "krill")
rec <- arrow::open_dataset("data/derived/gbif_events/records") |> filter(year >= 2000, year <= 2024) |> collect() |>
  filter(group_id %in% grp) |>
  # 中深層魚は主解析と同じハダカイワシ科に揃える（15 科版は範囲修正の感度分析で扱った）
  filter(group_id != "mesopelagic_fish" | family == "Myctophidae") |>
  left_join(select(meta, datasetkey, dna_type), by = "datasetkey") |>
  mutate(rtype = case_when(ds_class == "dna_ext" & dna_type == "barcode_specimen" ~ "dna_barcode",
                           ds_class == "dna_ext" & dna_type == "reference_db" ~ "dna_reference",
                           ds_class == "dna_ext" ~ "dna_metabarcoding",
                           basisofrecord == "HUMAN_OBSERVATION" ~ "human_obs", basisofrecord == "PRESERVED_SPECIMEN" ~ "specimen", TRUE ~ "other"))
# (1) データセットの偏り：上位 3 データセットの割合と、それを除いた記録数
ds <- rec |> group_by(group_id, datasetkey) |> summarise(n = sum(n), .groups = "drop") |> group_by(group_id) |> arrange(desc(n), .by_group = TRUE) |>
  summarise(R = sum(n), top1 = n[1] / sum(n), top3 = sum(head(n, 3)) / sum(n), R_minus_top3 = sum(n) - sum(head(n, 3)), n_datasets = n())
# (2) イベント単位（種 × データセット × 0.1° × 日付 の一意な組）
ev <- arrow::open_dataset("data/derived/gbif_events/events") |> filter(year >= 2000, year <= 2024) |>
  filter(group_id %in% grp) |> select(group_id, family, specieskey, datasetkey, cell01, date) |> collect() |>
  filter(group_id != "mesopelagic_fish" | family == "Myctophidae") |> distinct(group_id, specieskey, datasetkey, cell01, date) |> count(group_id, name = "R_events")
types <- rec |> group_by(group_id, rtype) |> summarise(n = sum(n), .groups = "drop") |> pivot_wider(names_from = rtype, values_from = n, values_fill = 0)
tab <- ds |> left_join(ev, by = "group_id") |> left_join(types, by = "group_id")
print(tab, width = 220); readr::write_csv(tab, "sim/rev_events_datasets.csv")

# 自由係数モデルを、応答だけ替えて当てはめ直す
labs <- sort(unique(tb_obs$label)); S <- p5_S[labs]; S["jellyfish"] <- 297   # 箱虫類を加える（QA で不一致を修正）
lnM_obs <- vapply(labs, \(l) { o <- tb_obs[tb_obs$label == l, ]; if (any(o$type == 3)) o$val[o$type == 3] else o$val[o$type == 2] - o$val[o$type == 1] }, 0)
lnN_obs <- vapply(labs, \(l) { o <- tb_obs[tb_obs$label == l, ]; if (any(o$type == 1)) o$val[o$type == 1] else o$val[o$type == 2] - o$val[o$type == 3] }, 0)
m <- cmdstanr::cmdstan_model("models/tierB_free.stan")
fit_free <- function(R, name) {
  dd <- list(G = length(labs), J = nrow(tb_obs), P = 1, obs_g = match(tb_obs$label, labs), obs_type = tb_obs$type, obs_val = tb_obs$val, obs_sd = tb_obs$sd,
             R = R, X = matrix(log(S) - mean(log(S)), ncol = 1), cN = mean(lnN_obs), cM = mean(lnM_obs), prior_lnN_mu = 40, prior_lnM_mu = -8)
  f <- m$sample(dd, seed = 20261103, chains = 4, parallel_chains = 4, iter_warmup = 1000, iter_sampling = 2000, adapt_delta = 0.99, refresh = 0, show_messages = FALSE)
  dr <- posterior::as_draws_df(f$draws(c("gamma", "delta", "eta[1]")))
  tibble(response = name, param = c("gamma (lnN)", "delta (lnM)", "lnS"), med = sapply(dr[1:3], median), lo = sapply(dr[1:3], quantile, .025),
         hi = sapply(dr[1:3], quantile, .975), P_gt0 = sapply(dr[1:3], \(v) mean(v > 0)))
}
ord <- match(labs, tab$group_id)
fr <- bind_rows(fit_free(tab$R_events[ord], "species-events"), fit_free(tab$R_minus_top3[ord], "records without top-3 datasets"))
print(fr); readr::write_csv(fr, "sim/rev_events_free_exponent.csv")

# (3) H4：DNA と人の観察の比（個体数が消える）を体重に回帰。センサスの不確実性はモンテカルロで伝播
set.seed(20261103)
h4 <- purrr::map(c("dna_all", "dna_barcode", "dna_metabarcoding", "specimen"), function(k) {
  num <- if (k == "dna_all") tab$dna_barcode + tab$dna_metabarcoding else tab[[k]]
  y <- log10((num[ord] + 0.5) / (tab$human_obs[ord] + 0.5))
  b <- replicate(2000, { v <- tb_obs$val + rnorm(nrow(tb_obs), 0, tb_obs$sd)
    lm_ <- vapply(labs, \(l) { o <- tb_obs$type[tb_obs$label == l]; x <- v[tb_obs$label == l]; if (any(o == 3)) x[o == 3] else x[o == 2] - x[o == 1] }, 0)
    coef(lm(y ~ I(lm_ / log(10))))[2] })
  tibble(contrast = paste0(k, " / human_obs"), slope = median(b), lo = quantile(b, .025), hi = quantile(b, .975), P_lt0 = mean(b < 0),
         groups_with_zero_numerator = sum(num[ord] == 0))
}) |> bind_rows()
print(h4)   # 正式な区間（残差を含む）は sim/rev_h4_contrast.R が書く。ここでは保存しない
