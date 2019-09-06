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
