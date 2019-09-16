
<!-- README.md is generated from README.Rmd. Please edit that file -->

# RBedtools

<!-- badges: start -->

<!-- badges: end -->

RBedtools is a light wrapper for the
[bedtools](https://bedtools.readthedocs.io/en/latest/) software suite.

I wrote this package for several reasons

  - I wanted to use bedtools in R. Other packages seemed unnecessarily
    complicated to use, and native R packages that have simlilar
    functions as bedtools(read GenomicRanges) were also difficult to use
  - I found myself writing a dataframe to a bed file, running bedtools
    in a notebook or with system2, then reading it back into R

## Installation

You can install RBedtools from here with:

``` r
# install.packages("devtools")
devtools::install_github("vinay-swamy/RBedtools")
```

Remember to install bedtools as well. Instructions can be found
[here](https://bedtools.readthedocs.io/en/latest/content/installation.html)

## Design

I tried to make this package as simple to use as I could. I assumed that
the user has some knowledge of how bedtools works and have very little
error checking with regards to bedtools input. If you get an error
message from bedtools, and not from this package, its likely your
bedtools command was wrong. The actual format of bed files/ data frames
is not checked, ie 0 based, number of columns etc.

### objects

All RBedtools object are simple S3 objects.

`bt_obj`: an object that contains a charcter vector that is the path to
a bed file.

`bt_cmd`: a object containing a stored and unrun bedtools command. See
below for more info

## functions

RBedtools’ core function is `RBedtools`

``` r
library(RBedtools)
args('RBedtools')
```

    function (tool, options = "", output = tmp_loc(), ...) 
    NULL

`tool` is the bedtools function you would like to use, eg intersect,
sort, closest etc

`options` are the options for selected tool. It must be formated as a
single character vector in the following way: `'-option1 input1 option2
input2'` the default option is no option

`output` can one of three options: blank, a character vector specifying
a location to write a bed file, or `'stdout'` signifying the output of
this bedtools command will be piped to another command. More on that
below

`...` The actual arguments for the bedtools function, in the following
format: `arg1='<path_to_bed>', arg2='<path_to_bed>'`

#### helpers

there are 2 functions to allow for use of data frame, `from_data_frame`,
and `to_data_frame`

`from_data_frame` takes a data frame as an input and returns a bedtools
object

`to_data_frame` takes a bedtools object and returns a data frame

## examples

sort a bed file. specifying no output will write to a file in the
`/tmp/` directory

``` r
library(RBedtools)
sorted.bed <- RBedtools(tool = 'sort', i='data/gerp.chr1.bed.gz')
unclass(sorted.bed)
```

    [1] "/tmp/kceIDF.bed"

otherwise the bed is written to the output
argument

``` r
sorted.bed <- RBedtools(tool = 'sort',output = 'sorted.bed' i='data/gerp.chr1.bed.gz')
```

use the `to_data_frame` command to convert a `bt_obj` to a dataframe

``` r
sorted.bed <- RBedtools(tool = 'sort', i='data/gerp.chr1.bed.gz')
sorted.bed.df <- to_data_frame(sorted.bed)
head(sorted.bed.df)
```

    # A tibble: 6 x 4
      X1       X2    X3       X4
      <chr> <dbl> <dbl>    <dbl>
    1 chr1  13219 13390 4.22e- 7
    2 chr1  14695 14837 5.13e- 8
    3 chr1  15784 15947 5.32e-10
    4 chr1  16848 17058 5.28e-10
    5 chr1  17231 17374 3.46e- 9
    6 chr1  17604 17751 1.40e- 9

piping is also supported(and encouraged)

``` r
suppressMessages(library(dplyr))
sorted.bed.df <-  RBedtools(tool = 'sort', i='data/gerp.chr1.bed.gz') %>% to_data_frame
head(sorted.bed.df)
```

    # A tibble: 6 x 4
      X1       X2    X3       X4
      <chr> <dbl> <dbl>    <dbl>
    1 chr1  13219 13390 4.22e- 7
    2 chr1  14695 14837 5.13e- 8
    3 chr1  15784 15947 5.32e-10
    4 chr1  16848 17058 5.28e-10
    5 chr1  17231 17374 3.46e- 9
    6 chr1  17604 17751 1.40e- 9

Use a single character vector for `options` to specfify options for
bedtools command. format `options` as you would on the command line

``` r
intersect_loj <- RBedtools(tool = 'intersect',
                            options = '-loj',
                            a='data/gerp.chr1.bed.gz',
                            b='data/aluY.chr1.bed.gz') %>% to_data_frame
head(intersect_loj)
```

``` 
# A tibble: 6 x 10
  X1       X2    X3       X4 X5       X6    X7 X8       X9 X10  
  <chr> <dbl> <dbl>    <dbl> <chr> <dbl> <dbl> <chr> <dbl> <chr>
1 chr1  13219 13390 4.22e- 7 .        -1    -1 .        -1 .    
2 chr1  14695 14837 5.13e- 8 .        -1    -1 .        -1 .    
3 chr1  15784 15947 5.32e-10 .        -1    -1 .        -1 .    
4 chr1  16848 17058 5.28e-10 .        -1    -1 .        -1 .    
5 chr1  17231 17374 3.46e- 9 .        -1    -1 .        -1 .    
6 chr1  17604 17751 1.40e- 9 .        -1    -1 .        -1 .    
```

Using an R data frame

``` r
closest <- sorted.bed.df %>% from_data_frame %>% 
    RBedtools('closest', a=., b='data/gerp.chr1.bed.gz') %>% to_data_frame
head(closest)
```

    # A tibble: 6 x 8
      X1       X2    X3       X4 X5       X6    X7       X8
      <chr> <dbl> <dbl>    <dbl> <chr> <dbl> <dbl>    <dbl>
    1 chr1  13219 13390 4.22e- 7 chr1  13219 13390 4.22e- 7
    2 chr1  14695 14837 5.13e- 8 chr1  14695 14837 5.13e- 8
    3 chr1  15784 15947 5.32e-10 chr1  15784 15947 5.32e-10
    4 chr1  16848 17058 5.28e-10 chr1  16848 17058 5.28e-10
    5 chr1  17231 17374 3.46e- 9 chr1  17231 17374 3.46e- 9
    6 chr1  17604 17751 1.40e- 9 chr1  17604 17751 1.40e- 9

An `RBedtools` command can also be piped to another `RBedtools` command,
using `'stdout'` as the output of the first command. When `'stdout'`
using `.` place holder for one of the arguments in the second
command.

``` r
sort_and_intersect <- RBedtools(tool = 'sort', output = 'stdout', i='data/gerp.chr1.bed.gz') %>% 
    RBedtools(tool = 'intersect', a=., b='data/aluY.chr1.bed.gz') %>% 
    to_data_frame 
head(sort_and_intersect)
```

    # A tibble: 6 x 4
      X1          X2       X3        X4
      <chr>    <dbl>    <dbl>     <dbl>
    1 chr1   8837592  8837599 8.72e-  7
    2 chr1   9986239  9986242 3.45e- 37
    3 chr1  12053803 12053818 4.57e- 21
    4 chr1  12687654 12687666 1.64e- 66
    5 chr1  16236644 16236646 6.46e-  9
    6 chr1  38030280 38030281 4.44e-111

An importnant note about piping multiple RBedtools commands

Using `'stdout'` makes `RBedtools` return a `bt_cmd` object, which is a
constructed but unrun
command

``` r
output_for_pipe <-  RBedtools(tool = 'sort', output = 'stdout', i='data/gerp.chr1.bed.gz')
class(output_for_pipe)
```

    [1] "bt_cmd"

Commands are not run until the RBedtools commands is run. This allows
for the contruction of a single command that uses shell pipes `|`

``` r
unclass(output_for_pipe)
```

    [1] "sort  -i data/gerp.chr1.bed.gz |"

if you do not specify `'stdout'` when chaining commands, the code will
still run, but the output of each command will be written to a file and
read each time, which may significantly slow down your code

Full Disclaimer, I havent tested this on all the bedtools functions. I
use the sorted, intersect and closest the most, so these are the ones I
tested on. If you find a bug/have any improvements, let me know.
