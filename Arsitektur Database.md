┌─────────────────────────────────────────────────────────────────┐
│                    DATABASE: retail_sales_db                     │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   [DATA KOTOR]          [DATA CLEANING]        [DATA SIAP ANALISIS]
│                                                                  │
│   stg_sales ───────▶ cleaning_log ──────▶ fact_sales             │
│       │                                        │                 │
│       │                                        ▼                 │
│       └──────────────────────────────▶ dim_product               │
│                                        dim_region                │
│                                        dim_date                  │
│                                                                  │
│   [REPORTING LAYER]                                              │
│   v_dashboard_penjualan                                          │
│   v_top5_produk                                                  │
│   v_ringkasan_wilayah                                            │
│   v_tren_bulanan                                                 │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
