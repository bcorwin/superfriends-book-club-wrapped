output_file <- file.path(
  "output",
  paste0("wrapped_", format(Sys.Date(), "%Y"), ".html")
)
rmarkdown::render(
  'analysis.Rmd',
  output_file = output_file
)