pkg_env <- new.env(parent = emptyenv())


get_base_request <- function(base_url = "https://api.up.com.au/api/v1", paths = NULL) {
  httr2::request(base_url) |>
    httr2::req_headers(Authorization = paste0("Bearer ", get_up_bank_auth_token()))
}

add_path_to_req <- function(req, path, path_class = path) {
  req <- httr2::req_url_path_append(req, path)
  structure(req, class = c(class(req)[1], path_class, class(req)[-1]))
}

query_up_api <- function(req) {
  paths <- class(req)[-1]

  if (is.null(pkg_env$rate_limit) || pkg_env$rate_limit > 0) {
    res <- httr2::req_perform(req)
    pkg_env$rate_limit <- res$headers$`x-ratelimit-remaining`
  } else {
    cli::cli_abort("Rate limited exceeded") # TODO better rate handling logic
  }

  structure(res, class = c(class(res), paths))
}

process_response <- function(res) {
  if (!(httr2::resp_status(res) %in% c(200, 201, 204))) {
    process_failed_response(res)
  }

  next_link <- httr2::resp_body_json(res)$links$`next`

  pre_results <- NULL
  if (!is.null(next_link)) {
    pre_results <-
      get_base_request(base_url = next_link, paths = class(res)[-1]) |>
      query_up_api() |>
      process_response()
  }

  dplyr::bind_rows(
    pre_results,
    json_decoder(res)
  )
}

process_failed_response <- function(res, call = rlang::caller_env()) {
  error_msg <-
    dplyr::case_match(
      httr2::resp_status(res),
      400 ~ "Bad request: Typically a problem with the query string or an encoding error.",
      401 ~ "Not authorized: The request was not authenticated.",
      404 ~ "Not found: Either the endpoint does not exist, or the requested resource does not exist.",
      422 ~ "Invalid request: The request contains invalid data and was not processed.",
      429 ~ "Too many requests: You have been rate limited-try later, ideally with exponential backoff.",
      c(500, 502, 503, 504) ~ "Server-side errors: Try again later.",
      .default = "Unknown error"
    )

  cli::cli_abort("Error with the response from Up Bank. status code: {httr2::resp_status(res)} - {error_msg}", call = call)
}
