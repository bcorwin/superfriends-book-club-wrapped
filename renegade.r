get_renegade <- function() {
  plot_data <- ratings |>
    select(bookmaker, book, rater, rating) |>
    group_by(book) |>
    mutate(
      median_val = median(rating),
      renegade = abs(rating - median_val) >= 2,
      min_val = min(rating[!renegade])
    ) |>
    ungroup() |>
    mutate(
      x_jitter = dense_rank(
        paste0(format(median_val, nsmall = 1), min_val, book)
      ),
      y_jitter = jitter(rating, amount = 0.25)
    )

  median_lines <- plot_data |>
    group_by(median_val) |>
    summarise(
      min_x = min(x_jitter),
      max_x = max(x_jitter)
    )

  output_plot <- plot_ly(type = "scatter", mode = "markers") |>
  add_markers(
    data = filter(plot_data, renegade),
    x = ~x_jitter,
    y = ~y_jitter,
    color = ~rater,
    colors = bookmaker_info$color,
    symbol = I("x"),
    marker = list(
      size = 10,
      opacity = 1,
      line = list(width = 1, color = "black")
    ),
    hoverinfo = "text",
    text = ~paste0(
      book,
      "<br>Median rating: ", median_val,
      "<br>", rater, "'s rating: ", rating
    )
  ) |>
    add_markers(
      data = filter(plot_data, !renegade),
      x = ~x_jitter,
      y = ~y_jitter,
      symbol = I("circle"),
      marker = list(size = 7, color = "#d3d3d3", opacity = 0.3),
      hoverinfo = "text",
      text = ~paste0(
        book,
        "<br>Median rating: ", median_val,
        "<br>", rater, "'s rating: ", rating
      )
    ) |>
    add_segments(
      mode = "lines",
      data = median_lines,
      x = ~min_x - 0.2,
      xend = ~max_x + 0.2,
      y = ~median_val,
      yend = ~median_val,
      line = list(color = "d3d3d3", width = 2),
      showlegend = FALSE,
      hoverinfo = "text",
      text = ~paste0("Group median: ", median_val)
    ) |>
    layout(
      showlegend = FALSE,
      xaxis = list(
        showticklabels = FALSE,
        showgrid = FALSE,
        title = "Book"
      ),
      yaxis = list(
        showgrid = FALSE,
        dtick = 1,
        title = "Individual score (with median)"
      )
    ) |>
    config(displayModeBar = FALSE)

  output_table <- plot_data |>
    filter(renegade) |>
    inner_join(meta_data, by = "book") |>
    mutate(
      type = if_else(rating > median_val, "Lover", "Hater"),
      book = if_else(
        rater == bookmaker,
        paste0(book, "\\*"),
        book
      ),
      book = if_else(
        year == params$year,
        paste0("<span style='color:red'>", book, "</span>"),
        book
      )
    ) |>
    group_by(rater, type) |>
    summarise(books = paste0(book, collapse = "<br>")) |>
    pivot_wider(
      names_from = type,
      values_from = books,
      values_fill = ""
    ) |>
    kable(
      format = "html",
      escape = FALSE,
      col.names = c("", "Hater", "Lover")
    ) |>
    footnote(
      symbol = c("Rater's own book."),
    ) |>
    kable_styling()

  renegades <- plot_data |>
    filter(renegade) |>
    mutate(
      type = if_else(rating > median_val, "Lover", "Hater")
    ) |>
    group_by(rater) |>
    summarise(
      lover = sum(type == "Lover"),
      hater = sum(type == "Hater")
    )

  biggest_lovers <- paste0(
    renegades$rater[max(renegades$lover) == renegades$lover],
    collapse = " / "
  )
  biggest_haters <- paste0(
    renegades$rater[max(renegades$hater) == renegades$hater],
    collapse = " / "
  )

  list(
    plot = output_plot,
    table = output_table,
    biggest_lovers = biggest_lovers,
    biggest_haters = biggest_haters
  )
}

get_renegade()
