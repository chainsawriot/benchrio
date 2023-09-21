require(rio)
require(Lahman)
require(purrr)

rio::install_formats()

roundtrip_formats <- c("csv", "csvy", "xlsx", "r", "xpt", "sav", "zsav", "rds", "rda", "dta", "dump", "dbf", "arff", "parquet", "fst", "feather", "json", "matlab", "qs" ,"ods", "fods", "yaml")

.test <- function(format, data_sample = Lahman::Batting) {
    message(format)
    filename <- tempfile(fileext = paste0(".", format))
    export_benchmark <- bench::mark(rio::export(data_sample, filename))
    import_benchmark <- bench::mark(x <- rio::import(filename))
    filesize <- file.info(filename)
    waldo_res <- waldo::compare(data_sample, x)
    return(list(export_benchmark, import_benchmark, filesize, waldo_res))
}

.test_vroom <- function(format = "vroom (not rio)", data_sample = Lahman::Batting) {
    message(format)
    filename <- tempfile(fileext = ".csv")
    export_benchmark <- bench::mark(vroom::vroom_write(data_sample, filename, delim = ","))
    import_benchmark <- bench::mark(x <- vroom::vroom(filename, delim = ","))    
    filesize <- file.info(filename)
    waldo_res <- waldo::compare(data_sample, as.data.frame(x))
    return(list(export_benchmark, import_benchmark, filesize, waldo_res))
}

.test_readr <- function(format = "readr (not rio)", data_sample = Lahman::Batting) {
    message(format)
    filename <- tempfile(fileext = ".csv")
    export_benchmark <- bench::mark(readr::write_csv(data_sample, filename))
    import_benchmark <- bench::mark(x <- readr::read_csv(filename))
    filesize <- file.info(filename)
    waldo_res <- waldo::compare(data_sample, as.data.frame(x))
    return(list(export_benchmark, import_benchmark, filesize, waldo_res))
}

.test_openxlsx <- function(format = "openxlsx (not rio)", data_sample = Lahman::Batting) {
    message(format)
    filename <- tempfile(fileext = ".xlsx")
    export_benchmark <- bench::mark(openxlsx::write.xlsx(data_sample, filename))
    import_benchmark <- bench::mark(x <- openxlsx::read.xlsx(filename))
    filesize <- file.info(filename)
    waldo_res <- waldo::compare(data_sample, as.data.frame(x))
    return(list(export_benchmark, import_benchmark, filesize, waldo_res))
    
}

data_sample <- Lahman::Batting
some_res <- purrr::map(roundtrip_formats, .test, data_sample = data_sample)
vroom_res <- .test_vroom(data_sample = data_sample)
readr_res <- .test_readr(data_sample = data_sample)
openxlsx_res <- .test_openxlsx(data_sample = data_sample)

res <- c(some_res, list(vroom_res), list(readr_res), list(openxlsx_res))
saveRDS(res, "/usr/local/src/output/res.RDS")

