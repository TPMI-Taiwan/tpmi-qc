
frq = read.table('all_freq.txt',sep='\t',header=T)
diff=apply(frq[,-1],MARGIN=1,function(x) max(x)-min(x))
write.table(frq[which(diff>0.1),c('id')],'af_diff_gt_01.id',row.names=F,col.names=F,quote=F)
