import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd

# Data dari SQL
data = {
    'product_name': ['Vacuum Cleaner', 'Electric Kettle', 'Blender', 
                     'Rice Cooker', 'Air Purifier'],
    'total_revenue': [68234567, 58456789, 48765432, 35678901, 28345678],
    'kontribusi_persen': [26.4, 22.6, 18.9, 13.8, 11.0]
}
df = pd.DataFrame(data).sort_values('total_revenue', ascending=True)

# Buat horizontal bar chart
fig, ax = plt.subplots(figsize=(12, 7))

# Gradient colors
colors = sns.color_palette("viridis", len(df))

# Horizontal bars
bars = ax.barh(df['product_name'], df['total_revenue'], 
               color=colors, edgecolor='white', linewidth=1.5, height=0.6)

# Tambahkan label nilai di kanan bar
for i, (bar, val, pct) in enumerate(zip(bars, df['total_revenue'], df['kontribusi_persen'])):
    ax.text(val + 500000, bar.get_y() + bar.get_height()/2,
            f'Rp {val/1e6:.1f}M ({pct}%)',
            va='center', fontsize=11, fontweight='bold', color='#333333')

# Formatting
ax.set_xlabel('Total Revenue (Rp)', fontsize=12, fontweight='bold')
ax.set_title('🏆 5 Produk dengan Pendapatan Tertinggi (2024)', 
             fontsize=16, fontweight='bold', pad=15)
ax.xaxis.set_major_formatter(plt.FuncFormatter(lambda x, p: f'Rp {x/1e6:.0f}M'))
ax.set_xlim(0, max(df['total_revenue']) * 1.25)

# Grid & style
ax.grid(True, axis='x', alpha=0.3, linestyle='--')
ax.set_axisbelow(True)
sns.despine(left=True, bottom=True)

plt.tight_layout()
plt.savefig('bar_top5_produk.png', dpi=150, bbox_inches='tight')
plt.show()
