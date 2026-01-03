get_liker <- function() {
  rating_colors <- c(
    "1" = "#d7191c",
    "2" = "#fdae61",
    "3" = "#ffffbf",
    "4" = "#abd9e9",
    "5" = "#2c7bb6"
  )

  plot_data <- ratings |>
    filter(rater %in% bookmaker_info$bookmaker) |>
    group_by(rater, rating) |>
    count() |>
    group_by(rater) |>
    mutate(
      n_percent = n / sum(n),
      hover_text = paste0(
        "<b>Rating: ", rating, "</b><br>",
        "Count: ", n, " (", scales::percent(n_percent, accuracy = 1), ")"
      ),
      x_val = case_when(
        rating == 3 ~ paste(-n_percent / 2, n_percent / 2),
        rating < 3 ~ as.character(-n_percent),
        rating > 3 ~ as.character(n_percent)
      )
    ) |>
    separate_rows(x_val, sep = " ", convert = TRUE) |>
    mutate(rating = factor(rating)) |>
    ungroup()

  yaxis_categories <- plot_data |>
    filter(x_val > 0) |>
    group_by(rater) |>
    summarise(positive_vals = sum(x_val)) |>
    arrange(positive_vals) |>
    pull(rater)

  borders <- plot_data |>
    mutate(name = if_else(x_val > 0, "x1", "x0")) |>
    group_by(rater, name) |>
    summarise(value = sum(x_val)) |>
    pivot_wider() |>
    mutate(
      y = match(rater, yaxis_categories) - 1,
      y0 = y - .4,
      y1 = y + .4
    ) |>
    apply(1, function(row) {
      list(
        type = "rect",
        x0 = as.numeric(row["x0"]),
        x1 = as.numeric(row["x1"]),
        y0 = as.numeric(row["y0"]),
        y1 = as.numeric(row["y1"]),
        line = list(color = "black")
      )
    }, simplify = FALSE)

  p <- plot_ly(data = plot_data, y = ~rater)

  for (lvl in c(3, 2, 1, 4, 5)) {
    p <- p |> add_trace(
      x = ~x_val,
      data = filter(plot_data, rating == lvl),
      name = as.character(lvl),
      type = "bar",
      marker = list(
        color = rating_colors[as.character(lvl)]
      ),
      textposition = "none",
      hoverinfo = "text",
      text = ~hover_text,
      showlegend = FALSE
    )
  }

  # Dummies so the legened is in the correct order
  for (lvl in 1:5) {
    p <- p |> add_trace(
      x = 0,
      y = plot_data$rater[1],
      name = as.character(lvl),
      type = "bar",
      marker = list(
        color = rating_colors[as.character(lvl)],
        line = list(color = "black", width = 1)
      ),
      showlegend = TRUE
    )
  }

  p <- p |> layout(
    barmode = "relative",
    shapes = borders,
    xaxis = list(
      title = "% of ratings",
      showgrid = FALSE,
      zeroline = FALSE,
      showticklabels = FALSE
    ),
    yaxis = list(
      title = "",
      categoryorder = "array",
      categoryarray = yaxis_categories
    )
  ) |>
    config(displayModeBar = FALSE)

  list(
    plot = p
  )
}
