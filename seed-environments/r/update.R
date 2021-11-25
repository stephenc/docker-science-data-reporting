if (!requireNamespace("renv", quietly = TRUE)) install.packages("renv", lib="/usr/local/lib/R/site-library");
renv::activate()
renv::restore()

renv::upgrade(prompt=FALSE, reload=TRUE)
renv::update(prompt=FALSE, reload=TRUE)
renv::snapshot(prompt=FALSE)