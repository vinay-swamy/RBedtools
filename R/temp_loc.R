tmp_loc <- function(){
    location <- paste0('/tmp/', paste0(sample(c(LETTERS, letters, 0:9), 6), collapse = '') , '.bed')
    location
}
