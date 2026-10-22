# Turning the NHL's nested JSON into tibbles.

LANGS <- c("default", "fr", "cs", "de", "es", "fi", "sk", "sv")

# {"default": "Edmonton", "fr": "..."}: a localized string; keep the default.
is_localized <- function(x) {
  is.list(x) && length(x) > 0 && !is.null(names(x)) && "default" %in% names(x) && all(names(x) %in% LANGS)
}

is_record <- function(x) is.list(x) && length(x) > 0 && !is.null(names(x)) && all(nzchar(names(x)))
is_record_list <- function(x) is.list(x) && length(x) > 0 && is.null(names(x)) && all(vapply(x, is_record, logical(1)))

#' snake_case names
#'
#' @param x Character vector of camelCase names.
#' @return `x` in snake_case.
#' @keywords internal
#' @noRd
to_snake <- function(x) {
  x <- gsub("([a-z0-9])([A-Z])", "\\1_\\2", x)
  x <- gsub("([A-Z]+)([A-Z][a-z])", "\\1_\\2", x)
  x <- gsub("[^A-Za-z0-9]+", "_", x)
  tolower(gsub("^_+|_+$", "", x))
}

# One record (named list) to a flat named list: nested records become
# parent_child fields, localized strings their default, French duplicates
# (fooFr beside foo) are dropped and arrays stay whole (list-columns).
flatten_record <- function(x, prefix = NULL) {
  out <- list()
  nms <- names(x)
  for (i in seq_along(x)) {
    k <- nms[[i]]
    if (grepl("Fr$", k) && sub("Fr$", "", k) %in% nms) next
    v <- x[[i]]
    key <- if (is.null(prefix)) k else paste(prefix, k, sep = "_")
    if (is.null(v)) {
      out[[key]] <- NA
    } else if (is_localized(v)) {
      out[[key]] <- v[["default"]] %||% NA
    } else if (is_record(v)) {
      out <- c(out, flatten_record(v, key))
    } else if (is.list(v)) {
      out[[key]] <- list(v)
    } else {
      out[[key]] <- v
    }
  }
  out
}

simplify_column <- function(vals) {
  if (any(vapply(vals, function(v) is.list(v) || length(v) != 1, logical(1)))) {
    return(lapply(vals, function(v) if (is.list(v) && length(v) == 1 && is.list(v[[1]])) v[[1]] else v))
  }
  unlist(vals, use.names = FALSE)
}

#' Records to a tibble
#'
#' @param records A list of records (named lists), as the NHL APIs return them.
#' @return A tibble, one row per record.
#' @keywords internal
#' @noRd
records_to_tibble <- function(records) {
  if (!length(records)) return(tibble::tibble())
  flat <- lapply(records, flatten_record)
  cols <- unique(unlist(lapply(flat, names), use.names = FALSE))
  data <- lapply(cols, function(cn) simplify_column(lapply(flat, function(r) if (is.null(r[[cn]])) NA else r[[cn]])))
  names(data) <- make.unique(to_snake(cols), sep = "_")
  tibble::as_tibble(data)
}

#' Tidy any NHL JSON
#'
#' Flattens a parsed NHL response: a list of records becomes a tibble; a
#' record becomes a named list whose record-list parts are tibbles and whose
#' other fields are gathered into a one-row tibble called `info`. Names
#' become snake_case and localized strings keep their English text.
#'
#' @param x Parsed JSON, e.g. from [nhl_api()].
#' @return A tibble or a named list of tibbles.
#' @export
#' @examples
#' tidy_json(list(list(playerId = 1, firstName = list(default = "Connor"))))
tidy_json <- function(x) {
  if (is_record_list(x)) return(records_to_tibble(x))
  if (!is_record(x)) return(x)
  out <- list()
  scalars <- list()
  for (k in names(x)) {
    v <- x[[k]]
    if (is_record_list(v)) {
      out[[to_snake(k)]] <- records_to_tibble(v)
    } else if (is_record(v) && !is_localized(v)) {
      inner <- Filter(is_record_list, v)
      if (length(inner) && length(inner) == length(v)) {
        out[[to_snake(k)]] <- lapply(stats::setNames(inner, to_snake(names(inner))), records_to_tibble)
      } else {
        scalars[[k]] <- v
      }
    } else {
      scalars[[k]] <- v
    }
  }
  if (length(scalars)) out <- c(list(info = records_to_tibble(list(scalars))), out)
  out
}

clock_seconds <- function(x) {
  x <- as.character(x)
  out <- rep(NA_real_, length(x))
  ok <- !is.na(x) & grepl("^\\d+:\\d{2}$", x)
  parts <- strsplit(x[ok], ":", fixed = TRUE)
  out[ok] <- vapply(parts, function(p) as.numeric(p[[1]]) * 60 + as.numeric(p[[2]]), numeric(1))
  out
}

# Columns in this order first, the rest after.
front <- function(df, cols) {
  cols <- intersect(cols, names(df))
  df[, c(cols, setdiff(names(df), cols)), drop = FALSE]
}
