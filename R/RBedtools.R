#main functions
RBedtools <- function(tool, options, output, ...){
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
