# 改訂（Reviewer 3）：H4 の比のモデル。体重の不確実性（モンテカルロ）と回帰の残差（係数の標本分布）の両方を伝播させる
source("sim/explore_common.R")
tar_load(tb_obs); tab <- readr::read_csv("sim/rev_events_datasets.csv", show_col_types = FALSE)
labs <- sort(unique(tb_obs$label)); ord <- match(labs, tab$group_id)
set.seed(20261103)
h4 <- purrr::map(c("dna_all", "dna_barcode", "dna_metabarcoding", "specimen"), function(k) {
  num <- if (k == "dna_all") tab$dna_barcode + tab$dna_metabarcoding else tab[[k]]
  y <- log10((num[ord] + 0.5) / (tab$human_obs[ord] + 0.5))
  b <- replicate(4000, { v <- tb_obs$val + rnorm(nrow(tb_obs), 0, tb_obs$sd)
    lm_ <- vapply(labs, \(l) { o <- tb_obs$type[tb_obs$label == l]; x <- v[tb_obs$label == l]; if (any(o == 3)) x[o == 3] else x[o == 2] - x[o == 1] }, 0) / log(10)
    s <- summary(lm(y ~ lm_))$coefficients; s[2, 1] + s[2, 2] * rt(1, df = length(y) - 2) })
  tibble(contrast = paste0(k, " / human_obs"), slope = median(b), lo = quantile(b, .025), hi = quantile(b, .975), P_lt0 = mean(b < 0))
}) |> bind_rows()
print(h4); readr::write_csv(h4, "sim/rev_h4_contrast.csv")
