import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec

# Buat dashboard 3x2 grid
fig = plt.figure(figsize=(18, 12))
fig.suptitle('📊 DASHBOARD PENJUALAN 2024\nPT Retail Elektronik Indonesia', 
             fontsize=20, fontweight='bold', y=0.98)

gs = GridSpec(3, 2, figure=fig, hspace=0.35, wspace=0.3)

# Row 1: KPI Cards (span 2 kolom)
ax_kpi = fig.add_subplot(gs[0, :])
# ... (kode KPI cards dari Chart 1)
ax_kpi.set_title('📈 KEY PERFORMANCE INDICATORS', fontsize=14, fontweight='bold')
ax_kpi.axis('off')

# Row 2: Line Chart + Bar Chart
ax_line = fig.add_subplot(gs[1, 0])
# ... (kode Line Chart dari Chart 2)

ax_bar = fig.add_subplot(gs[1, 1])
# ... (kode Bar Chart dari Chart 3)

# Row 3: Pie Chart + Scatter
ax_pie = fig.add_subplot(gs[2, 0])
# ... (kode Pie Chart dari Chart 4)

ax_scatter = fig.add_subplot(gs[2, 1])
# ... (kode Scatter dari Chart 5)

plt.savefig('dashboard_final.png', dpi=150, bbox_inches='tight')
plt.show()
