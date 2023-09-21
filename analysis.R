require(rio)
require(Lahman)
require(purrr)


roundtrip_formats <- c("csv", "csvy", "xlsx", "r", "xpt", "sav", "zsav", "rds", "rda", "dta", "dump", "dbf", "arff", "parquet", "fst", "feather", "json", "matlab", "qs" ,"ods", "fods", "yaml")

res <- readRDS(here::here("output", "res.RDS"))

res_tab <- tibble::tibble(format = c(roundtrip_formats, "vroom (not rio)", "readr (not rio)", "openxlsx (not rio)"),
               export_time = purrr::map_dbl(res, ~.[[1]]$median),
               import_time = 
                   purrr::map_dbl(res, ~.[[2]]$median),
               file_size = 
                   purrr::map_dbl(res, ~.[[3]]$size),
               accuracy = purrr::map_dbl(res, ~length(.[[4]])))

res_tab %>% mutate(export_time = export_time  / res_tab$export_time[1], import_time = import_time  / res_tab$import_time[1], file_size = file_size  / res_tab$file_size[1]) %>% arrange(import_time) %>% rename(`Export Time (Relative to csv)` = "export_time", `Import Time (Relative to csv)` = "import_time", `File Size (Relative to csv)` = "file_size", `Accuracy` = accuracy) %>% knitr::kable(digits = 1)

pca <- princomp(res_tab[,-1], cor = TRUE)
tibble(format = res_tab$format, score = pca$scores[,1]) %>% arrange(score) %>% print(n = 100) %>% knitr::kable(digits = 1)

km <- kmeans(res_tab[,-1], 4)
res_tab$format[km$cluster==4]

