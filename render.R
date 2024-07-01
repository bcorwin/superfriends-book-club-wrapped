#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly = TRUE)

if (length(args) == 0) {
  current_year <- as.integer(format(Sys.Date(), "%Y"))
  years <- seq(2020, current_year)
} else {
  years <- args
}

options(knitr.duplicate.label = "allow")
for (year in years) {
  output_file <- file.path(
    "output",
    paste0("wrapped_", year, ".html")
  )
  rmarkdown::render(
    "analysis.Rmd",
    output_file = output_file,
    params = list(year = year),
    envir = new.env()
  )
}
