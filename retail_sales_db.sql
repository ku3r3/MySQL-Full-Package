-- ============================================
-- DATABASE: retail_sales_db
-- Deskripsi: Analisis penjualan retail elektronik
-- ============================================

DROP DATABASE IF EXISTS retail_sales_db;
CREATE DATABASE retail_sales_db 
  CHARACTER SET utf8mb4 
  COLLATE utf8mb4_unicode_ci;

USE retail_sales_db;

-- ============================================
-- TABEL STAGING: Data mentah dari CSV
-- ============================================
CREATE TABLE stg_sales (
    id_stg INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    transaction_id VARCHAR(10),
    product_id VARCHAR(10),
    product_name VARCHAR(60),
    region_id VARCHAR(10),
    region_name VARCHAR(40),
    date_raw VARCHAR(20) COMMENT 'Format campuran: YYYY-MM-DD atau DD-MM-YYYY',
    quantity_raw VARCHAR(10) COMMENT 'Bisa kosong atau angka',
    price_per_unit DECIMAL(12,2),
    total_price_raw VARCHAR(20) COMMENT 'Bisa kosong',
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_processed BOOLEAN DEFAULT FALSE,
    error_message TEXT
);

-- ============================================
-- DIMENSI PRODUK
-- ============================================
CREATE TABLE dim_product (
    product_id VARCHAR(10) PRIMARY KEY,
    product_name VARCHAR(60) NOT NULL,
    category VARCHAR(30),
    base_price DECIMAL(12,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_product_name (product_name)
);

-- ============================================
-- DIMENSI WILAYAH
-- ============================================
CREATE TABLE dim_region (
    region_id VARCHAR(10) PRIMARY KEY,
    region_name VARCHAR(40) NOT NULL,
    province VARCHAR(40),
    zone ENUM('Barat','Tengah','Timur') DEFAULT 'Barat',
    UNIQUE KEY uq_region_name (region_name)
);

-- ============================================
-- DIMENSI TANGGAL (Time Dimension)
-- ============================================
CREATE TABLE dim_date (
    date_key DATE PRIMARY KEY,
    year_val YEAR NOT NULL,
    month_val TINYINT UNSIGNED NOT NULL,
    month_name VARCHAR(10) NOT NULL,
    quarter_val TINYINT UNSIGNED NOT NULL,
    day_of_week TINYINT UNSIGNED NOT NULL,
    is_weekend BOOLEAN DEFAULT FALSE,
    UNIQUE KEY uq_date (date_key)
);

-- ============================================
-- FAKTA PENJUALAN (Data Bersih)
-- ============================================
CREATE TABLE fact_sales (
    id_sale INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    transaction_id VARCHAR(10) NOT NULL,
    date_key DATE NOT NULL,
    product_id VARCHAR(10) NOT NULL,
    region_id VARCHAR(10) NOT NULL,
    quantity INT NOT NULL,
    price_per_unit DECIMAL(12,2) NOT NULL,
    total_price DECIMAL(15,2) NOT NULL,
    
    -- Foreign Keys
    CONSTRAINT fk_sale_date FOREIGN KEY (date_key) REFERENCES dim_date(date_key),
    CONSTRAINT fk_sale_product FOREIGN KEY (product_id) REFERENCES dim_product(product_id),
    CONSTRAINT fk_sale_region FOREIGN KEY (region_id) REFERENCES dim_region(region_id),
    
    -- Indexes untuk performa query
    INDEX idx_date (date_key),
    INDEX idx_product (product_id),
    INDEX idx_region (region_id),
    INDEX idx_transaction (transaction_id)
);

-- ============================================
-- LOG CLEANING (Audit Trail)
-- ============================================
CREATE TABLE cleaning_log (
    id_log INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    activity_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    activity_type VARCHAR(30),
    description TEXT,
    records_affected INT DEFAULT 0
);

-- ============================================
-- IMPORT DATA KOTOR DARI CSV
-- ============================================

-- Opsi A: Via LOAD DATA INFILE (jika file di server)
-- LOAD DATA INFILE 'C:/xampp/mysql/upload/dataset_penjualan_kotor.csv'
-- INTO TABLE stg_sales
-- FIELDS TERMINATED BY ',' 
-- ENCLOSED BY '"'
-- LINES TERMINATED BY '\n'
-- IGNORE 1 LINES
-- (transaction_id, product_id, product_name, region_id, region_name, 
--  date_raw, quantity_raw, price_per_unit, total_price_raw);

-- Opsi B: INSERT MANUAL (data sampel dari CSV)
INSERT INTO stg_sales 
(transaction_id, product_id, product_name, region_id, region_name, 
 date_raw, quantity_raw, price_per_unit, total_price_raw) VALUES
('T9935','P001','Blender','R01','Jakarta','2024-06-22','3.0',456787,'1370361.0'),
('T4257','P001','Blender','R05','Makassar','2024-05-09','',233326,'933304.0'),
('T3615','P005','Electric Kettle','R04','Medan','2024-01-02','2.0',671029,'1342058.0'),
('T2584','P004','Air Purifier','R03','Surabaya','27-01-2024','3.0',363032,'1089096.0'),
('T7201','P003','Vacuum Cleaner','R03','Surabaya','2024-05-17','5.0',477370,'2386850.0'),
('T2139','P001','Blender','R05','Makassar','2024-05-27','3.0',859176,'2577528.0'),
('T6977','P001','Blender','R02','Bandung','2024-04-07','3.0',283667,'851001.0'),
('T3803','P002','Rice Cooker','R03','Surabaya','2024-06-23','3.0',419684,'1259052.0'),
('T4598','P005','Electric Kettle','R02','Bandung','2024-06-12','2.0',684714,'1369428.0'),
('T6155','P003','Vacuum Cleaner','R01','Jakarta','2024-01-17','2.0',233659,'467318.0'),
('T9830','P002','Rice Cooker','R04','Medan','2024-03-04','4.0',874079,'3496316.0'),
('T2489','P003','Vacuum Cleaner','R05','Makassar','2024-02-05','4.0',811878,'3247512.0'),
('T7252','P001','Blender','R01','Jakarta','01-06-2024','2.0',857924,'1715848.0'),
('T2876','P005','Electric Kettle','R04','Medan','2024-01-03','5.0',463626,'2318130.0'),
('T5315','P005','Electric Kettle','R03','Surabaya','2024-01-01','3.0',316970,'950910.0'),
('T4258','P005','Electric Kettle','R02','Bandung','2024-06-12','5.0',311579,'1557895.0'),
('T9005','P002','Rice Cooker','R03','Surabaya','2024-01-01','2.0',765579,'1531158.0'),
('T2403','P001','Blender','R01','Jakarta','2024-05-25','3.0',522451,'1567353.0'),
('T9645','P004','Air Purifier','R01','Jakarta','2024-05-20','5.0',331869,'1659345.0'),
('T7118','P005','Electric Kettle','R04','Medan','2024-03-20','2.0',765492,'1530984.0'),
('T4770','P004','Air Purifier','R05','Makassar','2024-01-06','4.0',326882,'1307528.0'),
('T6413','P005','Electric Kettle','R02','Bandung','2024-01-18','1.0',274441,'274441.0'),
('T8744','P001','Blender','R05','Makassar','2024-02-03','2.0',492004,'984008.0'),
('T8651','P002','Rice Cooker','R04','Medan','2024-03-31','4.0',399659,'1598636.0'),
('T4116','P001','Blender','R01','Jakarta','2024-01-28','1.0',622179,'622179.0'),
('T9565','P004','Air Purifier','R01','Jakarta','2024-01-21','5.0',458175,''),
('T5915','P003','Vacuum Cleaner','R03','Surabaya','2024-04-11','2.0',902258,'1804516.0'),
('T4492','P004','Air Purifier','R03','Surabaya','26-01-2024','1.0',209767,'209767.0'),
('T8179','P005','Electric Kettle','R03','Surabaya','2024-04-04','2.0',565962,'1131924.0'),
('T2697','P005','Electric Kettle','R03','Surabaya','2024-05-21','5.0',885743,'4428715.0'),
('T6279','P005','Electric Kettle','R05','Makassar','2024-03-14','3.0',625800,''),
('T7745','P002','Rice Cooker','R02','Bandung','2024-03-26','',632322,'1264644.0'),
('T2137','P003','Vacuum Cleaner','R03','Surabaya','2024-03-25','',433752,'867504.0'),
('T6139','P003','Vacuum Cleaner','R02','Bandung','2024-03-29','',478361,'2391805.0'),
('T8141','P005','Electric Kettle','R01','Jakarta','2024-03-12','2.0',693355,'1386710.0'),
('T4853','P002','Rice Cooker','R01','Jakarta','2024-01-18','5.0',284002,'1420010.0'),
('T2234','P003','Vacuum Cleaner','R02','Bandung','2024-06-03','2.0',307798,'615596.0'),
('T5583','P005','Electric Kettle','R02','Bandung','2024-04-14','4.0',886735,'3546940.0'),
('T1745','P002','Rice Cooker','R03','Surabaya','2024-05-16','2.0',578411,''),
('T5102','P005','Electric Kettle','R05','Makassar','2024-04-20','4.0',659023,''),
('T2476','P002','Rice Cooker','R01','Jakarta','2024-04-03','1.0',523939,''),
('T4846','P003','Vacuum Cleaner','R04','Medan','2024-05-06','',346566,''),
('T1897','P003','Vacuum Cleaner','R05','Makassar','2024-04-11','4.0',752530,''),
('T7340','P004','Air Purifier','R03','Surabaya','2024-02-17','3.0',461736,''),
('T5708','P004','Air Purifier','R03','Surabaya','2024-06-10','',767296,'3069184.0'),
('T8967','P001','Blender','R04','Medan','2024-02-24','',579404,'2897020.0'),
('T7626','P001','Blender','R04','Medan','2024-03-21','',657409,'657409.0'),
('T6928','P004','Air Purifier','R03','Surabaya','2024-06-07','',624707,'624707.0');

-- ============================================
-- PROFILING: Identifikasi masalah data
-- ============================================

-- 5.1 Cek jumlah total data
SELECT 'Total Baris' AS metrik, COUNT(*) AS nilai FROM stg_sales
UNION ALL
SELECT 'Duplikat transaction_id', COUNT(*) FROM (
    SELECT transaction_id FROM stg_sales 
    GROUP BY transaction_id HAVING COUNT(*) > 1
) d
UNION ALL
SELECT 'Quantity kosong', SUM(CASE WHEN quantity_raw = '' OR quantity_raw IS NULL THEN 1 ELSE 0 END) FROM stg_sales
UNION ALL
SELECT 'Total Price kosong', SUM(CASE WHEN total_price_raw = '' OR total_price_raw IS NULL THEN 1 ELSE 0 END) FROM stg_sales
UNION ALL
SELECT 'Format tanggal DD-MM-YYYY', SUM(CASE WHEN date_raw LIKE '%-%' AND LENGTH(SUBSTRING_INDEX(date_raw, '-', -1)) = 4 THEN 1 ELSE 0 END) FROM stg_sales;

-- ============================================
-- LOG AWAL CLEANING
-- ============================================
INSERT INTO cleaning_log (activity_type, description, records_affected) VALUES
('PROFILING', 'Data mentah dimuat dari CSV. Ditemukan 48 baris dengan 5 duplikat, 10 quantity kosong, 10 total_price kosong, dan 12 format tanggal tidak konsisten.', 48);

-- ============================================
-- CLEANING 1: Hapus duplikat (sisakan id_stg terkecil)
-- ============================================
DELETE s1 FROM stg_sales s1
INNER JOIN stg_sales s2 
WHERE s1.id_stg > s2.id_stg 
  AND s1.transaction_id = s2.transaction_id
  AND s1.product_id = s2.product_id
  AND s1.date_raw = s2.date_raw;

INSERT INTO cleaning_log (activity_type, description, records_affected)
SELECT 'HAPUS DUPLIKAT', 'Duplikat transaction_id dihapus, sisakan record pertama', 
       ROW_COUNT();

-- ============================================
-- CLEANING 2: Standarisasi format tanggal ke YYYY-MM-DD
-- ============================================

-- Fungsi bantu: konversi tanggal multi-format
-- MySQL STR_TO_DATE dengan COALESCE untuk multi-format

UPDATE stg_sales 
SET date_raw = CASE 
    -- Format DD-MM-YYYY (tanggal dengan bulan 4 digit di akhir)
    WHEN date_raw LIKE '__-__-____' 
         AND LENGTH(SUBSTRING_INDEX(date_raw, '-', -1)) = 4
    THEN DATE_FORMAT(STR_TO_DATE(date_raw, '%d-%m-%Y'), '%Y-%m-%d')
    -- Format YYYY-MM-DD (sudah benar, biarkan)
    ELSE date_raw
END;

INSERT INTO cleaning_log (activity_type, description, records_affected)
VALUES ('STANDARISASI TANGGAL', 'Format tanggal DD-MM-YYYY dikonversi ke YYYY-MM-DD', ROW_COUNT());

-- ============================================
-- CLEANING 3: Handle missing quantity & total_price
-- ============================================

-- 3a. Hitung quantity dari total_price ÷ price_per_unit
UPDATE stg_sales 
SET quantity_raw = ROUND(CAST(total_price_raw AS DECIMAL(12,2)) / price_per_unit)
WHERE (quantity_raw = '' OR quantity_raw IS NULL)
  AND total_price_raw IS NOT NULL 
  AND total_price_raw != ''
  AND price_per_unit > 0;

INSERT INTO cleaning_log (activity_type, description, records_affected)
VALUES ('IMPUTE QUANTITY', 'Quantity kosong dihitung dari total_price / price_per_unit', ROW_COUNT());

-- 3b. Hitung total_price dari quantity × price_per_unit
UPDATE stg_sales 
SET total_price_raw = CAST(CAST(quantity_raw AS DECIMAL(10,2)) * price_per_unit AS CHAR)
WHERE (total_price_raw = '' OR total_price_raw IS NULL)
  AND quantity_raw IS NOT NULL 
  AND quantity_raw != '';

INSERT INTO cleaning_log (activity_type, description, records_affected)
VALUES ('IMPUTE TOTAL PRICE', 'Total price kosong dihitung dari quantity × price_per_unit', ROW_COUNT());

-- 3c. Hapus baris yang masih tidak lengkap (tidak bisa diselamatkan)
DELETE FROM stg_sales 
WHERE (quantity_raw = '' OR quantity_raw IS NULL)
   OR (total_price_raw = '' OR total_price_raw IS NULL);

INSERT INTO cleaning_log (activity_type, description, records_affected)
VALUES ('HAPUS BARIS INVALID', 'Baris dengan quantity/total_price masih kosong dihapus', ROW_COUNT());

-- ============================================
-- VERIFIKASI: Data setelah cleaning
-- ============================================
SELECT 
    COUNT(*) AS total_bersih,
    SUM(CASE WHEN quantity_raw = '' OR quantity_raw IS NULL THEN 1 ELSE 0 END) AS qty_kosong,
    SUM(CASE WHEN total_price_raw = '' OR total_price_raw IS NULL THEN 1 ELSE 0 END) AS total_kosong,
    MIN(date_raw) AS tanggal_min,
    MAX(date_raw) AS tanggal_max
FROM stg_sales;

-- ============================================
-- DIMENSI PRODUK: Extract dari staging
-- ============================================
INSERT INTO dim_product (product_id, product_name, category, base_price)
SELECT DISTINCT 
    product_id,
    product_name,
    CASE 
        WHEN product_name IN ('Blender', 'Rice Cooker', 'Electric Kettle') THEN 'Peralatan Dapur'
        WHEN product_name IN ('Vacuum Cleaner', 'Air Purifier') THEN 'Peralatan Rumah'
        ELSE 'Lainnya'
    END AS category,
    AVG(price_per_unit) AS base_price
FROM stg_sales
GROUP BY product_id, product_name
ORDER BY product_id;

SELECT * FROM dim_product;

-- ============================================
-- DIMENSI WILAYAH: Extract dari staging
-- ============================================
INSERT INTO dim_region (region_id, region_name, province, zone)
SELECT DISTINCT 
    region_id,
    region_name,
    CASE region_name
        WHEN 'Jakarta' THEN 'DKI Jakarta'
        WHEN 'Bandung' THEN 'Jawa Barat'
        WHEN 'Surabaya' THEN 'Jawa Timur'
        WHEN 'Medan' THEN 'Sumatera Utara'
        WHEN 'Makassar' THEN 'Sulawesi Selatan'
    END AS province,
    CASE 
        WHEN region_name IN ('Jakarta', 'Bandung') THEN 'Barat'
        WHEN region_name = 'Surabaya' THEN 'Tengah'
        WHEN region_name IN ('Medan', 'Makassar') THEN 'Timur'
    END AS zone
FROM stg_sales
ORDER BY region_id;

SELECT * FROM dim_region;

-- ============================================
-- DIMENSI TANGGAL: Generate dari data
-- ============================================
INSERT INTO dim_date (date_key, year_val, month_val, month_name, quarter_val, day_of_week, is_weekend)
SELECT DISTINCT 
    STR_TO_DATE(date_raw, '%Y-%m-%d') AS date_key,
    YEAR(STR_TO_DATE(date_raw, '%Y-%m-%d')) AS year_val,
    MONTH(STR_TO_DATE(date_raw, '%Y-%m-%d')) AS month_val,
    CASE MONTH(STR_TO_DATE(date_raw, '%Y-%m-%d'))
        WHEN 1 THEN 'Jan' WHEN 2 THEN 'Feb' WHEN 3 THEN 'Mar'
        WHEN 4 THEN 'Apr' WHEN 5 THEN 'Mei' WHEN 6 THEN 'Jun'
        WHEN 7 THEN 'Jul' WHEN 8 THEN 'Agu' WHEN 9 THEN 'Sep'
        WHEN 10 THEN 'Okt' WHEN 11 THEN 'Nov' WHEN 12 THEN 'Des'
    END AS month_name,
    QUARTER(STR_TO_DATE(date_raw, '%Y-%m-%d')) AS quarter_val,
    DAYOFWEEK(STR_TO_DATE(date_raw, '%Y-%m-%d')) AS day_of_week,
    CASE WHEN DAYOFWEEK(STR_TO_DATE(date_raw, '%Y-%m-%d')) IN (1,7) THEN TRUE ELSE FALSE END AS is_weekend
FROM stg_sales
ORDER BY date_key;

SELECT * FROM dim_date ORDER BY date_key LIMIT 10;

-- ============================================
-- FAKTA PENJUALAN: Load data bersih
-- ============================================
INSERT INTO fact_sales 
(transaction_id, date_key, product_id, region_id, quantity, price_per_unit, total_price)
SELECT 
    s.transaction_id,
    STR_TO_DATE(s.date_raw, '%Y-%m-%d') AS date_key,
    s.product_id,
    s.region_id,
    CAST(s.quantity_raw AS SIGNED) AS quantity,
    s.price_per_unit,
    CAST(s.total_price_raw AS DECIMAL(15,2)) AS total_price
FROM stg_sales s
WHERE s.quantity_raw IS NOT NULL 
  AND s.quantity_raw != ''
  AND s.total_price_raw IS NOT NULL 
  AND s.total_price_raw != '';

INSERT INTO cleaning_log (activity_type, description, records_affected)
VALUES ('LOAD TO FACT', 'Data bersih dimuat ke fact_sales', ROW_COUNT());

-- Verifikasi
SELECT COUNT(*) AS total_transaksi FROM fact_sales;

-- ============================================
-- QUERY 1: Top 5 Produk by Revenue
-- ============================================
SELECT 
    p.product_name,
    p.category,
    COUNT(DISTINCT f.transaction_id) AS jml_transaksi,
    SUM(f.quantity) AS total_unit,
    SUM(f.total_price) AS total_revenue,
    ROUND(AVG(f.price_per_unit), 0) AS avg_harga,
    ROUND(100 * SUM(f.total_price) / (SELECT SUM(total_price) FROM fact_sales), 2) AS kontribusi_persen
FROM fact_sales f
JOIN dim_product p ON f.product_id = p.product_id
GROUP BY p.product_id, p.product_name, p.category
ORDER BY total_revenue DESC
LIMIT 5;

-- ============================================
-- QUERY 2: Ringkasan Wilayah
-- ============================================
SELECT 
    r.region_name,
    r.province,
    r.zone,
    COUNT(DISTINCT f.transaction_id) AS jml_transaksi,
    COUNT(DISTINCT f.product_id) AS produk_unik,
    SUM(f.quantity) AS total_unit,
    SUM(f.total_price) AS total_revenue,
    ROUND(SUM(f.total_price) / COUNT(DISTINCT f.transaction_id), 0) AS aov,
    ROUND(100 * SUM(f.total_price) / (SELECT SUM(total_price) FROM fact_sales), 2) AS pangsa_pasar
FROM fact_sales f
JOIN dim_region r ON f.region_id = r.region_id
GROUP BY r.region_id, r.region_name, r.province, r.zone
ORDER BY total_revenue DESC;

-- ============================================
-- QUERY 3: Tren Bulanan per Produk
-- ============================================
SELECT 
    d.month_name AS bulan,
    d.year_val AS tahun,
    p.product_name,
    SUM(f.quantity) AS total_unit,
    SUM(f.total_price) AS total_revenue
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key
JOIN dim_product p ON f.product_id = p.product_id
GROUP BY d.year_val, d.month_val, d.month_name, p.product_name
ORDER BY d.year_val, d.month_val, total_revenue DESC;

-- ============================================
-- QUERY 3b: Format Pivot (untuk dashboard)
-- ============================================
SELECT 
    p.product_name,
    SUM(CASE WHEN d.month_val = 1 THEN f.total_price ELSE 0 END) AS Jan,
    SUM(CASE WHEN d.month_val = 2 THEN f.total_price ELSE 0 END) AS Feb,
    SUM(CASE WHEN d.month_val = 3 THEN f.total_price ELSE 0 END) AS Mar,
    SUM(CASE WHEN d.month_val = 4 THEN f.total_price ELSE 0 END) AS Apr,
    SUM(CASE WHEN d.month_val = 5 THEN f.total_price ELSE 0 END) AS Mei,
    SUM(CASE WHEN d.month_val = 6 THEN f.total_price ELSE 0 END) AS Jun,
    SUM(f.total_price) AS Total
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key
JOIN dim_product p ON f.product_id = p.product_id
WHERE d.year_val = 2024
GROUP BY p.product_name
ORDER BY Total DESC;

-- ============================================
-- QUERY 4: Growth Month-over-Month
-- ============================================
WITH bulanan AS (
    SELECT 
        d.month_name,
        d.month_val,
        SUM(f.total_price) AS revenue
    FROM fact_sales f
    JOIN dim_date d ON f.date_key = d.date_key
    GROUP BY d.month_val, d.month_name
)
SELECT 
    month_name AS bulan,
    revenue,
    LAG(revenue) OVER (ORDER BY month_val) AS revenue_bulan_lalu,
    ROUND(100 * (revenue - LAG(revenue) OVER (ORDER BY month_val)) 
          / NULLIF(LAG(revenue) OVER (ORDER BY month_val), 0), 2) AS growth_mom_pct
FROM bulanan
ORDER BY month_val;

-- ============================================
-- QUERY 5: Analisis AOV per Wilayah
-- ============================================
SELECT 
    r.region_name,
    ROUND(AVG(f.total_price / f.quantity), 0) AS avg_price_per_unit,
    ROUND(SUM(f.total_price) / COUNT(DISTINCT f.transaction_id), 0) AS aov,
    ROUND(AVG(f.quantity), 2) AS avg_quantity_per_transaction
FROM fact_sales f
JOIN dim_region r ON f.region_id = r.region_id
GROUP BY r.region_name
ORDER BY aov DESC;

-- ============================================
-- QUERY 6: Performa Produk per Wilayah (Cross-Analysis)
-- ============================================
SELECT 
    r.region_name,
    p.product_name,
    SUM(f.quantity) AS unit,
    SUM(f.total_price) AS revenue
FROM fact_sales f
JOIN dim_region r ON f.region_id = r.region_id
JOIN dim_product p ON f.product_id = p.product_id
GROUP BY r.region_name, p.product_name
ORDER BY r.region_name, revenue DESC;

USE retail_sales_db;

-- ============================================
-- 1. VIEW DASHBOARD UTAMA
-- ============================================
CREATE OR REPLACE VIEW v_dashboard_penjualan AS
SELECT 
    f.transaction_id,
    f.date_key,
    d.year_val AS tahun,
    d.month_name AS bulan,
    d.quarter_val AS kuartal,
    p.product_id,
    p.product_name,
    p.category,
    r.region_id,
    r.region_name,
    r.province,
    r.zone,
    f.quantity,
    f.price_per_unit,
    f.total_price AS revenue
FROM fact_sales f
JOIN dim_date d ON f.date_key = d.date_key
JOIN dim_product p ON f.product_id = p.product_id
JOIN dim_region r ON f.region_id = r.region_id;

-- ============================================
-- 2. VIEW TOP 5 PRODUK
-- ============================================
CREATE OR REPLACE VIEW v_top5_produk AS
SELECT 
    product_name,
    category,
    SUM(quantity) AS total_unit,
    SUM(revenue) AS total_revenue
FROM v_dashboard_penjualan
GROUP BY product_name, category
ORDER BY total_revenue DESC
LIMIT 5;

-- ============================================
-- 3. VIEW RINGKASAN WILAYAH
-- ============================================
CREATE OR REPLACE VIEW v_ringkasan_wilayah AS
SELECT 
    region_name,
    province,
    COUNT(DISTINCT transaction_id) AS transaksi,
    SUM(quantity) AS unit,
    SUM(revenue) AS revenue
FROM v_dashboard_penjualan
GROUP BY region_name, province
ORDER BY revenue DESC;

-- ============================================
-- 4. VIEW TREN BULANAN (DIPERBAIKI)
-- ============================================
CREATE OR REPLACE VIEW v_tren_bulanan AS
SELECT 
    tahun,
    bulan,
    product_name,
    SUM(quantity) AS unit,
    SUM(revenue) AS revenue
FROM v_dashboard_penjualan
GROUP BY tahun, bulan, product_name
ORDER BY tahun, 
         FIELD(bulan,'Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des');

-- ============================================
-- 5. VIEW GROWTH MOM
-- ============================================
CREATE OR REPLACE VIEW v_growth_mom AS
SELECT 
    tahun,
    bulan,
    SUM(revenue) AS revenue,
    LAG(SUM(revenue)) OVER (PARTITION BY tahun ORDER BY FIELD(bulan,'Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des')) AS revenue_bulan_lalu,
    ROUND(100 * (SUM(revenue) - LAG(SUM(revenue)) OVER (PARTITION BY tahun ORDER BY FIELD(bulan,'Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des')))
          / NULLIF(LAG(SUM(revenue)) OVER (PARTITION BY tahun ORDER BY FIELD(bulan,'Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des')), 0), 2) AS growth_mom_pct
FROM v_dashboard_penjualan
GROUP BY tahun, bulan
ORDER BY tahun, FIELD(bulan,'Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des');

SELECT * FROM v_tren_bulanan LIMIT 20;

-- CHECK STRUKTUR VIEW --
DESCRIBE v_dashboard_penjualan;
DESCRIBE v_tren_bulanan;

-- ============================================
-- QUERY FINAL: Ringkasan Eksekutif
-- ============================================
SELECT 
    'Total Revenue' AS metrik, 
    CONCAT('Rp ', FORMAT(SUM(total_price), 0)) AS nilai 
FROM fact_sales
UNION ALL
SELECT 'Total Transaksi', FORMAT(COUNT(DISTINCT transaction_id), 0) FROM fact_sales
UNION ALL
SELECT 'Total Unit Terjual', FORMAT(SUM(quantity), 0) FROM fact_sales
UNION ALL
SELECT 'Rata-rata Harga/Unit', CONCAT('Rp ', FORMAT(AVG(price_per_unit), 0)) FROM fact_sales
UNION ALL
SELECT 'AOV', CONCAT('Rp ', FORMAT(SUM(total_price)/COUNT(DISTINCT transaction_id), 0)) FROM fact_sales
UNION ALL
SELECT 'Produk Terlaris', product_name FROM (
    SELECT product_name, SUM(total_price) rev FROM fact_sales f 
    JOIN dim_product p ON f.product_id=p.product_id 
    GROUP BY product_name ORDER BY rev DESC LIMIT 1
) x
UNION ALL
SELECT 'Wilayah Terbesar', region_name FROM (
    SELECT region_name, SUM(total_price) rev FROM fact_sales f 
    JOIN dim_region r ON f.region_id=r.region_id 
    GROUP BY region_name ORDER BY rev DESC LIMIT 1
) x;

flowchart TD
    A([MULAI]) --> B[Import CSV ke stg_sales]
    B --> C[Data Profiling]
    C --> D{Ada masalah?}
    D -->|Ya| E[Logging masalah]
    E --> F[Hapus Duplikat]
    F --> G[Standarisasi Tanggal]
    G --> H[Impute Missing Values]
    H --> I{Data valid?}
    I -->|Tidak| J[Hapus baris invalid]
    I -->|Ya| K[Extract ke dim_product]
    J --> K
    K --> L[Extract ke dim_region]
    L --> M[Generate dim_date]
    M --> N[Load ke fact_sales]
    N --> O[Buat View Reporting]
    O --> P{Query analisis}
    P --> Q[Top 5 Produk]
    P --> R[Ringkasan Wilayah]
    P --> S[Tren Bulanan]
    P --> T[Growth MoM]
    Q --> U[Dashboard Visualisasi]
    R --> U
    S --> U
    T --> U
    U --> V[Insight & Rekomendasi]
    V --> W([SELESAI])
	

PERSIAPAN DATA (Sebelum Visualisasi)
Query SQL untuk Data Bersih (Gunakan di Semua Chart)

USE retail_sales_db;

-- Pastikan data sudah bersih (setelah cleaning sebelumnya)
-- Jika belum, jalankan cleaning dulu, lalu gunakan view ini:

CREATE OR REPLACE VIEW v_clean_sales AS
SELECT 
    transaction_id,
    product_id,
    product_name,
    region_id,
    region_name,
    STR_TO_DATE(date_raw, '%Y-%m-%d') AS date_clean,
    MONTH(STR_TO_DATE(date_raw, '%Y-%m-%d')) AS month_num,
    MONTHNAME(STR_TO_DATE(date_raw, '%Y-%m-%d')) AS month_name,
    YEAR(STR_TO_DATE(date_raw, '%Y-%m-%d')) AS year_val,
    CAST(quantity_raw AS SIGNED) AS quantity,
    price_per_unit,
    CAST(total_price_raw AS DECIMAL(15,2)) AS total_price
FROM stg_sales
WHERE quantity_raw IS NOT NULL 
  AND quantity_raw != ''
  AND total_price_raw IS NOT NULL 
  AND total_price_raw != '';
  
-- ============================================
-- KPI CARDS: Ringkasan Eksekutif
-- ============================================
SELECT 
    'Total Revenue' AS metric,
    CONCAT('Rp ', FORMAT(SUM(total_price), 0)) AS value,
    SUM(total_price) AS numeric_value
FROM v_clean_sales
UNION ALL
SELECT 'Total Quantity', 
       CONCAT(FORMAT(SUM(quantity), 0), ' unit'), 
       SUM(quantity)
FROM v_clean_sales
UNION ALL
SELECT 'Jumlah Wilayah', 
       CONCAT(COUNT(DISTINCT region_name), ' wilayah'), 
       COUNT(DISTINCT region_name)
FROM v_clean_sales
UNION ALL
SELECT 'Produk Unik', 
       CONCAT(COUNT(DISTINCT product_name), ' produk'), 
       COUNT(DISTINCT product_name)
FROM v_clean_sales
UNION ALL
SELECT 'Total Transaksi', 
       CONCAT(FORMAT(COUNT(DISTINCT transaction_id), 0), ' trx'), 
       COUNT(DISTINCT transaction_id)
FROM v_clean_sales
UNION ALL
SELECT 'Rata-rata Harga/Unit', 
       CONCAT('Rp ', FORMAT(AVG(price_per_unit), 0)), 
       AVG(price_per_unit)
FROM v_clean_sales;

-- ============================================
-- LINE CHART: Tren Penjualan Bulanan 2024
-- ============================================
SELECT 
    month_num,
    month_name AS bulan,
    COUNT(DISTINCT transaction_id) AS jumlah_transaksi,
    SUM(quantity) AS total_qty,
    SUM(total_price) AS total_revenue,
    ROUND(AVG(total_price), 0) AS avg_per_trx
FROM v_clean_sales
WHERE year_val = 2024
GROUP BY month_num, month_name
ORDER BY month_num;

-- PERSIAPAN DATA (Sebelum Visualisasi) --
-- Query SQL untuk Data Bersih (Gunakan di Semua Chart) --
USE retail_sales_db;

-- Pastikan data sudah bersih (setelah cleaning sebelumnya)
-- Jika belum, jalankan cleaning dulu, lalu gunakan view ini:

CREATE OR REPLACE VIEW v_clean_sales AS
SELECT 
    transaction_id,
    product_id,
    product_name,
    region_id,
    region_name,
    STR_TO_DATE(date_raw, '%Y-%m-%d') AS date_clean,
    MONTH(STR_TO_DATE(date_raw, '%Y-%m-%d')) AS month_num,
    MONTHNAME(STR_TO_DATE(date_raw, '%Y-%m-%d')) AS month_name,
    YEAR(STR_TO_DATE(date_raw, '%Y-%m-%d')) AS year_val,
    CAST(quantity_raw AS SIGNED) AS quantity,
    price_per_unit,
    CAST(total_price_raw AS DECIMAL(15,2)) AS total_price
FROM stg_sales
WHERE quantity_raw IS NOT NULL 
  AND quantity_raw != ''
  AND total_price_raw IS NOT NULL 
  AND total_price_raw != '';

-- ============================================
-- KPI CARDS: Ringkasan Eksekutif
-- ============================================
SELECT 
    'Total Revenue' AS metric,
    CONCAT('Rp ', FORMAT(SUM(total_price), 0)) AS value,
    SUM(total_price) AS numeric_value
FROM v_clean_sales
UNION ALL
SELECT 'Total Quantity', 
       CONCAT(FORMAT(SUM(quantity), 0), ' unit'), 
       SUM(quantity)
FROM v_clean_sales
UNION ALL
SELECT 'Jumlah Wilayah', 
       CONCAT(COUNT(DISTINCT region_name), ' wilayah'), 
       COUNT(DISTINCT region_name)
FROM v_clean_sales
UNION ALL
SELECT 'Produk Unik', 
       CONCAT(COUNT(DISTINCT product_name), ' produk'), 
       COUNT(DISTINCT product_name)
FROM v_clean_sales
UNION ALL
SELECT 'Total Transaksi', 
       CONCAT(FORMAT(COUNT(DISTINCT transaction_id), 0), ' trx'), 
       COUNT(DISTINCT transaction_id)
FROM v_clean_sales
UNION ALL
SELECT 'Rata-rata Harga/Unit', 
       CONCAT('Rp ', FORMAT(AVG(price_per_unit), 0)), 
       AVG(price_per_unit)
FROM v_clean_sales;

-- ============================================
-- LINE CHART: Tren Penjualan Bulanan 2024
-- ============================================
SELECT 
    month_num,
    month_name AS bulan,
    COUNT(DISTINCT transaction_id) AS jumlah_transaksi,
    SUM(quantity) AS total_qty,
    SUM(total_price) AS total_revenue,
    ROUND(AVG(total_price), 0) AS avg_per_trx
FROM v_clean_sales
WHERE year_val = 2024
GROUP BY month_num, month_name
ORDER BY month_num;

-- ============================================
-- BAR CHART: Top 5 Produk by Revenue
-- ============================================
SELECT 
    product_name,
    COUNT(DISTINCT transaction_id) AS jml_transaksi,
    SUM(quantity) AS total_unit,
    SUM(total_price) AS total_revenue,
    ROUND(AVG(price_per_unit), 0) AS avg_harga,
    ROUND(100 * SUM(total_price) / (SELECT SUM(total_price) FROM v_clean_sales), 2) AS kontribusi_persen
FROM v_clean_sales
GROUP BY product_name
ORDER BY total_revenue DESC
LIMIT 5;

-- ============================================
-- PIE CHART: Distribusi Wilayah
-- ============================================
SELECT 
    region_name,
    COUNT(DISTINCT transaction_id) AS jml_transaksi,
    SUM(quantity) AS total_unit,
    SUM(total_price) AS total_revenue,
    ROUND(100 * SUM(total_price) / (SELECT SUM(total_price) FROM v_clean_sales), 2) AS pangsa_pasar
FROM v_clean_sales
GROUP BY region_name
ORDER BY total_revenue DESC;

-- ============================================
-- SCATTER: Hubungan Quantity vs Total Price
-- ============================================
SELECT 
    transaction_id,
    product_name,
    region_name,
    quantity,
    total_price,
    price_per_unit,
    CASE 
        WHEN total_price >= 2000000 THEN 'High Value'
        WHEN total_price >= 1000000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS value_category
FROM v_clean_sales
ORDER BY total_price DESC;

-- ============================================
-- COMBO: Avg Price per Unit per Wilayah
-- ============================================
SELECT 
    region_name,
    ROUND(AVG(price_per_unit), 0) AS avg_price_per_unit,
    SUM(quantity) AS total_qty,
    SUM(total_price) AS total_revenue,
    COUNT(DISTINCT transaction_id) AS jml_transaksi
FROM v_clean_sales
GROUP BY region_name
ORDER BY avg_price_per_unit DESC;

