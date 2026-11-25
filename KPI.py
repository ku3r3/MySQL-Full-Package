import matplotlib.pyplot as plt
import pandas as pd
import numpy as np

# Data KPI (ganti dengan hasil query SQL)
kpi_data = {
    'Metric': ['Total Revenue', 'Total Quantity', 'Jumlah Wilayah', 
               'Produk Unik', 'Total Transaksi', 'Avg Price/Unit'],
    'Value': ['Rp 258.456.789', '612 unit', '5 Wilayah', 
              '5 Produk', '180 Transaksi', 'Rp 422.345'],
    'Icon': ['💰', '📦', '🗺️', '🛒', '🧾', '💵']
}

# Buat figure dengan 6 KPI cards
fig, axes = plt.subplots(2, 3, figsize=(15, 6))
fig.suptitle('DASHBOARD PENJUALAN 2024 - KPI SUMMARY', 
             fontsize=18, fontweight='bold', y=0.98)

colors = ['#2E86AB', '#A23B72', '#F18F01', '#C73E1D', '#3B1F2B', '#44BBA4']

for idx, ax in enumerate(axes.flatten()):
    if idx < len(kpi_data['Metric']):
        ax.text(0.5, 0.65, kpi_data['Icon'][idx], 
                fontsize=40, ha='center', va='center')
        ax.text(0.5, 0.35, kpi_data['Value'][idx], 
                fontsize=16, fontweight='bold', ha='center', va='center',
                color=colors[idx])
        ax.text(0.5, 0.15, kpi_data['Metric'][idx], 
                fontsize=11, ha='center', va='center', color='gray')
        ax.set_xlim(0, 1)
        ax.set_ylim(0, 1)
        ax.axis('off')
        ax.set_facecolor(colors[idx] + '15')
        for spine in ax.spines.values():
            spine.set_edgecolor(colors[idx])
            spine.set_linewidth(2)

plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.savefig('kpi_cards.png', dpi=150, bbox_inches='tight')
plt.show()
