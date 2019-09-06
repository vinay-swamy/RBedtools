#validators
is.bt_obj <- function(x) {return(class(x) == 'bt_obj')}
is.bt_command <- function(x) {return(class(x) == 'bt_cmd')}
