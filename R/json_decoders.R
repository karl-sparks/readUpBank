#' Decode Json
#'
#'  These functions decode the response json from a range of Up Bank API end points. It uses S3 to determine which decoder to use.
#'
#' @param resp response from the up bank API
#'
#' @return tibble containing the contents of the response json.
json_decoder <- function(resp_list, spec, formatter) {
  resp_list |>
    purrr::map(
      \(x)
      httr2::resp_body_json(x) |>
        tibblify::tibblify(
          spec = spec
        )
    ) |>
    dplyr::bind_rows() |>
    formatter()
}


raw_formatter <- function(processed_resp) {
  processed_resp
}


standard_transaction_formatter <- function(processed_resp) {
  processed_resp |>
    dplyr::select("data") |>
    tidyr::unnest("data") |>
    tidyr::unnest(c("attributes", "relationships")) |>
    tidyr::unnest(c("amount", "foreignAmount", "cardPurchaseMethod", "account", "transferAccount"), names_sep = "_") |>
    tidyr::unnest(c("account_data", "transferAccount_data", "account_links", "transferAccount_links"), names_sep = "_") |>
    tidyr::unnest(c("status", "note", "performingCustomer", "links", "cardPurchaseMethod_method")) |>
    dplyr::mutate(
      dplyr::across(
        tidyr::all_of(c("settledAt", "createdAt")),
        \(x) lubridate::as_datetime(x) |> lubridate::with_tz("Australia/Sydney")
      ),
      status = factor(status, levels = c("HELD", "SETTLED")),
      cardPurchaseMethod_method = factor(cardPurchaseMethod_method, levels = c("BAR_CODE", "OCR", "CARD_PIN", "CARD_DETAILS", "CARD_ON_FILE", "ECOMMERCE", "MAGNETIC_STRIPE", "CONTACTLESS"))
    )
}
