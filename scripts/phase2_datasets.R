source("R/gbif.R")
d <- dataset_classes()
print(dplyr::count(d, ds_class, wt = n_total))
print(nrow(d))
