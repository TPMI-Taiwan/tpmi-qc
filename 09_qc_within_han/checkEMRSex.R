t <- read.table('emr_sex.list')
colnames(t) <- c('FID','IID','sex')
t$sex[which(t$sex=='Male')] <- 1
t$sex[which(t$sex=='Female')] <- 2

f <- read.table('check_sex.sexcheck', header=T)
m <- merge(f, t, by='IID', all.x=T)

write.table(m$IID[which(m$sex!=m$SNPSEX)], 'emr_geno_inconsistent_gender.id', quote=F, row.names=F, col.names=F)
write.table(m$IID[which(is.na(m$sex)&(m$SNPSEX==0))], 'emr_geno_gender_fail.id', quote=F, row.names=F, col.names=F)
