# 改訂（Reviewers 3, 4）：検出の下限の解析式、自己相関の影響、IUCN の 10 年窓での指標
source("sim/explore_common.R")
za <- qnorm(0.95); zb <- qnorm(0.8)
# (1) 解析式：大きな λ では var(ln y) ≈ 1/φ（+ 1/λ）。T 年の線形回帰の傾きの精度は T(T²−1)/12
T_floor <- function(phi, d, lambda = Inf) { s2 <- 1 / phi + 1 / lambda; uniroot(\(T) T * (T^2 - 1) / 12 - s2 * ((za + zb) / d)^2, c(2, 1e4))$root }
d30 <- -log(0.7) / 10; d50 <- -log(0.5) / 10
an <- expand_grid(phi = c(0.06, 0.12, 0.25, 0.5, 0.69, 1, 1.33, 2, 4, 6), lambda = c(1, 10, 100, Inf)) |>
  mutate(T30 = mapply(T_floor, phi, d30, lambda), T50 = mapply(T_floor, phi, d50, lambda),
         # 10 年で検出力 0.8 を得られる最小の減少率（10 年あたり）、検出時点で失われている割合（30%/10 年の場合）
         min_decline_10yr = 1 - exp(-10 * (za + zb) * sqrt((1 / phi + 1 / lambda) * 12 / (10 * (10^2 - 1)))),
         lost_at_detection_30 = 1 - exp(-d30 * T30))
print(an |> filter(lambda %in% c(10, Inf)), n = 30)
readr::write_csv(an, "sim/rev_detection_analytic.csv")
# シミュレーション格子（φ = 0.69、努力量一定）との照合
g <- readr::read_csv("sim/explore_const_grid.csv", show_col_types = FALSE) |> filter(decline == "30%/10yr", lambda0 >= 10)
cat("simulated floor (λ0>=10):", range(g$T_a), " analytic (λ=Inf):", round(T_floor(0.69, d30), 1), "\n")

# (2) 年の自己相関：潜在の対数正規ノイズを AR(1)（ρ）にし、周辺の過分散を φ に合わせる（e^{σ²} − 1 = 1/φ）
sim_ar <- function(T, lambda0, d, phi, rho, n_rep = 1000, seed = 20261103) {
  set.seed(seed); s2 <- log(1 + 1 / phi); t <- seq_len(T)
  res <- replicate(n_rep, {
    u <- numeric(T); u[1] <- rnorm(1, 0, sqrt(s2)); for (i in 2:T) u[i] <- rho * u[i - 1] + rnorm(1, 0, sqrt(s2 * (1 - rho^2)))
    y <- rpois(T, lambda0 * exp(-d * (t - 1) + u - s2 / 2))
    if (sum(y) == 0) return(c(dec = FALSE, inc = FALSE))
    f <- tryCatch(suppressWarnings(MASS::glm.nb(y ~ t)), error = function(e) NULL)
    if (is.null(f)) return(c(dec = FALSE, inc = FALSE))
    zz <- summary(f)$coefficients["t", 1] / summary(f)$coefficients["t", 2]
    c(dec = zz < -za, inc = zz > za)
  })
  rowMeans(res)
}
jobs <- expand_grid(rho = c(0, 0.44), lambda0 = c(1, 10, 100), T = c(10, 25, 50), d = c(0, d30))
jobs <- bind_cols(jobs, bind_rows(parallel::mclapply(seq_len(nrow(jobs)), \(i) as.list(sim_ar(jobs$T[i], jobs$lambda0[i], jobs$d[i], 0.69, jobs$rho[i])),
                                                     mc.cores = 12, mc.preschedule = FALSE)))
jobs <- mutate(jobs, scenario = ifelse(d == 0, "no decline: false declines", "30%/10yr: power"))
print(jobs |> select(scenario, rho, lambda0, T, dec) |> pivot_wider(names_from = rho, values_from = dec, names_prefix = "rho="), n = 30)
readr::write_csv(jobs, "sim/rev_autocorrelation.csv")
