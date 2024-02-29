import pandas as pd
import sys
import numpy as np

pre=sys.argv[1]
k = int(sys.argv[2])
igsr=sys.argv[3]

c = ['v1','v2','v3','v4','v5','v6','v7','v8','v9','v10']
tbl = pd.read_csv(pre+'.'+str(k)+'.Q',sep=' ',names=c[:k])
fam = pd.read_csv(pre+'.fam',sep=' ',names=['IID','FID','a','b','c','d'])
pop = pd.read_csv(igsr, sep='\t')

m1 = pd.concat([fam['IID'],tbl], axis=1, join='inner')
m2 = m1.merge(pop, left_on='IID', right_on='Sample name', how='left')

mean_df = pd.DataFrame()

mean_df['CDX'] = m2.loc[m2['Population elastic ID'] == 'CDX'].iloc[:,1:k+1].mean()
mean_df['CHB'] = m2.loc[m2['Population elastic ID'] == 'CHB'].iloc[:,1:k+1].mean()
mean_df['CHS'] = m2.loc[m2['Population elastic ID'] == 'CHS'].iloc[:,1:k+1].mean()
mean_df['JPT'] = m2.loc[m2['Population elastic ID'] == 'JPT'].iloc[:,1:k+1].mean()
mean_df['KHV'] = m2.loc[m2['Population elastic ID'] == 'KHV'].iloc[:,1:k+1].mean()


mean_df.transpose().to_csv(pre+'.'+str(k)+'.mean',index=True, sep='\t', float_format='%.6f')

idmax = m2[c[:k]].idxmax(axis=1)
max1 = m2[c[:k]].max(axis=1)
max2 = m2[c[:k]].apply(lambda row: row.nlargest(2).values[-1], axis=1)

out = pd.concat([m2['IID'],m2[c[:k]],max1,max2,idmax,m2['Population elastic ID']], axis=1, join='inner')
out.rename(columns={ 0:'max', 1:'second', 2:'max_group', 'Population elastic ID':'pop'}, inplace=True)
out.to_csv(pre+'.'+str(k)+'.output.txt',index=False, sep='\t', float_format='%.6f')

out['gt04']= np.where((out['max'] >= 0.4) & ((out['max']-out['second'])>0.1), out['max_group'], '-')
out['gt05']= np.where((out['max'] >= 0.5) & ((out['max']-out['second'])>0.1), out['max_group'], '-')
out['gt06']= np.where(out['max'] >= 0.6, out['max_group'], '-')
out['gt07']= np.where(out['max'] >= 0.7, out['max_group'], '-')
out['gt08']= np.where(out['max'] >= 0.8, out['max_group'], '-')
out['gt09']= np.where(out['max'] >= 0.9, out['max_group'], '-')
out['gt065']= np.where(out['max'] >= 0.65, out['max_group'], '-')

out[['IID','max','second','max_group','gt04','gt05','gt06','gt07','gt08','gt09','gt065']].to_csv(pre+'.pop_assign.txt', index=False, sep='\t', float_format='%.6f')


