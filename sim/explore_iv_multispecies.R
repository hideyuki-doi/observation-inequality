# (iv) 探索的：K 種をまとめた指標での検出時間（全種が同じ率で減少、努力量一定、方法 a 相当）
# プール NB-GLM：y ~ factor(species) + t。種間の年変動は独立と仮定（共通の年ショックがあれば楽観的）
source("sim/explore_common.R")
phi <- readr::read_csv("sim/phi_estimate.csv", show_col_types = FALSE)$phi_med
pow_multi <- function(T, K, lambda0, d, n_rep, seed) {
  set.seed(seed)
  sp <- factor(rep(seq_len(K), each = T)); t <- rep(seq_len(T), K)
  mu <- lambda0 * exp(-d * (t - 1))
  mean(replicate(n_rep, {
    y <- rnbinom(length(mu), size = phi, mu = mu)
    if (sum(y) == 0) return(FALSE)
    f <- tryCatch(suppressWarnings(if (K == 1) MASS::glm.nb(y ~ t) else MASS::glm.nb(y ~ sp + t)), error = function(e) NULL)   # 1 水準の因子は不可
    if (is.null(f)) return(FALSE)
    s <- summary(f)$coefficients["t", ]; s[1] / s[2] < qnorm(0.05)
  }))
}
tdet_multi <- function(K, lambda0, d, n_rep = 200) {
  cache <- list(); pw <- function(T) { k <- as.character(T); if (is.null(cache[[k]])) cache[[k]] <<- pow_multi(T, K, lambda0, d, n_rep, 20261103 + T); cache[[k]] }
  if (pw(100) < 0.8) return(Inf); if (pw(3) >= 0.8) return(3)
  lo <- 3; hi <- 100; while (hi - lo > 1) { m <- (lo + hi) %/% 2; if (pw(m) >= 0.8) hi <- m else lo <- m }; hi
}
jobs <- expand_grid(K = c(1, 10, 100), lambda0 = c(0.3, 1, 10, 100), decline = c("30%/10yr", "50%/10yr")) |>
  mutate(d = ifelse(decline == "30%/10yr", -log(0.7) / 10, -log(0.5) / 10))
jobs$T_detect <- unlist(parallel::mclapply(seq_len(nrow(jobs)), \(i) tdet_multi(jobs$K[i], jobs$lambda0[i], jobs$d[i]),
                                           mc.cores = 20, mc.preschedule = FALSE))
print(jobs, n = 30)
readr::write_csv(jobs, "sim/explore_multispecies.csv")
