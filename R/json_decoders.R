json_decoder <- function(res_json) {
  UseMethod("json_decoder")
}

json_decoder.accounts <- function(res) {
  json_data <- httr2::resp_body_json(res)$data

  flatten_json <- tibble::tibble(!!!1:11, .rows = 0)

  if (length(json_data) > 1) {
    flatten_json <-
      purrr::map(
        json_data,
        \(x)  purrr::list_flatten(x) |>
          purrr::list_flatten() |>
          purrr::list_flatten() |>
          tibble::as_tibble()
      ) |>
      purrr::list_rbind()
  }

  flatten_json |>
    format_accounts_tibble()
}

json_decoder.accounts_id <- function(res) {
  json_data <- httr2::resp_body_json(res)$data

  flatten_json <- tibble::tibble(!!!1:11, .rows = 0)

  if (length(json_data) > 1) {
    flatten_json <-
      httr2::resp_body_json(res)$data |>
      purrr::list_flatten() |>
      purrr::list_flatten() |>
      purrr::list_flatten() |>
      tibble::as_tibble()
  }

  flatten_json |>
    format_accounts_tibble()
}


format_accounts_tibble <- function(processed_json) {
  var_names <- c(
    "type", "account_id", "account_name", "account_type",
    "account_ownership_type", "account_balance_currency",
    "account_balance_value", "account_balance_value_base_units",
    "account_created_at", "link_to_transactions", "link_to_self"
  )

  var_datatimes <- c("account_created_at")
  var_with_timezone <- "Australia/Sydney"

  var_numeric <- c(
    "account_balance_value",
    "account_balance_value_base_units"
  )

  var_to_drop <- c("link_to_transactions", "link_to_self")

  processed_json |>
    setNames(var_names) |>
    dplyr::mutate(
      dplyr::across(
        dplyr::all_of(var_datatimes),
        \(x) lubridate::as_datetime(x) |> lubridate::with_tz(var_with_timezone)
      ),
      dplyr::across(
        dplyr::all_of(var_numeric),
        as.numeric
      )
    ) |>
    dplyr::select(-dplyr::all_of(var_to_drop))
}
