#' @export
group_by.dm <- function(.data, ...) {
  abort_no_table_zoomed_dplyr("group_by")
}

#' @export
group_by.zoomed_dm <- function(.data, ...) {
  tbl <- get_zoomed_tbl(.data)
  grouped_tbl <- group_by(tbl, ...)

  replace_zoomed_tbl(.data, grouped_tbl)
}

#' @export
ungroup.dm <- function(x, ...) {
  abort_no_table_zoomed_dplyr("ungroup")
}

#' @export
ungroup.zoomed_dm <- function(x, ...) {
  tbl <- get_zoomed_tbl(x)
  ungrouped_tbl <- ungroup(tbl, ...)

  replace_zoomed_tbl(x, ungrouped_tbl)
}

#' @export
summarise.zoomed_dm <- function(.data, ...) {
  tbl <- get_zoomed_tbl(.data)
  # groups are "selected"; key tracking will continue for them
  groups <- set_names(map_chr(groups(tbl), as_string))
  summarized_tbl <- summarize(tbl, ...)
  new_tracked_keys_zoom <- new_tracked_keys(.data, groups)
  replace_zoomed_tbl(.data, summarized_tbl, new_tracked_keys_zoom)
}

#' @export
summarise.dm <- function(.data, ...) {
  abort_no_table_zoomed_dplyr("summarise")
}

#' @export
filter.dm <- function(.data, ...) {
  abort_no_table_zoomed_dplyr("filter")
}

#' @export
filter.zoomed_dm <- function(.data, ...) {
  filter_quos <- enquos(...)
  if (is_empty(filter_quos)) {
    return(.data)
  } # valid table and empty ellipsis provided

  tbl <- get_zoomed_tbl(.data)
  filtered_tbl <- filter(tbl, !!!filter_quos)

  # attribute filter expression to zoomed table. Needs to be flagged with `zoomed = TRUE`, since
  # in case of `cdm_insert_zoomed_tbl()` the filter exprs needs to be transferred
  set_filter_for_table(.data, orig_name_zoomed(.data), map(filter_quos, quo_get_expr), TRUE) %>%
    replace_zoomed_tbl(filtered_tbl)
}

#' @export
mutate.dm <- function(.data, ...) {
  abort_no_table_zoomed_dplyr("mutate")
}

#' @export
mutate.zoomed_dm <- function(.data, ...) {
  tbl <- get_zoomed_tbl(.data)
  mutated_tbl <- mutate(tbl, ...)
  # all columns that are not touched count as "selected"; names of "selected" are identical to "selected"
  selected <- set_names(setdiff(names(get_tracked_keys(.data)), names(enquos(..., .named = TRUE))))
  new_tracked_keys_zoom <- new_tracked_keys(.data, selected)
  replace_zoomed_tbl(.data, mutated_tbl, new_tracked_keys_zoom)
}

#' @export
transmute.dm <- function(.data, ...) {
  abort_no_table_zoomed_dplyr("transmute")
}

#' @export
transmute.zoomed_dm <- function(.data, ...) {
  tbl <- get_zoomed_tbl(.data)
  # groups are "selected"; key tracking will continue for them
  groups <- set_names(map_chr(groups(tbl), as_string))
  transmuted_tbl <- transmute(tbl, ...)
  new_tracked_keys_zoom <- new_tracked_keys(.data, groups)

  replace_zoomed_tbl(.data, transmuted_tbl, new_tracked_keys_zoom)
}

#' @export
select.dm <- function(.data, ...) {
  abort_no_table_zoomed_dplyr("select")
}

#' @export
select.zoomed_dm <- function(.data, ...) {
  tbl <- get_zoomed_tbl(.data)
  selected <- tidyselect::vars_select(colnames(tbl), ...)
  selected_tbl <- select(tbl, !!!selected)

  new_tracked_keys_zoom <- new_tracked_keys(.data, selected)

  replace_zoomed_tbl(.data, selected_tbl, new_tracked_keys_zoom)
}

#' @export
rename.dm <- function(.data, ...) {
  abort_no_table_zoomed_dplyr("rename")
}

#' @export
rename.zoomed_dm <- function(.data, ...) {
  tbl <- get_zoomed_tbl(.data)
  renamed <- tidyselect::vars_rename(colnames(tbl), ...)
  renamed_tbl <- rename(tbl, !!!renamed)

  new_tracked_keys_zoom <- new_tracked_keys(.data, renamed)

  replace_zoomed_tbl(.data, renamed_tbl, new_tracked_keys_zoom)
}

#' @export
left_join.dm <- function(x, ...) {
  check_zoomed(x)
}

#' @export
left_join.zoomed_dm <- function(x, y, by = NULL, copy = FALSE, suffix = c(".x", ".y"), select = NULL, ...) {
  y_name <- as_string(enexpr(y))
  join_data <- prepare_join(x, {{ y }}, by, {{ select }}, suffix[1], copy)
  joined_tbl <- left_join(join_data$x_tbl, join_data$y_tbl, join_data$by, copy = FALSE, suffix = suffix, ...)
  replace_zoomed_tbl(x, joined_tbl, join_data$new_key_names)
}

#' @export
inner_join.dm <- function(x, ...) {
  check_zoomed(x)
}

#' @export
inner_join.zoomed_dm <- function(x, y, by = NULL, copy = FALSE, suffix = c(".x", ".y"), select = NULL, ...) {
  y_name <- as_string(enexpr(y))
  join_data <- prepare_join(x, {{ y }}, by, {{ select }}, suffix[1], copy)
  joined_tbl <- inner_join(join_data$x_tbl, join_data$y_tbl, join_data$by, copy = FALSE, suffix = suffix, ...)
  replace_zoomed_tbl(x, joined_tbl, join_data$new_key_names)
}

#' @export
full_join.dm <- function(x, ...) {
  check_zoomed(x)
}

#' @export
full_join.zoomed_dm <- function(x, y, by = NULL, copy = FALSE, suffix = c(".x", ".y"), select = NULL, ...) {
  y_name <- as_string(enexpr(y))
  join_data <- prepare_join(x, {{ y }}, by, {{ select }}, suffix[1], copy)
  joined_tbl <- full_join(join_data$x_tbl, join_data$y_tbl, join_data$by, copy = FALSE, suffix = suffix, ...)
  replace_zoomed_tbl(x, joined_tbl, join_data$new_key_names)
}

#' @export
semi_join.dm <- function(x, ...) {
  check_zoomed(x)
}

#' @export
semi_join.zoomed_dm <- function(x, y, by = NULL, copy = FALSE, select = NULL, ...) {
  y_name <- as_string(enexpr(y))
  join_data <- prepare_join(x, {{ y }}, by, {{ select }}, NULL, copy)
  joined_tbl <-semi_join(join_data$x_tbl, join_data$y_tbl, join_data$by, copy = FALSE, ...)
  replace_zoomed_tbl(x, joined_tbl, join_data$new_key_names)
}

#' @export
anti_join.dm <- function(x, ...) {
  check_zoomed(x)
}

#' @export
anti_join.zoomed_dm <- function(x, y, by = NULL, copy = FALSE, select = NULL, ...) {
  y_name <- as_string(enexpr(y))
  join_data <- prepare_join(x, {{ y }}, by, {{ select }}, NULL, copy)
  joined_tbl <-anti_join(join_data$x_tbl, join_data$y_tbl, join_data$by, copy = FALSE, ...)
  replace_zoomed_tbl(x, joined_tbl, join_data$new_key_names)
}

#' @export
right_join.dm <- function(x, ...) {
  check_zoomed(x)
}

#' @export
right_join.zoomed_dm <- function(x, y, by = NULL, copy = FALSE, suffix = c(".x", ".y"), select = NULL, ...) {
  y_name <- as_string(enexpr(y))
  join_data <- prepare_join(x, {{ y }}, by, {{ select }}, suffix[1], copy)
  joined_tbl <-right_join(join_data$x_tbl, join_data$y_tbl, join_data$by, copy = FALSE, suffix = suffix, ...)
  replace_zoomed_tbl(x, joined_tbl, join_data$new_key_names)
}

prepare_join <- function(x, y, by, selected, suffix, copy) {
  y_name <- as_string(ensym(y))
  select_quo <- enquo(selected)
  if (copy) message("Tables in a `dm` are necessarily on the same `src`, setting `copy = FALSE`.")
  x_tbl <- get_zoomed_tbl(x)
  x_orig_name <- orig_name_zoomed(x)
  y_tbl <- cdm_get_tables(x)[[y_name]]
  all_cols_y <- colnames(y_tbl)
  selected <- if (quo_is_null(select_quo))
    tidyselect::vars_select(all_cols_y, everything()) else
    tidyselect::vars_select(all_cols_y, !!select_quo)
  if (is_null(by)) {
    by <- get_by(x, x_orig_name, y_name)
    if (!any(selected == by)) abort_need_to_select_rhs_by(y_name, unname(by))
    # in case user is renaming RHS-by during the join
    by <- set_names(names(selected[selected == by]), names(by))
    x_by <- names(by)
    names(by) <- names(get_tracked_keys(x)[get_tracked_keys(x) == x_by])
    if (is_na(names(by))) abort_fk_not_tracked(x_orig_name, y_name)
  }
  # in case key columns of x_tbl have the same name as selected columns of y_tbl
  # the column names of x will be adapted (not for `semi_join()` and `anti_join()`)
  # We can track the new column names
  new_key_names <- repair_tracking(get_tracked_keys(x), selected, suffix, names(by))
  list(x_tbl = x_tbl, y_tbl = select(y_tbl, !!!selected), by = by, new_key_names = new_key_names)
}

repair_tracking <- function(tracked_keys, selected, suffix, lhs_by) {
  old_names <- names(tracked_keys)
  # change those column names from table 'x' which
  # 1. correspond to one of those columns that are selected in table 'y'
  # 2. are NOT one of the columns that the join is performed by
  indices <- old_names %in% names(selected) & !(old_names %in% lhs_by)
  new_names <- if_else(!is_null(suffix) & indices, paste0(old_names, suffix), old_names)
  set_names(tracked_keys, new_names)
}