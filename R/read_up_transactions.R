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
read_up_transactions <- function(transaction_id = NULL, status = c("HELD", "SETTLED"), since = NULL, until = NULL, category = NULL, tag = NULL) {
  stopifnot("transaction_id must be NULL or a character of length 1" = missing(transaction_id) || is.character(transaction_id) && length(transaction_id) == 1)
  stopifnot("category must be NULL or a character of length 1" = missing(category) || is.character(category) && length(category) == 1)
  stopifnot("tag must be NULL or a character of length 1" = missing(tag) || is.character(tag) && length(tag) == 1)

  if (!missing(status)) {
    status <- rlang::arg_match(status)
  }

  req <- get_base_request() |>
    add_path_to_req("transactions")

  if (!missing(transaction_id)) {
    req <- add_path_to_req(req, transaction_id, "transaction_id")
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

  query_up_api(req) |>
    process_response()
}
