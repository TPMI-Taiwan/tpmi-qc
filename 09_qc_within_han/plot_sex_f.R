library(tidyverse)

### check sex
sex <- read.table("check_sex.sexcheck",header=TRUE)
sex_x <- sex %>% rowid_to_column(var='x')

pdf('EAS_check_sex_F.pdf')
plot(sex_x[,c('x','F')],pch='.')
axis(2, seq(from = -0.5, to = 1, by = 0.2))
dev.off()

#### het check
het <- read.table("het_check.het",header=TRUE)

pdf('het_check.pdf')
hist(het$F, col='blue')
dev.off()

# zoom in
pdf('het_check.enlarge.pdf')
hist(het$F, col='blue', ylim=c(0,2000))
dev.off()
