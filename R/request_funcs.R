pkg_env <- new.env(parent = emptyenv())


get_base_request <- function(base_url = "https://api.up.com.au/api/v1", paths = NULL) {
  httr2::request(base_url) |>
    httr2::req_user_agent(
      "readUpBank (https://github.com/karl-sparks/readUpBank)"
    ) |>
    httr2::req_error(
      body = up_api_error_body
    ) |>
    httr2::req_retry(
      max_tries = 6
    ) |>
    httr2::req_headers(
      Authorization = paste("Bearer", get_up_bank_auth_token())
    ) |>
    httr2::req_url_query(
      `page[size]` = 100
    )
}

up_api_error_body <- function(resp) {
  json_body <- resp |> httr2::resp_body_json()

  error <- json_body$errors[[1]]

  c(
    error$title,
    error$detail
  )
}

query_up_api <- function(req) {
  resp <- httr2::req_perform(req)
  pkg_env$rate_limit <- resp$headers$`x-ratelimit-remaining`

  resp
}

process_response <- function(resp, num_records = 0) {
  if (!(httr2::resp_status(resp) %in% c(200, 201, 204))) {
    process_failed_response(resp)
  }

  next_link <- httr2::resp_body_json(resp)$links$`next`
  records_loaded <- httr2::resp_body_json(resp)$data |> length()

  pre_results <- NULL
  if (!is.null(next_link)) {
    msg_str <- format((records_loaded + num_records), big.mark = ",")
    cli::cli_progress_message("~{msg_str} records retrieved from Up")

    pre_results <-
      get_base_request(base_url = next_link, paths = class(resp)[-1]) |>
      query_up_api() |>
      process_response(records_loaded + num_records)
  }

  append(
    pre_results,
    list(resp)
  )
}

process_failed_response <- function(resp, call = rlang::caller_env()) {
  cli::cli_abort(
    c(
      "Error with the response from Up Bank. status code: {httr2::resp_status(res)}",
      up_api_error_body(resp)
    ),
    call = call
  )
}
