# dataframe utilities
### data frame to bt_obj
from_data_frame <- function(df){
    stopifnot(is.data.frame(df))
    location <- paste0('/tmp/', paste0(sample(c(LETTERS, letters, 0:9), 6), collapse = '') , '.bed')
    suppressMessages(suppressWarnings(write_tsv(df, location, col_names = F)))
    return(bedtools_obj(location))
}

### bt_obj to data_fram
to_data_frame <- function(obj){
    if(!is.bt_obj(obj)) stop('Can only convert an object to a data frame')
    location <- unclass(obj)
    df <-  suppressMessages(suppressWarnings(read_tsv(location, col_names = F)))
    return(df)
}

