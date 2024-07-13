# Superfriends Book Club Wrapped

This repo takes the ratings and meta data
for the books we've read each year
and analyzes the data.
Then it creates HTML reports for each year.

## Set-up
1. Clone the repo
1. In `R` run `renv::restore()` to install libraries

## Updating a report
1. Create a branch
1. If updating the most recent year:
    1. Make sure the ratings Google Sheet is up-to-date
    1. Download the ratings and meta data files as CSVs
    1. Move the files to `data/`
1. Run `render.R` to generate the new reports and index
1. Merge to main

## Pages

The final reports can be found
[here](https://bcorwin.github.io/superfriends-book-club-wrapped/).