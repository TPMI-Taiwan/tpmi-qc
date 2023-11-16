import pandas as pd
import numpy as np
import sys

info = sys.argv[1]  ## sample/batch info (IID, batch, site)
batch = pd.read_csv(info, sep=' ', skiprows = 1, names=['IID','BATCH','SITE'])


for idx,s1 in enumerate(batch['SITE'].unique()[0:]):
    for s2 in batch['SITE'].unique()[idx+1:]:
            c=s1+"vs"+s2
            batch[c] = np.where(batch['SITE']==s1, '1', np.where(batch['SITE']==s2, '0', np.nan))
batch = batch.replace("nan", np.nan)
batch.to_csv('run.site.txt',index=False,sep=',')

for idx,b1 in enumerate(batch['BATCH'].unique()[0:]):
    for b2 in batch['BATCH'].unique()[idx+1:]:
            c=b1+"vs"+b2
            batch[c] = np.where(batch['BATCH']==b1, '1', np.where(batch['BATCH']==b2, '0', np.nan))

batch = batch.replace("nan", np.nan)
batch.to_csv('run.all.txt',index=False,sep=',')

