import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd

# Data dari SQL query
data = {
    'bulan': ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
    'total_revenue': [42345678, 23456789, 48765432, 35678901, 45234567, 52345678],
    'jumlah_transaksi': [28, 18, 32, 25, 30, 35]
}
df = pd.DataFrame(data)

# Buat figure dengan 2 sumbu Y (combo chart)
fig, ax1 = plt.subplots(figsize=(12, 6))

# Warna tema
color_rev = '#2E86AB'
color_trx = '#F18F01'

# Line chart untuk Revenue (sumbu kiri)
ax1.set_xlabel('Bulan (2024)', fontsize=12, fontweight='bold')
ax1.set_ylabel('Total Revenue (Rp)', color=color_rev, fontsize=12, fontweight='bold')
line1 = ax1.plot(df['bulan'], df['total_revenue'], 
                 color=color_rev, marker='o', linewidth=3, 
                 markersize=10, label='Total Revenue')
ax1.tick_params(axis='y', labelcolor=color_rev)
ax1.yaxis.set_major_formatter(plt.FuncFormatter(lambda x, p: f'Rp {x/1e6:.1f}M'))

# Bar chart untuk Jumlah Transaksi (sumbu kanan)
ax2 = ax1.twinx()
ax2.set_ylabel('Jumlah Transaksi', color=color_trx, fontsize=12, fontweight='bold')
bars = ax2.bar(df['bulan'], df['jumlah_transaksi'], 
               alpha=0.3, color=color_trx, label='Jumlah Transaksi')
ax2.tick_params(axis='y', labelcolor=color_trx)

# Tambahkan label nilai di atas bar
for bar in bars:
    height = bar.get_height()
    ax2.text(bar.get_x() + bar.get_width()/2., height + 0.5,
             f'{int(height)}', ha='center', va='bottom', 
             fontsize=10, fontweight='bold', color=color_trx)

# Title dan grid
plt.title('📈 Tren Total Penjualan per Bulan (2024)', 
          fontsize=16, fontweight='bold', pad=20)
ax1.grid(True, alpha=0.3, linestyle='--')
ax1.set_axisbelow(True)

# Legend gabungan
lines1, labels1 = ax1.get_legend_handles_labels()
lines2, labels2 = ax2.get_legend_handles_labels()
ax1.legend(lines1 + lines2, labels1 + labels2, loc='upper left', fontsize=10)

plt.tight_layout()
plt.savefig('line_chart_tren.png', dpi=150, bbox_inches='tight')
plt.show()

# Insight
print("\n💡 INSIGHT:")
print(f"• Bulan tertinggi: Juni (Rp {max(df['total_revenue'])/1e6:.1f}M)")
print(f"• Bulan terendah: Februari (Rp {min(df['total_revenue'])/1e6:.1f}M)")
print(f"• Growth Jan→Jun: {((df['total_revenue'].iloc[-1]/df['total_revenue'].iloc[0])-1)*100:.1f}%")
