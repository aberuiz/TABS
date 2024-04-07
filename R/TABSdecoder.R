#' Recode values
#'
#' @description
#' Will submit appropriate codes to TDLR and return plain language values to user

TABSdecoder <- function(codes,..., codebook_df=dat) {
  # Ensure the codebook dataframe has two columns: numeric_value and character_value
  if (!all(c("code", "value") %in% colnames(codebook_df))) {
    stop("Codebook dataframe must have columns 'code' and 'value'")
  }

  if (is.numeric(codes)){
    # Use match to find the corresponding character values based on numeric values
    character_values <- codebook_df$value[match(codes, codebook_df$code)]

    return(character_values)
  } else {
    numeric_values <- codebook_df$code[match(codes, codebook_df$value)]

    return(numeric_values)
  }
}
