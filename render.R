#!/usr/bin/env Rscript
args <- commandArgs(trailingOnly = TRUE)

if (length(args) == 0) {
  current_year <- as.integer(format(Sys.Date(), "%Y")) - 1
  years <- seq(2021, current_year)
} else {
  years <- args
}

options(knitr.duplicate.label = "allow")
for (year in years) {
  output_file <- paste0("wrapped_", year, ".html")
  
  rmarkdown::render(
    "analysis.Rmd",
    output_file = file.path("docs", output_file),
    params = list(year = year),
    envir = new.env()
  )
}

page_list <- NULL
page_names <- NULL
for(page in list.files("docs")) {
  if(!grepl("wrapped_", page)) next

  name <- sub("wrapped_", "", page)
  name <- sub(".html", "", name)
  name <- paste(name, "Wrapped")

  page_list <- c(page_list, page)
  page_names <- c(page_names, name)
}

page_list <- glue::glue("    <li><a href='{page_list}'>{page_names}</a></li>")
page_list <- paste(page_list, sep = "", collapse = "\n")

index_page <- readr::read_file("index_template.html")
index_page <- glue::glue(index_page)
readr::write_file(index_page, file.path("docs", "index.html"))
