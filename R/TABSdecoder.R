#' Recode values to and from TDLR
#'
#' @param codes variable sent to codebook for deciphering
#' @param codebook_df codebook dataframe to check codes against, by default this uses the built in `codebook`
#'
#' @description
#' Will submit appropriate codes to TDLR and return plain language values to user.
#' Name lookups are case-insensitive and ignore surrounding whitespace.
TABSdecoder <- function(codes, codebook_df=codebook) {
  # Ensure the codebook dataframe has two columns: numeric_value and character_value
  if (!all(c("code", "value") %in% colnames(codebook_df))) {
    stop("Codebook dataframe must have columns 'code' and 'value'")
  }

  if (is.numeric(codes)){
    # Use match to find the corresponding character values based on numeric values
    character_values <- codebook_df$value[match(codes, codebook_df$code)]

    return(character_values)
  } else {
    # Match names case-insensitively (and ignore surrounding whitespace) so
    # users don't have to reproduce TDLR's exact capitalization.
    numeric_values <- codebook_df$code[
      match(tolower(trimws(codes)), tolower(trimws(codebook_df$value)))
    ]

    # A name absent from the codebook would otherwise be pasted into the TDLR
    # request as the literal string "NA" and silently return the wrong results.
    # Fail loudly so typos surface at the call site. Blank/NA inputs are ignored
    # (they represent "no filter"), and this branch is only reached for name
    # look-ups: numeric code decoding above is intentionally left untouched.
    supplied <- !is.na(codes) & nzchar(trimws(as.character(codes)))
    unmatched <- supplied & is.na(numeric_values)
    if (any(unmatched)) {
      stop(
        "Value(s) not found in the codebook: ",
        paste0('"', codes[unmatched], '"', collapse = ", "),
        call. = FALSE
      )
    }

    return(numeric_values)
  }
}
