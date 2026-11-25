import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
import numpy as np

# Data dari SQL
data = {
    'transaction_id': [f'T{i:04d}' for i in range(1, 181)],
    'quantity': np.random.randint(1, 6, 180),
    'total_price': np.random.randint(200000, 5000000, 180),
    'region_name': np.random.choice(['Jakarta', 'Surabaya', 'Bandung', 'Medan', 'Makassar'], 180),
    'product_name': np.random.choice(['Blender', 'Rice Cooker', 'Vacuum Cleaner', 'Electric Kettle', 'Air Purifier'], 180)
}
df = pd.DataFrame(data)

# Buat figure dengan 2 subplot
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 7))

# ============================================
# SCATTER PLOT (kiri): Quantity vs Total Price
# ============================================
palette = {'Jakarta': '#2E86AB', 'Surabaya': '#A23B72', 'Bandung': '#F18F01',
           'Medan': '#C73E1D', 'Makassar': '#44BBA4'}

for region in df['region_name'].unique():
    subset = df[df['region_name'] == region]
    ax1.scatter(subset['quantity'], subset['total_price'], 
                s=100, alpha=0.7, label=region, 
                color=palette[region], edgecolors='white', linewidth=0.5)

# Trend line
z = np.polyfit(df['quantity'], df['total_price'], 1)
p = np.poly1d(z)
ax1.plot(df['quantity'], p(df['quantity']), 
         "r--", alpha=0.8, linewidth=2, label='Trend Line')

ax1.set_xlabel('Quantity (unit)', fontsize=12, fontweight='bold')
ax1.set_ylabel('Total Price (Rp)', fontsize=12, fontweight='bold')
ax1.set_title('🔍 Hubungan Quantity vs Total Price per Wilayah', 
              fontsize=14, fontweight='bold')
ax1.legend(title='Wilayah', fontsize=9)
ax1.grid(True, alpha=0.3, linestyle='--')
ax1.yaxis.set_major_formatter(plt.FuncFormatter(lambda x, p: f'Rp {x/1e6:.1f}M'))

# ============================================
# COMBO CHART (kanan): Avg Price per Wilayah
# ============================================
region_stats = df.groupby('region_name').agg({
    'total_price': 'mean',
    'quantity': 'sum',
    'transaction_id': 'count'
}).reset_index()
region_stats.columns = ['region', 'avg_price', 'total_qty', 'jml_trx']
region_stats = region_stats.sort_values('avg_price', ascending=True)

# Horizontal bar
colors_bar = [palette[r] for r in region_stats['region']]
bars = ax2.barh(region_stats['region'], region_stats['avg_price'], 
                color=colors_bar, edgecolor='white', height=0.6)

# Label
for bar, val in zip(bars, region_stats['avg_price']):
    ax2.text(val + 50000, bar.get_y() + bar.get_height()/2,
             f'Rp {val/1e6:.2f}M',
             va='center', fontsize=10, fontweight='bold')

ax2.set_xlabel('Rata-rata Harga per Transaksi (Rp)', fontsize=12, fontweight='bold')
ax2.set_title('💰 Rata-rata Harga per Wilayah', fontsize=14, fontweight='bold')
ax2.xaxis.set_major_formatter(plt.FuncFormatter(lambda x, p: f'Rp {x/1e6:.1f}M'))
ax2.grid(True, axis='x', alpha=0.3, linestyle='--')
ax2.set_axisbelow(True)

plt.tight_layout()
plt.savefig('scatter_combo.png', dpi=150, bbox_inches='tight')
plt.show()
