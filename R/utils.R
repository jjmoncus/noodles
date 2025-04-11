#' Quickly make a metadata file for a dataset
#'
#' @export
#'
#' @importFrom tibble tibble
meta <- function(data) {
  data %>%
    {
      tibble(
        var = names(.),
        class = map(., class),
        levels = map(., levels),
        label = map(., ~ attr(.x, "label"))
      )
    }
}


#' Find variables in a dataset with certain levels
#'
#' Sometimes you don't know what a variable is called, but you do know
#' what factor levels it has. This function lets you search through a dataset
#' and returns you variables and their factors which match a regex.
#'
#' @importFrom rlang set_names
#' @importFrom purrr some
#' @importFrom stringr str_detect
#' @importFrom purrr keep
#'
#' @export

find_level <- function(data, pattern) {
  names(data) %>%
    keep(function(x) {
      levels(data[[x]]) %>%
        some(function(y) {
          str_detect(y, pattern = pattern)
        })
    }) -> vars_to_keep

  vars_to_keep %>%
    set_names() %>%
    map(~ levels(data[[.x]]))
}

#' Find variables in a dataset whose label attribute match some pattern
#'
#' Sometimes you don't know what a variable is called, but you do know
#' what its variable label might contain. This function lets you search
#' through a dataset and returns you variables and their factors which match
#' a regex.
#'
#'@export

find_label <- function(data, pattern) {
  names(data) %>%
    keep(function(x) {
      attr(data[[x]], "label") %>%
        some(function(y) {
          str_detect(y, pattern = pattern)
        })
    }) -> vars_to_keep

  vars_to_keep %>%
    set_names() %>%
    map(~ attr(data[[.x]], "label"))
}


#' Lowercase names and return data
#' @export
#'
#' @importFrom stringr str_to_lower
lower_names <- function(data) {
  names(data) <- str_to_lower(names(data))
  return(data)
}

#' Generic Gartner ggplot theme
#' @export
#'
#' @importFrom ggplot2 theme_minimal theme element_blank
theme_g <- function(...) {
  # potential feature addition: allow people to add theme parameters
  # inside function call
  # dots <- list2(...)

  theme_minimal() %+replace%
    theme(
      panel.grid = element_blank()
    )
}

#' Generic Gartner reactable
#' @export
#'
#' @importFrom reactable reactable
greactable <- function(data) {
  reactable(data, height = 500)
}

#' Add a variable label to variable
#' @export
add_label <- function(var, label) {
  structure(
    var,
    label = label
  )
}

#' Return variable labels for a group
#' @export
#'
#' @importFrom rlang enquos
#' @importFrom purrr map
get_labels <- function(data, ...) {
  criteria <- enquos(...)

  data %>%
    select(!!!criteria) %>%
    map(~ attr(.x, "label"))
}

#' How many non-NA responses are there for a variable?
#' @export
n_size <- function(data, var) {
  quo_var <- enquo(var)

  data %>%
    pull(!!quo_var) %>%
    Filter(function(x) !is.na(x), .) %>%
    length()
}

#' How many non-NA responses are there for a group of variables?
#' @export
n_sizes <- function(data, group) {
  data %>%
    select(matches(group)) %>%
    names() %>%
    purrr::set_names() %>%
    map(
      ~ .x %>%
        sym() %>%
        {
          n_size(data, !!.)
        }
    )
}

#' Get names of a dataset, then auto-name them
#'
#' When mapping over variables in `data`, we frequently
#' start by taking `names` and then using `purrr::set_names`
#' to name each element after itself. This is a shortcut for that
#'
#' @export
auto_names <- function(data) {
  data %>%
    names() %>%
    set_names()
}


#' Find Variables by Pattern
#'
#' Identifies and returns variable names from a dataset that match a specified pattern, while excluding certain patterns.
#'
#' @param data A data frame from which variable names are to be extracted.
#' @param pattern A character string representing the pattern to match variable names against.
#' @param exclude A character string representing the pattern to exclude from the matched variable names. Default is `"(_other)|(o$)|(FLAG)|(Flag)|(oe)"`.
#'
#' @return A character vector of variable names that match the specified pattern and do not match the exclusion pattern.
#'
#' @examples
#' \dontrun{
#' # Example usage:
#' vars <- find_vars(data = my_data, pattern = "Q23")
#' }
#'
#' @importFrom stringr str_subset
find_vars <- function(
  data,
  pattern,
  exclude = "(_other)|(o$)|(FLAG)|(Flag)|(oe)"
) {
  data %>%
    names() %>%
    # grab all variables assocated with that index
    str_subset(pattern = pattern) %>%
    # remove any vars for other category
    str_subset(pattern = exclude, negate = TRUE)
}
