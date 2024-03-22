library(scales)


args = commandArgs(trailingOnly=TRUE)
tpmifam <- read.table(args[1], header=FALSE)
colnames(tpmifam) <- c("IID","FID","a","b","SEX","PHENO")
pc1 <- args[2]
pc2 <- args[3]
pop_1kg <- read.table("../igsr_samples.tsv", sep='\t', header=TRUE)
pca <- read.table("pca.eigenvec", sep=' ', header=TRUE)
iseas <- read.table("pca.eas.id", header=TRUE)
noteas <- read.table("pca.not_eas.id", header=TRUE)


if (!dir.exists("plot")){
	dir.create("plot")
}

## AFR AMR EAS EUR EUR,AFR SAS
colors <- c('black','dodgerblue4','gold','forestgreen','firebrick','darkorchid')

pca$color=colors[1]
pca$color[which(pca$IID %in% pop_1kg$Sample.name[which(pop_1kg$Superpopulation.code=='AFR')])]=colors[2]
pca$color[which(pca$IID %in% pop_1kg$Sample.name[which(pop_1kg$Superpopulation.code=='AMR')])]=colors[3]
pca$color[which(pca$IID %in% pop_1kg$Sample.name[which(pop_1kg$Superpopulation.code=='EAS')])]=colors[4]
pca$color[which(pca$IID %in% pop_1kg$Sample.name[which(pop_1kg$Superpopulation.code=='EUR')])]=colors[5]
pca$color[which(pca$IID %in% pop_1kg$Sample.name[which(pop_1kg$Superpopulation.code=='SAS')])]=colors[6]
pca$color[which(pca$IID %in% pop_1kg$Sample.name[which(pop_1kg$Superpopulation.code=='EUR,AFR')])]='gray'

### plot 1KG 5 pop 
png(paste('plot/pca.',pc1,pc2,'.1kg.png', sep=''), width = 2000, height = 2000,  units = "px", pointsize = 56)
plot(pca[which(pca$IID %in% pop_1kg$Sample.name[]), c(pc1,pc2)], col = pca$color[which(pca$IID %in% pop_1kg$Sample.name[])], pch=1, lwd=3)
legend('bottomleft', legend = c('AFR','AMR','EAS','EUR','SAS'), col = c(colors[2],colors[3],colors[4],colors[5],colors[6]),pch=15)
dev.off()

### plot 1KG 5 pop & tpmi 
png(paste('plot/pca.',pc1,pc2,'.tpm1.png', sep=''), width = 2000, height = 2000,  units = "px", pointsize = 56)
plot(pca[which(pca$IID %in% pop_1kg$Sample.name[]), c(pc1,pc2)], col = pca$color[which(pca$IID %in% pop_1kg$Sample.name[])], pch=1, lwd=3)
points(pca[which(pca$IID %in% tpmifam$IID[]), c(pc1,pc2)], col = 'gray50', pch=4, lwd=3)
legend('bottomleft', legend = c('tpm1','AFR','AMR','EAS','EUR','SAS'), col = c('gray50',colors[2],colors[3],colors[4],colors[5],colors[6]),pch=15)
dev.off()

### plot 1KG 5 pop & tpmi cutting line 
png(paste('plot/pca.',pc1,pc2,'.cut_eas.tpm1.png', sep=''), width = 2000, height = 2000,  units = "px", pointsize = 56)
plot(pca[which(pca$IID %in% pop_1kg$Sample.name[]), c(pc1,pc2)], col = pca$color[which(pca$IID %in% pop_1kg$Sample.name[])], pch=1, lwd=3)
points(pca[which(pca$IID %in% tpmifam$IID[]), c(pc1,pc2)], col = 'gray50', pch=4, lwd=3)
lines(c(-0.03,0),c(0,0.025),col='black', lwd=3)
legend('bottomleft', legend = c('tpm1','AFR','AMR','EAS','EUR','SAS'), col = c('gray50',colors[2],colors[3],colors[4],colors[5],colors[6]),pch=15)
dev.off()

### plot 1KG 5 pop & tpmi cutting line & assignment 
png(paste('plot/pca.',pc1,pc2,'.eas.tpm1.png', sep=''), width = 2000, height = 2000,  units = "px", pointsize = 56)
plot(pca[which(pca$IID %in% pop_1kg$Sample.name[]), c(pc1,pc2)], col = pca$color[which(pca$IID %in% pop_1kg$Sample.name[])], pch=1, lwd=3)
points(pca[which(pca$IID %in% tpmifam$IID[]), c(pc1,pc2)], col = 'gray50', pch=4, lwd=3)
points(pca[which(pca$IID %in% iseas$IID[]), c(pc1,pc2)], col = 'black', pch=4, lwd=3)
lines(c(-0.03,0),c(0,0.025),col='black', lwd=3)
legend('bottomleft', legend = c('tpm1','AFR','AMR','EAS','EUR','SAS'), col = c('gray50',colors[2],colors[3],colors[4],colors[5],colors[6]),pch=15)
dev.off()

### plot not eas
png(paste('plot/pca.',pc1,pc2,'.not_eas.tpm1.png', sep=''), width = 2000, height = 2000,  units = "px", pointsize = 56)
plot(pca[which(pca$IID %in% pop_1kg$Sample.name[]), c(pc1,pc2)], col = pca$color[which(pca$IID %in% pop_1kg$Sample.name[])], pch=1, lwd=3)
points(pca[which(pca$IID %in% tpmifam$IID[]), c(pc1,pc2)], col = 'gray50', pch=4, lwd=3)
points(pca[which(pca$IID %in% noteas$IID[] & pca$IID %in% tpmifam$IID[]), c(pc1,pc2)], col = 'black', pch=4, lwd=3)
lines(c(-0.03,0),c(0,0.025),col='black', lwd=3)
legend('bottomleft', legend = c('tpm1','AFR','AMR','EAS','EUR','SAS'), col = c('gray50',colors[2],colors[3],colors[4],colors[5],colors[6]),pch=15)
dev.off()

############ Zoom in EAS ####################
pca$color=colors[1]
pca$color[which(pca$FID %in% pop_1kg$Sample.name[which(pop_1kg$Population.code=='CDX')])]=colors[2]
pca$color[which(pca$FID %in% pop_1kg$Sample.name[which(pop_1kg$Population.code=='CHB')])]=colors[3]
pca$color[which(pca$FID %in% pop_1kg$Sample.name[which(pop_1kg$Population.code=='CHS')])]=colors[4]
pca$color[which(pca$FID %in% pop_1kg$Sample.name[which(pop_1kg$Population.code=='JPT')])]=colors[5]
pca$color[which(pca$FID %in% pop_1kg$Sample.name[which(pop_1kg$Population.code=='KHV')])]=colors[6]


png(paste('plot/pca.',pc1,pc2,'.eas.png', sep=''), width = 2000, height = 2000,  units = "px", pointsize = 56)
plot(pca[which(pca$IID %in% pop_1kg$Sample.name[which(pop_1kg$Superpopulation.code=='EAS')]), c(pc1,pc2)], col = pca$color[which(pca$IID %in% pop_1kg$Sample.name[which(pop_1kg$Superpopulation.code=='EAS')])], pch=16, ylim=c(-0.1,0.1))
points(pca[which(pca$IID %in% tpmifam$IID[]), c(pc1,pc2)], col = 'gray50', pch='+')
legend('bottomright', legend = c('CDX','CHB','CHS','JPT','KHV'), col = c(colors[2],colors[3],colors[4],colors[5],colors[6]), pch=15)
dev.off()
