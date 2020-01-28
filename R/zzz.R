.onLoad <- function(libname, pkgname){
    tryCatch(print(paste('using', system2('bedtools','--version', stdout = T))) ,
                   error  = function() {print ('Bedtools not found in path.'); stop()})
}
