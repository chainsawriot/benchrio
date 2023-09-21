snap_date <- as.Date(Sys.getenv("SNAPSHOT_DATE"))
repo <- paste0("https://packagemanager.posit.co/cran/", snap_date)

options(repos = c(REPO_NAME = repo))
Sys.setenv(RSPM_ROOT = "https://packagemanager.posit.co")

hard_deps <- c("bench", "waldo", "Lahman", "remotes")

for (p in hard_deps) {
  if (!requireNamespace(p, quietly = TRUE)) install.packages(p)
}

soft_deps <- c("rio", "openxlsx", "vroom", "readr", "clipr",
    "fst",
    "hexView",
    "jsonlite",
    "pzfx",
    "readODS",
    "rmatio",
    "xml2",
    "yaml",
    "qs",
    "arrow",
    "stringi")

reqs <- remotes::system_requirements("ubuntu", "20.04", package = soft_deps)

z <- lapply(reqs, system) ## install system dependencies

install.packages(soft_deps)
