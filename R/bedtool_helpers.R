#helper args
### convert list of args to a single string
parse_args <- function(argl){
    arg_names <- names(argl)
    arg_charl <- sapply(seq_along(arg_names), function(i) paste0('-', arg_names[i],' ', argl[[i]]))
    return(paste(arg_charl, collapse = ' '))
}
### convert single input lists to a single string
collapse_input_lists <- function(argl){
    idx <- which(sapply(argl, length) > 1)
    if(length(idx) >0){
        argl[idx] <- lapply(argl[idx], function(x) paste(x, collapse=' '))
    }
    return(argl)
}
### file paths validation
check_files_exist <- function(argl){
    all_file_args <- c('a', 'b', 'i', 'g', 'fq', 'ibam', 'abam', 'fi', 'fo', 'bams', 'bed')
    found_file_args <- names(argl)[names(argl) %in% all_file_args]
    input_files <- argl[found_file_args]
    return(all(unlist(sapply(input_files, file.exists))) )
}
### extract bt_obj names and replace in argument list
process_bt_obj <- function(argl){
    idx <- which(sapply(argl, is.bt_obj))
    if(length(idx) >0){
        argl[idx] <- lapply(argl[idx], function(x) unclass(x))
    }
    return(argl)
}
