// Tier A：Poisson-lognormal、ln N の測定誤差（sdN）と過分散（tau）を合成した1つの正規項に周辺化
// eta_s ~ Normal(lnN_obs_s + alpha + beta (lnM_s - c) + u_order[s], sqrt(sdN_s^2 + tau^2))、R_s ~ Poisson(exp(eta_s))
// （ln N の誤差と ε はともに独立な正規で線形予測子に足し算で入るので、PREREG §4 のモデルと同値）
// eta は中心化パラメータ化：ほとんどの種で記録数が多く、R が eta を強く決めるため
data {
  int<lower=1> S;
  array[S] int<lower=0> R;
  vector[S] lnN_obs;
  vector<lower=0>[S] sdN;
  vector[S] lnM;
  int<lower=1> O;
  array[S] int<lower=1, upper=O> ord;
  real lnM_c;
}
parameters {
  real alpha;
  real beta;
  real<lower=0> sd_order;
  real<lower=0> tau;
  vector[O] z_order;
  vector[S] eta;
}
model {
  alpha ~ normal(-15, 10);
  beta ~ normal(0, 2);
  sd_order ~ normal(0, 2);
  tau ~ normal(0, 2);
  z_order ~ std_normal();
  eta ~ normal(lnN_obs + alpha + beta * (lnM - lnM_c) + sd_order * z_order[ord], sqrt(square(sdN) + square(tau)));
  R ~ poisson_log(eta);
}
