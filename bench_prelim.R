require(rio)
require(Lahman)
require(purrr)

roundtrip_formats <- c("csv", "xml", "html")

.test <- function(format, data_sample = Lahman::Batting) {
    message(format)
    filename <- tempfile(fileext = paste0(".", format))
    export_benchmark <- bench::mark(rio::export(data_sample, filename))
    import_benchmark <- bench::mark(x <- rio::import(filename))
    filesize <- file.info(filename)
    waldo_res <- waldo::compare(data_sample, x)
    return(list(export_benchmark, import_benchmark, filesize, waldo_res))
}

data_sample <- Lahman::Batting[1:3000,]
some_res <- purrr::map(roundtrip_formats, .test, data_sample = data_sample)

some_res_tab <- tibble::tibble(format = c(roundtrip_formats),
               export_time = purrr::map_dbl(some_res, ~.[[1]]$median),
               import_time = 
                   purrr::map_dbl(some_res, ~.[[2]]$median),
               file_size = 
                   purrr::map_dbl(some_res, ~.[[3]]$size),
               accuracy = purrr::map_dbl(some_res, ~length(.[[4]])))

some_res_tab %>% mutate(export_time = export_time  / some_res_tab$export_time[1], import_time = import_time  / some_res_tab$import_time[1], file_size = file_size  / some_res_tab$file_size[1]) %>% arrange(import_time) %>% rename(`Export Time (Relative to csv)` = "export_time", `Import Time (Relative to csv)` = "import_time", `File Size (Relative to csv)` = "file_size", `Accuracy` = accuracy) %>% knitr::kable(digits = 1)
