#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly = TRUE)

if (length(args) == 0) {
  current_year <- as.integer(format(Sys.Date(), "%Y")) - 1
  years <- seq(2021, current_year)
} else {
  years <- args
}

options(knitr.duplicate.label = "allow")
page_list <- NULL
for (year in years) {
  output_file <- paste0("wrapped_", year, ".html")
  page_list <- c(page_list, output_file)

  rmarkdown::render(
    "analysis.Rmd",
    output_file = file.path("docs", output_file),
    params = list(year = year),
    envir = new.env()
  )
}

page_list <- paste0("    <li>", page_list, "</li>")
page_list <- paste(page_list, sep = "", collapse = "\n")

index_page <- readr::read_file("index_template.html")
index_page <- glue::glue(index_page)
write_file(index_page, file.path("docs", "index.html"))
