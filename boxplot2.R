#!/usr/bin/env Rscript
# this script creates multiple box plots, however, you have to specify the column names
# by hand on either side of the tilde symbol
# call this program from command line using
# Rscript --vanilla /home/peter/utilities/boxplot2.R <csv file name with headers>`;
args = commandArgs(trailingOnly=TRUE)
data = as.data.frame(read.csv(args[1], header = TRUE))
title = "this is the title"
output_file_name = "temp.png"

png(output_file_name)
boxplot(coverage~chromosome,data=data, main=title, horizontal = FALSE)
dev.off()