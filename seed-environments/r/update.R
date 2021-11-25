if (!requireNamespace("renv", quietly = TRUE)) install.packages("renv", lib="/usr/local/lib/R/site-library");
renv::activate()
renv::restore()

renv::update(prompt=FALSE)
renv::snapshot(prompt=FALSE)
