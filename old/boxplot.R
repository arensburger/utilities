#!/usr/bin/env Rscript
# call this program from perl or command line using
# my $o = `Rscript --vanilla /home/peter/utilities/boxplot.R $tmp_fh title axisname temp3.pdf`;
args = commandArgs(trailingOnly=TRUE)
data = read.table(args[1], header = FALSE)
title = args[2]
xaxis_title = args[3]
output_file_name = args[4]

pdf(output_file_name)
boxplot(data$V1, main=title, xlab=xaxis_title)
dev.off()