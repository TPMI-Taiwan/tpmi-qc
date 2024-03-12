#### Maximum SNP-level missing rate difference between two batches (histogram)
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import sys

count=int(sys.argv[1])+1
miss = pd.read_csv('all_f_miss.txt',sep='\t')
all_miss = miss.iloc[:,1:count:2]
miss_diff = pd.DataFrame()
miss_diff['snp'] = miss.iloc[:,0]
miss_diff['min'] = all_miss.min(axis=1)
miss_diff['max'] = all_miss.max(axis=1)
miss_diff['diff'] = miss_diff['max'] - miss_diff['min']

plt.figure(figsize=(12,8),edgecolor='blue')
plt.hist(miss_diff['diff'], bins=50, color='steelblue',edgecolor='blue')
plt.xlabel('\nMissing difference\n', fontsize = 16)
plt.ylabel('\nCount\n', fontsize = 16)
plt.tick_params( labelsize = 12)
plt.legend()
plt.savefig(f'snp_missing_diff.png')

miss_diff.to_csv('missing_diff.txt', sep=',', index=False)
miss_diff[miss_diff['diff']>0.02]['snp'].to_csv('missing_diff.gt_002.txt', sep=',', index=False, header=False)
