args = commandArgs(trailingOnly=TRUE)
data_money = as.data.frame(read.csv(args[1], header = TRUE))
title = args[2]
output_file_name = args[3]
#data_money = as.data.frame(read.csv("/home/peter/Dropbox/Money/Retirement/retirement modeling/temp.output", header=TRUE))
#title = "temp title"
#output_file_name = "outfile.pdf"

income = data_money$cash + data_money$dividend - data_money$expense

pdf(output_file_name)
old.par = par(mfrow=c(2, 1)) # setup graphs in columns
boxplot(income~year,data=data_money, main=c(title, "Total Income"), ylab="Year", xlab="Yearly Income (in $)", horizontal = TRUE)
boxplot(stock~year,data=data_money, main=c(title, "Stock Value"), ylab="Year", xlab="Stock Value (in $)", horizontal = TRUE)
par(old.par) # output graphs
dev.off()