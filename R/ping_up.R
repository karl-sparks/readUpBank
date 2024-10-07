ping_up <- function() {
  res <- get_base_request() |>
    add_path_to_req("util") |>
    add_path_to_req("ping") |>
    query_up_api()

  if (!(httr2::resp_status(res) %in% c(200, 201, 204))) {
    process_failed_response(res)
  }

  body <- httr2::resp_body_json(res)

  emoji <- body$meta$statusEmoji

  cli::cli_alert_success("{emoji} rate limit remaining : {pkg_env$rate_limit}")
}
