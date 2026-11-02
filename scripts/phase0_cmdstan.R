# Phase 0: CmdStan をインストールして簡単なモデルで動作確認
library(cmdstanr)
if (is.null(tryCatch(cmdstan_path(), error = function(e) NULL)))
  install_cmdstan(cores = 16, quiet = TRUE)
cat("CmdStan:", cmdstan_version(), "at", cmdstan_path(), "\n")
f <- write_stan_file("data{int N; vector[N] y;} parameters{real mu; real<lower=0> s;} model{y ~ normal(mu,s);}")
m <- cmdstan_model(f)
set.seed(20261103)
fit <- m$sample(data = list(N = 50, y = rnorm(50, 1, 2)), seed = 20261103, chains = 2,
                refresh = 0, show_messages = FALSE)
print(fit$summary())
