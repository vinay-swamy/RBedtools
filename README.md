# RBedtools
Goal is to make a package with similar functionality to pybedtools - easily integrate dataframes with bedtools, and allow for piping from command to command, with results being easily returned as a dataframe
# current ideas
RBT object - a class that contains a string thats the filename of a temporary file

from_dataframe() takes a data frame and returns a RBT object

action() runs a command eg sort, merge, intersect etc 

to_dataframe() converts an to a data frame
