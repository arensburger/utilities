#!/usr/bin/env Rscript
# this script creates multiple box plots, however, you have to specify the column names
# by hand on either side of the tilde symbol
# call this program from command line using
# Rscript --vanilla /home/peter/utilities/boxplot2.R <csv file name with headers> <title> <output file name>`;
args = commandArgs(trailingOnly=TRUE)
data = as.data.frame(read.csv(args[1], header = TRUE))
title = args[2]
output_file_name =args[3]

#data=as.data.frame(read.csv("~/Desktop/temp.csv"))

png(output_file_name, width = 800, height = 800, units = "px")
boxplot(data[,2]~data[,1],data=data, main=title, horizontal = TRUE)

dev.off()