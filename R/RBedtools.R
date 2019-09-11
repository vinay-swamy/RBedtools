#' Main interface to bedtools
#' @param tool which bedtools function to use
#' @param options A character vector containing options to use for tools. use bedtools intersec -h on CL to see options
#' @param output can be either a path to a file to write to, or 'stdout' to direct output to new bedtools command
#' @param ... Arguments to pass to bed tools that are specfic to tool
#' @return  a bedtools object that points to an output file, or bedtools command object to add to another command
#' @export

#main functions
RBedtools <- function(tool, options='', output=tmp_loc(), ...){
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
