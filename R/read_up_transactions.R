#' Read Up Transactions
#'
#' @param transaction_id
#' @param status
#' @param since
#' @param until
#' @param category
#' @param tag
#'
#' @return
#' @export
read_up_transactions <- function(transaction_id = NULL, status = c("HELD", "SETTLED"), since = NULL, until = NULL, category = NULL, tag = NULL, formatter = "simple") {
  stopifnot("transaction_id must be NULL or a character of length 1" = missing(transaction_id) || is.character(transaction_id) && length(transaction_id) == 1)
  stopifnot("category must be NULL or a character of length 1" = missing(category) || is.character(category) && length(category) == 1)
  stopifnot("tag must be NULL or a character of length 1" = missing(tag) || is.character(tag) && length(tag) == 1)

  if (!missing(status)) {
    status <- rlang::arg_match(status)
  }

  req <- get_base_request() |>
    httr2::req_url_path_append("transactions")

  transaction_endpoint <- "/transactions"

  if (!missing(transaction_id)) {
    req <- httr2::req_url_path_append(req, transaction_id)
    transaction_endpoint  <- "/transactions/{id}"
  }

  if (!missing(status)) {
    req <- httr2::req_url_query(req, `filter[status]` = status)
  }

  if (!missing(category)) {
    req <- httr2::req_url_query(req, `filter[category]` = category)
  }

  if (!missing(tag)) {
    req <- httr2::req_url_query(req, `filter[tag]` = tag)
  }

  cli::cli_progress_step("Loading transactions from Up Bank API")

  spec <- api_specs |>
    dplyr::filter(
      endpoint == transaction_endpoint,
      operation == "get"
    ) |>
    dplyr::pull(spec) |>
    _[[1]]

  query_up_api(req) |>
    process_response() |>
    json_decoder(
      spec = spec,
      formatter = standard_transaction_formatter
    )
}
