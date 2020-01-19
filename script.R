library(ggplot2)
library(haven)
# read in the auto data
nlsw88 <- read_dta('nlsw88.dta')
# make a hexagonal bin scatterplot
png('~/hexbin.png')
ggplot(nlsw88, aes(hours, wage)) + geom_hex()
dev.off()
