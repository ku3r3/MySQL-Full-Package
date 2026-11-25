import matplotlib.pyplot as plt
import pandas as pd

# Data dari SQL
data = {
    'region_name': ['Jakarta', 'Surabaya', 'Bandung', 'Medan', 'Makassar'],
    'total_revenue': [78234567, 58456789, 48765432, 42678901, 28345678],
    'pangsa_pasar': [30.3, 22.6, 18.9, 16.5, 11.0]
}
df = pd.DataFrame(data)

# Buat figure dengan 2 subplot (Pie + Donut)
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(15, 7))

# Warna
colors = ['#2E86AB', '#A23B72', '#F18F01', '#C73E1D', '#44BBA4']
explode = (0.05, 0.03, 0, 0, 0)  # Highlight Jakarta & Surabaya

# PIE CHART (kiri)
wedges1, texts1, autotexts1 = ax1.pie(
    df['total_revenue'], 
    labels=df['region_name'],
    autopct='%1.1f%%',
    colors=colors,
    explode=explode,
    shadow=True,
    startangle=90,
    textprops={'fontsize': 11, 'fontweight': 'bold'}
)
for autotext in autotexts1:
    autotext.set_color('white')
    autotext.set_fontsize(10)
ax1.set_title('📊 Porsi Penjualan per Wilayah', 
              fontsize=14, fontweight='bold', pad=15)

# DONUT CHART (kanan) - dengan hole di tengah
wedges2, texts2, autotexts2 = ax2.pie(
    df['total_revenue'],
    autopct=lambda p: f'{p:.1f}%\n(Rp {p*258/100:.1f}M)',
    colors=colors,
    startangle=90,
    pctdistance=0.78,
    textprops={'fontsize': 9}
)
# Buat hole di tengah (donut)
centre_circle = plt.Circle((0, 0), 0.55, fc='white')
ax2.add_artist(centre_circle)
ax2.text(0, 0, 'TOTAL\nRp 258M', 
         ha='center', va='center', fontsize=14, fontweight='bold')
ax2.set_title('🎯 Distribusi Revenue per Wilayah', 
              fontsize=14, fontweight='bold', pad=15)

# Legend di bawah
legend = ax2.legend(wedges2, 
                    [f'{r} - Rp {v/1e6:.1f}M' for r, v in zip(df['region_name'], df['total_revenue'])],
                    title="Wilayah",
                    loc="lower center",
                    bbox_to_anchor=(0.5, -0.15),
                    ncol=5,
                    fontsize=9)

plt.tight_layout()
plt.savefig('pie_wilayah.png', dpi=150, bbox_inches='tight')
plt.show()

# Insight
print("\n💡 INSIGHT:")
print(f"• Jakarta & Surabaya mendominasi: {(df['pangsa_pasar'].iloc[0] + df['pangsa_pasar'].iloc[1]):.1f}%")
print(f"• Makassar terkecil: {df['pangsa_pasar'].iloc[-1]}% → peluang ekspansi")
