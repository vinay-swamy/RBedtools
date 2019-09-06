
#classes

### object to store bedtools command, used when piping
bedtools_command <- function(cmd){
    if(!is.character(cmd)) stop('Bad Command Constructor Input')
    return(structure(cmd, class='bt_cmd'))
}
### object that contains string that is the path to a bedtools file
bedtools_obj <- function(file){
    if((!file.exists(file)) | (length(file)!=1)) stop('bad object contstructor input')
    return(structure(file, class='bt_obj'))

}

#validators
is.bt_obj <- function(x) {return(class(x) == 'bt_obj')}
is.bt_command <- function(x) {return(class(x) == 'bt_cmd')}


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


#main functions
bedtools <- function(tool, options, output, ...){
    input_raw <- list(...)
    input_raw <- process_bt_obj(input_raw)  #check if inputs contain any bedtools command objects

    #find arguments that correspond to files, and throw error if any are do not exist
    which_cmd <- which(sapply(input_raw, function(x) class(x) == 'bt_cmd'))
    if(length(which_cmd)>0){   #print('pipe mode ')
        if(length(which_cmd) >1) stop('there should only be one incomming command. Something is wrong') # only one piped input
        old_cmd <- unclass(input_raw[[which_cmd]])
        inputs_only <- input_raw[-which_cmd]
        if(!check_files_exist(inputs_only)) stop('one or more input files does not exist')
        input_raw[[which_cmd]] <- 'stdin'
        input_processed <- collapse_input_lists(input_raw)
        input_char <- parse_args(input_processed)
        cmd <- paste(old_cmd, 'bedtools', tool, options,input_char)
    } else {
        if(!check_files_exist(input_raw)) stop('one or more input files does not exist')
        input_processed <- collapse_input_lists(input_raw)
        input_char <- parse_args(input_processed)
        cmd <- paste(tool, options, input_char)
    }

    if(output == 'stdout'){ #write pipe
        cmd <- paste(cmd, '|')
        return(bedtools_command(cmd))
    } else {
        cmd <- paste(cmd, '>', output)
        system2('bedtools', cmd)
        return(bedtools_obj(output))
    }

}

bedtools('intersect','-loj', 'stdout', a='a.bed', b='b.bed') # vanilla usage
bedtools('intersect','-loj', 'c.bed', a=bedtools_obj('x.bed'), b='b.bed', g='genome.fa') # test out using an bt_obj
bedtools('intersect','-loj', 'c.bed', a=bedtools_command('intersect -a x.bed -b m.bed |'), b='b.bed', g='genome.fa')



