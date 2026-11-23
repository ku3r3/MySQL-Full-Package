-- =====================================================
-- DATABASE: PT. NUSANTARA MINING SEJAHTERA
-- Deskripsi: Sistem Informasi Operasional Pertambangan
-- =====================================================

-- Hapus database jika sudah ada (reset)
DROP DATABASE IF EXISTS mining_co;

-- Buat database baru
CREATE DATABASE mining_co;

-- Aktifkan database
USE mining_co;

-- =====================================================
-- 1. TABEL DEPARTEMEN
-- =====================================================
CREATE TABLE departemen (
    id_dept CHAR(3) PRIMARY KEY,
    nama_dept VARCHAR(50) NOT NULL,
    lokasi VARCHAR(30) DEFAULT 'Jakarta',
    kepala_dept VARCHAR(50),
    tanggal_berdiri DATE
);

-- =====================================================
-- 2. TABEL SITE TAMBAng (Lokasi Operasional)
-- =====================================================
CREATE TABLE site_tambang (
    id_site CHAR(4) PRIMARY KEY,
    nama_site VARCHAR(50) NOT NULL,
    lokasi VARCHAR(50) NOT NULL,
    provinsi VARCHAR(30),
    komoditas_utama ENUM('Batubara', 'Nikel', 'Timah', 'Emas', 'Tembaga') NOT NULL,
    luas_konsesi INT UNSIGNED COMMENT 'Dalam hektar',
    status ENUM('Aktif', 'Explorasi', 'Non-Aktif') DEFAULT 'Aktif',
    tanggal_mulai_operasi DATE
);

-- =====================================================
-- 3. TABEL KARYAWAN
-- =====================================================
CREATE TABLE karyawan (
    nik CHAR(8) PRIMARY KEY,
    nama VARCHAR(50) NOT NULL,
    gender ENUM('L', 'P') NOT NULL,
    tanggal_lahir DATE,
    alamat VARCHAR(100),
    no_hp VARCHAR(15),
    email VARCHAR(50),
    jabatan VARCHAR(30),
    id_dept CHAR(3),
    id_site CHAR(4),
    tanggal_bergabung DATE DEFAULT (CURDATE()),
    gaji_pokok DECIMAL(12,2),
    status_karyawan ENUM('Tetap', 'Kontrak', 'Magang') DEFAULT 'Kontrak',
    FOREIGN KEY (id_dept) REFERENCES departemen(id_dept) ON DELETE SET NULL,
    FOREIGN KEY (id_site) REFERENCES site_tambang(id_site) ON DELETE SET NULL
);

-- =====================================================
-- 4. TABEL MATERIAL / MINERAL
-- =====================================================
CREATE TABLE material (
    kode_mat CHAR(4) PRIMARY KEY,
    nama_material VARCHAR(50) NOT NULL,
    jenis ENUM('Batubara', 'Nikel', 'Timah', 'Emas', 'Tembaga', 'Bijih Besi') NOT NULL,
    satuan ENUM('Ton', 'Kg', 'Gram', 'Ons Troy') DEFAULT 'Ton',
    harga_per_satuan DECIMAL(12,2) COMMENT 'Dalam Rupiah',
    grade_minimum DECIMAL(5,2)
);

-- =====================================================
-- 5. TABEL ALAT BERAT (EQUIPMENT)
-- =====================================================
CREATE TABLE alat_berat (
    no_unit CHAR(6) PRIMARY KEY,
    nama_alat VARCHAR(50) NOT NULL,
    merk VARCHAR(30),
    tipe VARCHAR(30),
    tahun_pembuatan YEAR,
    kapasitas DECIMAL(8,2) COMMENT 'Dalam Ton/Jam',
    id_site CHAR(4),
    kondisi ENUM('Baik', 'Perlu Perbaikan', 'Rusak', 'Dalam Perawatan') DEFAULT 'Baik',
    tanggal_masuk DATE,
    FOREIGN KEY (id_site) REFERENCES site_tambang(id_site) ON DELETE SET NULL
);

-- =====================================================
-- 6. TABEL SHIFT KERJA
-- =====================================================
CREATE TABLE shift_kerja (
    id_shift CHAR(2) PRIMARY KEY,
    nama_shift VARCHAR(20) NOT NULL,
    jam_mulai TIME NOT NULL,
    jam_selesai TIME NOT NULL,
    keterangan VARCHAR(50)
);

-- =====================================================
-- 7. TABEL PRODUKSI HARIAN
-- =====================================================
CREATE TABLE produksi (
    id_produksi INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    tanggal DATE NOT NULL,
    id_site CHAR(4) NOT NULL,
    kode_mat CHAR(4) NOT NULL,
    no_unit CHAR(6),
    id_shift CHAR(2),
    jumlah_produksi DECIMAL(10,2) NOT NULL COMMENT 'Dalam satuan material',
    grade_aktual DECIMAL(5,2),
    target_produksi DECIMAL(10,2),
    catatan TEXT,
    FOREIGN KEY (id_site) REFERENCES site_tambang(id_site) ON DELETE CASCADE,
    FOREIGN KEY (kode_mat) REFERENCES material(kode_mat) ON DELETE CASCADE,
    FOREIGN KEY (no_unit) REFERENCES alat_berat(no_unit) ON DELETE SET NULL,
    FOREIGN KEY (id_shift) REFERENCES shift_kerja(id_shift) ON DELETE SET NULL
);
-- Drop Foreign Key
ALTER TABLE produksi DROP FOREIGN KEY produksi_ibfk_3;

-- Modify kolom di tabel alat_berat
ALTER TABLE alat_berat MODIFY no_unit VARCHAR(10) NOT NULL;

-- Modify kolom di tabel produksi (agar sesuai)
ALTER TABLE produksi MODIFY no_unit VARCHAR(10);

-- Recreate Foreign Key
ALTER TABLE produksi 
ADD CONSTRAINT produksi_ibfk_3 
FOREIGN KEY (no_unit) REFERENCES alat_berat(no_unit) ON DELETE SET NULL;

-- =====================================================
-- 8. TABEL INSIDEN K3 (KESELAMATAN KERJA)
-- =====================================================
CREATE TABLE insiden_k3 (
    id_insiden INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    tanggal DATE NOT NULL,
    waktu TIME,
    id_site CHAR(4) NOT NULL,
    nik_pelapor CHAR(8),
    kategori ENUM('Near Miss', 'First Aid', 'Lost Time Injury', 'Fatal', 'Property Damage') NOT NULL,
    tingkat_risiko ENUM('Rendah', 'Sedang', 'Tinggi', 'Kritis') DEFAULT 'Sedang',
    deskripsi TEXT NOT NULL,
    tindakan_perbaikan TEXT,
    status ENUM('Open', 'Investigasi', 'Closed') DEFAULT 'Open',
    FOREIGN KEY (id_site) REFERENCES site_tambang(id_site) ON DELETE CASCADE,
    FOREIGN KEY (nik_pelapor) REFERENCES karyawan(nik) ON DELETE SET NULL
);

-- =====================================================
-- 9. TABEL SUPPLIER
-- =====================================================
CREATE TABLE supplier (
    id_supplier CHAR(4) PRIMARY KEY,
    nama_supplier VARCHAR(50) NOT NULL,
    kategori ENUM('Bahan Bakar', 'Sparepart', 'Ban', 'Alat Tulis', 'Konsumsi', 'Jasa') NOT NULL,
    alamat VARCHAR(100),
    kota VARCHAR(30),
    no_telepon VARCHAR(15),
    email VARCHAR(50),
    rating ENUM('A', 'B', 'C', 'D') DEFAULT 'B'
);

-- =====================================================
-- 10. TABEL PENGADAAN (PURCHASE ORDER)
-- =====================================================
CREATE TABLE pengadaan (
    no_po CHAR(10) PRIMARY KEY,
    tanggal_po DATE NOT NULL,
    id_supplier CHAR(4) NOT NULL,
    id_site CHAR(4) NOT NULL,
    deskripsi VARCHAR(100) NOT NULL,
    jumlah DECIMAL(10,2),
    satuan VARCHAR(20),
    total_nilai DECIMAL(15,2),
    status_po ENUM('Draft', 'Approved', 'Dikirim', 'Diterima', 'Dibatalkan') DEFAULT 'Draft',
    tanggal_jatuh_tempo DATE,
    FOREIGN KEY (id_supplier) REFERENCES supplier(id_supplier) ON DELETE CASCADE,
    FOREIGN KEY (id_site) REFERENCES site_tambang(id_site) ON DELETE CASCADE
);
-- Drop Foreign Key terlebih dahulu
ALTER TABLE pengadaan DROP FOREIGN KEY pengadaan_ibfk_2;

-- Ubah kolom id_site agar boleh NULL
ALTER TABLE pengadaan MODIFY id_site CHAR(4);

-- Recreate Foreign Key
ALTER TABLE pengadaan 
ADD CONSTRAINT pengadaan_ibfk_2 
FOREIGN KEY (id_site) REFERENCES site_tambang(id_site) ON DELETE SET NULL;

INSERT INTO site_tambang VALUES
('ST00', 'Kantor Pusat Jakarta', 'Jakarta', 'DKI Jakarta', 'Batubara', 0, 'Aktif', '2010-01-01');


INSERT INTO departemen VALUES
('PRD', 'Produksi', 'Site', 'Budi Hartono', '2010-03-15'),
('K3L', 'Keselamatan & Lingkungan', 'Site', 'Siti Aminah', '2010-03-15'),
('EXP', 'Eksplorasi', 'Jakarta', 'Andi Wijaya', '2012-06-01'),
('LOG', 'Logistik & Supply Chain', 'Site', 'Dewi Sartika', '2010-03-15'),
('HRD', 'Human Capital', 'Jakarta', 'Ratna Sari', '2010-03-15'),
('FIN', 'Keuangan', 'Jakarta', 'Hendra Kurniawan', '2010-03-15'),
('MNT', 'Maintenance', 'Site', 'Joko Susilo', '2011-01-10');

INSERT INTO site_tambang VALUES
('ST01', 'Tambang Batubara Bukit Asam', 'Muara Enim', 'Sumatera Selatan', 'Batubara', 47426, 'Aktif', '2010-05-01'),
('ST02', 'Tambang Nikel Pomalaa', 'Kolaka', 'Sulawesi Tenggara', 'Nikel', 118435, 'Aktif', '2012-08-15'),
('ST03', 'Tambang Timah Bangka', 'Bangka Tengah', 'Bangka Belitung', 'Timah', 85000, 'Aktif', '2013-02-20'),
('ST04', 'Tambang Emas Bombana', 'Bombana', 'Sulawesi Tenggara', 'Emas', 30000, 'Aktif', '2015-11-10'),
('ST05', 'Site Eksplorasi Halmahera', 'Halmahera Selatan', 'Maluku Utara', 'Emas', 15000, 'Explorasi', '2022-06-01'),
('ST06', 'Tambang Batubara Kalimantan', 'Kutai Timur', 'Kalimantan Timur', 'Batubara', 90000, 'Aktif', '2014-09-05');

INSERT INTO karyawan VALUES
('K0010001', 'Budi Hartono', 'L', '1975-05-12', 'Jl. Merdeka No. 10, Jakarta', '081234567001', 'budi.hartono@nms.com', 'Kepala Dept Produksi', 'PRD', 'ST01', '2010-03-15', 25000000.00, 'Tetap'),
('K0010002', 'Siti Aminah', 'P', '1980-08-22', 'Jl. Sudirman No. 25, Jakarta', '081234567002', 'siti.aminah@nms.com', 'Kepala Dept K3L', 'K3L', 'ST01', '2010-03-15', 23000000.00, 'Tetap'),
('K0010003', 'Andi Wijaya', 'L', '1978-03-15', 'Jl. Thamrin No. 5, Jakarta', '081234567003', 'andi.wijaya@nms.com', 'Kepala Dept Eksplorasi', 'EXP', 'ST02', '2012-06-01', 24000000.00, 'Tetap'),
('K0010004', 'Dewi Sartika', 'P', '1982-11-30', 'Jl. Gatot Subroto No. 40, Jakarta', '081234567004', 'dewi.sartika@nms.com', 'Kepala Dept Logistik', 'LOG', 'ST01', '2010-03-15', 22000000.00, 'Tetap'),
('K0010005', 'Ratna Sari', 'P', '1985-07-18', 'Jl. Rasuna Said No. 15, Jakarta', '081234567005', 'ratna.sari@nms.com', 'Kepala Dept HRD', 'HRD', NULL, '2010-03-15', 21000000.00, 'Tetap'),
('K0010006', 'Hendra Kurniawan', 'L', '1979-02-28', 'Jl. Kuningan No. 8, Jakarta', '081234567006', 'hendra.k@nms.com', 'Kepala Dept Keuangan', 'FIN', NULL, '2010-03-15', 24000000.00, 'Tetap'),
('K0010007', 'Joko Susilo', 'L', '1981-09-10', 'Jl. HR Rasuna Said, Jakarta', '081234567007', 'joko.susilo@nms.com', 'Kepala Dept Maintenance', 'MNT', 'ST02', '2011-01-10', 22000000.00, 'Tetap'),
('K0020001', 'Agus Setiawan', 'L', '1990-04-05', 'Muara Enim, Sumsel', '081234567101', 'agus.setiawan@nms.com', 'Operator Excavator', 'PRD', 'ST01', '2015-06-01', 8500000.00, 'Tetap'),
('K0020002', 'Bambang Suryadi', 'L', '1988-12-15', 'Muara Enim, Sumsel', '081234567102', 'bambang.s@nms.com', 'Operator Dump Truck', 'PRD', 'ST01', '2016-03-10', 7500000.00, 'Tetap'),
('K0020003', 'Cahyo Nugroho', 'L', '1992-07-22', 'Kolaka, Sultra', '081234567103', 'cahyo.n@nms.com', 'Operator Loader', 'PRD', 'ST02', '2017-08-15', 8000000.00, 'Tetap'),
('K0020004', 'Dian Permata', 'P', '1993-05-18', 'Bangka, Babel', '081234567104', 'dian.p@nms.com', 'Staf Administrasi', 'LOG', 'ST03', '2018-02-20', 6500000.00, 'Kontrak'),
('K0020005', 'Eko Prasetyo', 'L', '1991-10-30', 'Kutai Timur, Kaltim', '081234567105', 'eko.p@nms.com', 'Operator Excavator', 'PRD', 'ST06', '2016-11-05', 8500000.00, 'Tetap'),
('K0020006', 'Fitri Handayani', 'P', '1994-01-25', 'Kolaka, Sultra', '081234567106', 'fitri.h@nms.com', 'Staf K3L', 'K3L', 'ST02', '2019-05-10', 7000000.00, 'Kontrak'),
('K0020007', 'Gunawan Wibowo', 'L', '1989-06-14', 'Muara Enim, Sumsel', '081234567107', 'gunawan.w@nms.com', 'Mekanik Alat Berat', 'MNT', 'ST01', '2014-09-20', 9000000.00, 'Tetap'),
('K0020008', 'Hana Pertiwi', 'P', '1995-03-08', 'Bombana, Sultra', '081234567108', 'hana.p@nms.com', 'Staf HRD', 'HRD', 'ST04', '2020-01-15', 6000000.00, 'Kontrak'),
('K0020009', 'Indra Wijaya', 'L', '1990-08-20', 'Halmahera, Malut', '081234567109', 'indra.w@nms.com', 'Geologist', 'EXP', 'ST05', '2022-07-01', 12000000.00, 'Kontrak'),
('K0020010', 'Jihan Rahma', 'P', '1992-11-11', 'Bangka, Babel', '081234567110', 'jihan.r@nms.com', 'Staf Keuangan', 'FIN', 'ST03', '2018-09-05', 7500000.00, 'Tetap'),
('K0020011', 'Kurniawan Adi', 'L', '1987-04-17', 'Kutai Timur, Kaltim', '081234567111', 'kurniawan.a@nms.com', 'Supervisor Produksi', 'PRD', 'ST06', '2013-04-01', 15000000.00, 'Tetap'),
('K0020012', 'Lina Marlina', 'P', '1991-09-29', 'Kolaka, Sultra', '081234567112', 'lina.m@nms.com', 'Staf Logistik', 'LOG', 'ST02', '2017-12-10', 7000000.00, 'Tetap'),
('K0020013', 'Maman Suherman', 'L', '1985-02-14', 'Muara Enim, Sumsel', '081234567113', 'maman.s@nms.com', 'Safety Officer', 'K3L', 'ST01', '2012-05-20', 11000000.00, 'Tetap'),
('K0020014', 'Nina Kurniasari', 'P', '1993-06-07', 'Bombana, Sultra', '081234567114', 'nina.k@nms.com', 'Operator Lab', 'PRD', 'ST04', '2019-08-15', 8000000.00, 'Kontrak'),
('K0020015', 'Oscar Pratama', 'L', '1988-10-25', 'Halmahera, Malut', '081234567115', 'oscar.p@nms.com', 'Driller', 'PRD', 'ST05', '2022-07-01', 9500000.00, 'Kontrak'),
('K0030001', 'Putra Ramadhan', 'L', '1998-01-15', 'Palembang, Sumsel', '081234567201', 'putra.r@nms.com', 'Magang Produksi', 'PRD', 'ST01', '2026-07-01', 3500000.00, 'Magang'),
('K0030002', 'Qori Aulia', 'P', '1999-05-20', 'Jakarta', '081234567202', 'qori.a@nms.com', 'Magang HRD', 'HRD', NULL, '2026-08-01', 3500000.00, 'Magang');

INSERT INTO material VALUES
('MAT1', 'Batubara Steam Coal', 'Batubara', 'Ton', 1250000.00, 60.00),
('MAT2', 'Batubara Coking Coal', 'Batubara', 'Ton', 2800000.00, 72.00),
('MAT3', 'Bijih Nikel Laterit', 'Nikel', 'Ton', 850000.00, 1.80),
('MAT4', 'Timah Ingot', 'Timah', 'Ton', 285000000.00, 99.00),
('MAT5', 'Emas Bullion', 'Emas', 'Gram', 1350000.00, 99.50),
('MAT6', 'Tembaga Konsentrat', 'Tembaga', 'Ton', 95000000.00, 25.00),
('MAT7', 'Bijih Besi', 'Bijih Besi', 'Ton', 1100000.00, 62.00);

INSERT INTO alat_berat VALUES
('EXC-001', 'Excavator', 'Komatsu', 'PC400', 2020, 120.00, 'ST01', 'Baik', '2020-03-15'),
('EXC-002', 'Excavator', 'Hitachi', 'ZX350', 2019, 95.00, 'ST01', 'Baik', '2019-08-10'),
('EXC-003', 'Excavator', 'CAT', '349DL', 2021, 110.00, 'ST02', 'Baik', '2021-05-20'),
('DMP-001', 'Dump Truck', 'Komatsu', 'HD785', 2020, 60.00, 'ST01', 'Baik', '2020-03-15'),
('DMP-002', 'Dump Truck', 'Hitachi', 'EH700', 2018, 55.00, 'ST01', 'Perlu Perbaikan', '2018-11-05'),
('DMP-003', 'Dump Truck', 'CAT', '777E', 2022, 70.00, 'ST06', 'Baik', '2022-02-10'),
('LDR-001', 'Wheel Loader', 'Komatsu', 'WA600', 2020, 180.00, 'ST02', 'Baik', '2020-07-22'),
('LDR-002', 'Wheel Loader', 'CAT', '980M', 2019, 165.00, 'ST03', 'Baik', '2019-10-15'),
('GRD-001', 'Motor Grader', 'CAT', '140H', 2021, 0.00, 'ST01', 'Baik', '2021-04-18'),
('BLD-001', 'Bulldozer', 'Komatsu', 'D155A', 2017, 0.00, 'ST06', 'Dalam Perawatan', '2017-09-30'),
('DRL-001', 'Drill Rig', 'Sandvik', 'DR460i', 2022, 0.00, 'ST04', 'Baik', '2022-06-15'),
('DRL-002', 'Drill Rig', 'Atlas Copco', 'DM45', 2023, 0.00, 'ST05', 'Baik', '2023-01-10');

INSERT INTO shift_kerja VALUES
('S1', 'Shift Pagi', '06:00:00', '14:00:00', 'Shift utama operasional'),
('S2', 'Shift Siang', '14:00:00', '22:00:00', 'Shift lanjutan'),
('S3', 'Shift Malam', '22:00:00', '06:00:00', 'Shift malam'),
('S4', 'Shift Umum', '08:00:00', '17:00:00', 'Shift staff kantor');

INSERT INTO produksi (tanggal, id_site, kode_mat, no_unit, id_shift, jumlah_produksi, grade_aktual, target_produksi, catatan) VALUES
('2026-11-01', 'ST01', 'MAT1', 'EXC-001', 'S1', 1250.50, 62.50, 1200.00, 'Produksi optimal'),
('2026-11-01', 'ST01', 'MAT1', 'EXC-002', 'S2', 1180.25, 61.80, 1200.00, 'Sedikit di bawah target'),
('2026-11-01', 'ST06', 'MAT2', 'EXC-003', 'S1', 850.00, 73.20, 800.00, 'Melebihi target'),
('2026-11-02', 'ST01', 'MAT1', 'EXC-001', 'S1', 1320.75, 63.10, 1200.00, 'Cuaca cerah'),
('2026-11-02', 'ST01', 'MAT1', 'DMP-001', 'S2', 1150.00, 62.00, 1200.00, 'Hujan ringan di sore hari'),
('2026-11-02', 'ST02', 'MAT3', 'LDR-001', 'S1', 2450.00, 1.85, 2400.00, 'Kadar nikel baik'),
('2026-11-02', 'ST06', 'MAT2', 'DMP-003', 'S3', 780.50, 72.80, 800.00, NULL),
('2026-11-03', 'ST01', 'MAT1', 'EXC-001', 'S1', 1280.00, 62.75, 1200.00, NULL),
('2026-11-03', 'ST02', 'MAT3', 'LDR-001', 'S2', 2380.00, 1.82, 2400.00, 'Kadar sedikit rendah'),
('2026-11-03', 'ST03', 'MAT4', 'LDR-002', 'S1', 45.50, 99.20, 50.00, 'Produksi timah stabil'),
('2026-11-03', 'ST04', 'MAT5', 'DRL-001', 'S1', 125.75, 99.60, 120.00, 'Emas grade tinggi'),
('2026-11-04', 'ST01', 'MAT1', 'EXC-002', 'S1', 1190.00, 62.20, 1200.00, NULL),
('2026-11-04', 'ST02', 'MAT3', 'EXC-003', 'S2', 2520.00, 1.88, 2400.00, 'Melebihi target'),
('2026-11-04', 'ST03', 'MAT4', 'LDR-002', 'S1', 48.25, 99.30, 50.00, NULL),
('2026-11-04', 'ST04', 'MAT5', 'DRL-001', 'S2', 130.50, 99.70, 120.00, 'Performa drill baik'),
('2026-11-05', 'ST01', 'MAT1', 'EXC-001', 'S1', 1310.00, 63.00, 1200.00, NULL),
('2026-11-05', 'ST01', 'MAT1', 'DMP-001', 'S3', 1120.00, 61.50, 1200.00, 'Shift malam'),
('2026-11-05', 'ST06', 'MAT2', 'DMP-003', 'S1', 870.00, 73.50, 800.00, NULL),
('2026-11-05', 'ST02', 'MAT3', 'LDR-001', 'S2', 2410.00, 1.84, 2400.00, NULL),
('2026-11-06', 'ST01', 'MAT1', 'EXC-001', 'S1', 1295.00, 62.90, 1200.00, NULL),
('2026-11-06', 'ST02', 'MAT3', 'EXC-003', 'S1', 2480.00, 1.86, 2400.00, NULL),
('2026-11-06', 'ST03', 'MAT4', 'LDR-002', 'S2', 47.80, 99.25, 50.00, NULL),
('2026-11-06', 'ST04', 'MAT5', 'DRL-001', 'S1', 128.00, 99.65, 120.00, NULL),
('2026-11-07', 'ST01', 'MAT1', 'EXC-002', 'S1', 1220.00, 62.40, 1200.00, NULL),
('2026-11-07', 'ST06', 'MAT2', 'DMP-003', 'S2', 840.00, 73.00, 800.00, NULL),
('2026-11-07', 'ST02', 'MAT3', 'LDR-001', 'S1', 2500.00, 1.87, 2400.00, 'Performa loader optimal'),
('2026-11-08', 'ST01', 'MAT1', 'EXC-001', 'S1', 1305.00, 62.95, 1200.00, NULL),
('2026-11-08', 'ST02', 'MAT3', 'EXC-003', 'S2', 2460.00, 1.85, 2400.00, NULL),
('2026-11-08', 'ST03', 'MAT4', 'LDR-002', 'S1', 46.50, 99.15, 50.00, NULL),
('2026-11-08', 'ST04', 'MAT5', 'DRL-001', 'S2', 132.00, 99.75, 120.00, NULL);

INSERT INTO insiden_k3 (tanggal, waktu, id_site, nik_pelapor, kategori, tingkat_risiko, deskripsi, tindakan_perbaikan, status) VALUES
('2026-10-15', '10:30:00', 'ST01', 'K0020001', 'Near Miss', 'Sedang', 'Dump truck hampir menabrak light vehicle di persimpangan hauling road', 'Pemasangan rambu peringatan tambahan dan briefing safety', 'Closed'),
('2026-10-22', '14:15:00', 'ST02', 'K0020003', 'First Aid', 'Rendah', 'Operator loader terpeleset saat turun dari kabin', 'Pembersihan tangga kabin dan pemasangan anti-slip', 'Closed'),
('2026-11-02', '09:45:00', 'ST01', 'K0020013', 'Property Damage', 'Sedang', 'Ban dump truck DMP-002 pecah saat operasional', 'Pemeriksaan tekanan ban seluruh unit dan penggantian ban', 'Closed'),
('2026-11-05', '16:20:00', 'ST06', 'K0020011', 'Near Miss', 'Tinggi', 'Longsoran kecil di area bench tambang', 'Pemeriksaan kestabilan lereng oleh geoteknik', 'Investigasi'),
('2026-11-10', '08:00:00', 'ST04', 'K0020014', 'First Aid', 'Rendah', 'Luka gores ringan saat penanganan sample di lab', 'Penggunaan APD lengkap dan training handling material', 'Closed'),
('2026-11-15', '13:30:00', 'ST01', 'K0020002', 'Near Miss', 'Sedang', 'Kegagalan rem di unit dump truck saat turunan', 'Inspeksi sistem rem seluruh unit dan penggantian brake pad', 'Investigasi'),
('2026-11-18', '11:00:00', 'ST02', 'K0020006', 'Lost Time Injury', 'Tinggi', 'Cedera punggung operator saat mengangkat sparepart berat', 'Training manual handling dan penyediaan alat bantu angkat', 'Open');

INSERT INTO supplier VALUES
('SUP1', 'PT. Pertamina Patra Niaga', 'Bahan Bakar', 'Jl. Merdeka No. 1, Jakarta', 'Jakarta', '0215678901', 'bcc@pertamina.com', 'A'),
('SUP2', 'PT. United Tractors', 'Sparepart', 'Jl. Yos Sudarso, Jakarta', 'Jakarta', '0215678902', 'info@unitedtractors.com', 'A'),
('SUP3', 'PT. Gajah Tunggal', 'Ban', 'Jl. Industri No. 5, Jakarta', 'Jakarta', '0215678903', 'sales@gajahtunggal.com', 'B'),
('SUP4', 'PT. Sumber Alfaria', 'Konsumsi', 'Jl. Raya Serang, Tangerang', 'Tangerang', '0215678904', 'corporate@alfamart.com', 'B'),
('SUP5', 'PT. Komatsu Indonesia', 'Sparepart', 'Jl. Gunung Sahari, Jakarta', 'Jakarta', '0215678905', 'sales@komatsu.id', 'A'),
('SUP6', 'PT. Bridgestone Indonesia', 'Ban', 'Jl. Tanjung Burung, Tangerang', 'Tangerang', '0215678906', 'info@bridgestone.id', 'A'),
('SUP7', 'PT. Graha Konstruksi', 'Jasa', 'Jl. Gatot Subroto, Jakarta', 'Jakarta', '0215678907', 'info@grahakonstruksi.com', 'B'),
('SUP8', 'PT. Alat Tulis Nusantara', 'Alat Tulis', 'Jl. Mangga Besar, Jakarta', 'Jakarta', '0215678908', 'order@atn.co.id', 'C');

INSERT INTO pengadaan VALUES
('PO-2026-001', '2026-11-01', 'SUP1', 'ST01', 'Solar HSD 50.000 Liter', 50000.00, 'Liter', 625000000.00, 'Diterima', '2026-11-15'),
('PO-2026-002', '2026-11-02', 'SUP2', 'ST01', 'Filter Oli Excavator PC400 - 20 pcs', 20.00, 'Pcs', 45000000.00, 'Dikirim', '2026-11-20'),
('PO-2026-003', '2026-11-03', 'SUP3', 'ST06', 'Ban Dump Truck 18.00-25 - 8 pcs', 8.00, 'Pcs', 320000000.00, 'Approved', '2026-11-25'),
('PO-2026-004', '2026-11-05', 'SUP4', 'ST02', 'Paket konsumsi karyawan Q4-2026', 1.00, 'Paket', 85000000.00, 'Diterima', '2026-11-10'),
('PO-2026-005', '2026-11-07', 'SUP5', 'ST01', 'Undercarriage part Bulldozer D155A', 1.00, 'Set', 275000000.00, 'Dikirim', '2026-12-01'),
('PO-2026-006', '2026-11-08', 'SUP6', 'ST02', 'Ban Loader WA600 - 6 pcs', 6.00, 'Pcs', 420000000.00, 'Approved', '2026-11-28'),
('PO-2026-007', '2026-11-10', 'SUP7', 'ST03', 'Jasa perbaikan jalan hauling 500m', 500.00, 'Meter', 180000000.00, 'Draft', '2026-12-05'),
('PO-2026-008', '2026-11-12', 'SUP1', 'ST06', 'Solar HSD 45.000 Liter', 45000.00, 'Liter', 562500000.00, 'Approved', '2026-11-30'),
('PO-2026-009', '2026-11-15', 'SUP8', NULL, 'ATK kantor pusat - November 2026', 1.00, 'Paket', 12500000.00, 'Diterima', '2026-11-18'),
('PO-2026-010', '2026-11-18', 'SUP2', 'ST04', 'Drill bit untuk Drill Rig - 15 pcs', 15.00, 'Pcs', 135000000.00, 'Draft', '2026-12-10'),
('PO-2026-011', '2026-11-20', 'SUP1', 'ST02', 'Solar HSD 40.000 Liter', 40000.00, 'Liter', 500000000.00, 'Approved', '2026-12-05'),
('PO-2026-012', '2026-11-22', 'SUP5', 'ST01', 'Hydraulic pump Excavator PC400', 2.00, 'Unit', 380000000.00, 'Dibatalkan', '2026-12-15');

-- Tampilkan semua karyawan dari site tambang batubara
SELECT k.nama, k.jabatan, s.nama_site 
FROM karyawan k
JOIN site_tambang s ON k.id_site = s.id_site
WHERE s.komoditas_utama = 'Batubara';

-- Total produksi per site bulan November 2026
SELECT s.nama_site, m.nama_material, SUM(p.jumlah_produksi) AS total_produksi
FROM produksi p
JOIN site_tambang s ON p.id_site = s.id_site
JOIN material m ON p.kode_mat = m.kode_mat
WHERE p.tanggal BETWEEN '2026-11-01' AND '2026-11-30'
GROUP BY s.nama_site, m.nama_material
ORDER BY total_produksi DESC;

-- Statistik insiden K3 per site
SELECT s.nama_site, i.kategori, COUNT(*) AS jumlah_insiden
FROM insiden_k3 i
JOIN site_tambang s ON i.id_site = s.id_site
GROUP BY s.nama_site, i.kategori;

-- Total nilai pengadaan per supplier
SELECT sp.nama_supplier, COUNT(po.no_po) AS jumlah_po, 
       SUM(po.total_nilai) AS total_nilai
FROM pengadaan po
JOIN supplier sp ON po.id_supplier = sp.id_supplier
WHERE po.status_po != 'Dibatalkan'
GROUP BY sp.nama_supplier
ORDER BY total_nilai DESC;

-- =====================================================
-- TABEL PLANT AREA (Area Pengolahan Hasil Tambang)
-- =====================================================
USE mining_co;

CREATE TABLE plant_area (
    id_plant INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nama_plant VARCHAR(50) NOT NULL,
    kode_plant CHAR(5) UNIQUE NOT NULL,
    kota VARCHAR(30) NOT NULL,
    provinsi VARCHAR(30),
    id_site CHAR(4) NOT NULL,
    kode_mat CHAR(4) NOT NULL,
    jenis_plant ENUM('Processing', 'Stockpile', 'Pelabuhan', 'Smelter', 'Crushing') NOT NULL,
    kapasitas_harian DECIMAL(10,2) COMMENT 'Dalam Ton/Hari',
    status_operasional ENUM('Aktif', 'Maintenance', 'Non-Aktif', 'Under Construction') DEFAULT 'Aktif',
    tanggal_beroperasi DATE,
    luas_area INT UNSIGNED COMMENT 'Dalam hektar',
    jumlah_pekerja INT UNSIGNED DEFAULT 0,
    FOREIGN KEY (id_site) REFERENCES site_tambang(id_site) ON DELETE CASCADE,
    FOREIGN KEY (kode_mat) REFERENCES material(kode_mat) ON DELETE CASCADE
);

-- =====================================================
-- TABEL PRODUKSI PLANT BULANAN (Nilai Hasil Tambang)
-- =====================================================
CREATE TABLE produksi_plant (
    id_produksi_plant INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_plant INT UNSIGNED NOT NULL,
    periode_bulan TINYINT UNSIGNED NOT NULL COMMENT '1-12',
    periode_tahun YEAR NOT NULL,
    jumlah_produksi DECIMAL(12,2) COMMENT 'Dalam satuan material',
    harga_per_satuan DECIMAL(12,2),
    nilai_produksi DECIMAL(18,2) COMMENT 'Total nilai dalam Rupiah',
    biaya_operasional DECIMAL(15,2),
    laba_bersih DECIMAL(15,2),
    grade_rata_rata DECIMAL(5,2),
    tanggal_pelaporan DATE DEFAULT (CURDATE()),
    FOREIGN KEY (id_plant) REFERENCES plant_area(id_plant) ON DELETE CASCADE,
    UNIQUE KEY unique_periode (id_plant, periode_bulan, periode_tahun)
);

INSERT INTO plant_area (nama_plant, kode_plant, kota, provinsi, id_site, kode_mat, jenis_plant, kapasitas_harian, status_operasional, tanggal_beroperasi, luas_area, jumlah_pekerja) VALUES
-- Site Batubara Bukit Asam (ST01)
('Coal Processing Plant Muara Enim', 'CP-ME01', 'Muara Enim', 'Sumatera Selatan', 'ST01', 'MAT1', 'Processing', 5000.00, 'Aktif', '2010-06-15', 45, 320),
('Stockpile Batubara Tarahan', 'SP-TR01', 'Muara Enim', 'Sumatera Selatan', 'ST01', 'MAT1', 'Stockpile', 8000.00, 'Aktif', '2011-03-20', 60, 150),
('Pelabuhan Batubara Kertapati', 'PL-KP01', 'Palembang', 'Sumatera Selatan', 'ST01', 'MAT1', 'Pelabuhan', 10000.00, 'Aktif', '2012-08-10', 25, 280),

-- Site Nikel Pomalaa (ST02)
('Nickel Crushing Plant Pomalaa', 'CR-PM01', 'Kolaka', 'Sulawesi Tenggara', 'ST02', 'MAT3', 'Crushing', 3000.00, 'Aktif', '2013-02-15', 35, 250),
('Nickel Stockpile Pomalaa', 'SP-PM02', 'Kolaka', 'Sulawesi Tenggara', 'ST02', 'MAT3', 'Stockpile', 4500.00, 'Aktif', '2013-05-20', 50, 120),
('Ferronickel Smelter Pomalaa', 'SM-PM03', 'Kolaka', 'Sulawesi Tenggara', 'ST02', 'MAT3', 'Smelter', 1500.00, 'Maintenance', '2015-11-10', 80, 450),

-- Site Timah Bangka (ST03)
('Tin Processing Plant Bangka', 'TP-BK01', 'Bangka Tengah', 'Bangka Belitung', 'ST03', 'MAT4', 'Processing', 150.00, 'Aktif', '2014-01-25', 20, 180),
('Tin Smelter Sungai Liat', 'SM-SL01', 'Bangka', 'Bangka Belitung', 'ST03', 'MAT4', 'Smelter', 80.00, 'Aktif', '2015-06-30', 30, 220),

-- Site Emas Bombana (ST04)
('Gold Processing Plant Bombana', 'GP-BM01', 'Bombana', 'Sulawesi Tenggara', 'ST04', 'MAT5', 'Processing', 500.00, 'Aktif', '2016-04-15', 15, 200),
('Gold Refinery Bombana', 'RF-BM02', 'Bombana', 'Sulawesi Tenggara', 'ST04', 'MAT5', 'Smelter', 200.00, 'Aktif', '2017-09-20', 10, 150),

-- Site Batubara Kalimantan (ST06)
('Coal Processing Plant Kutai', 'CP-KT01', 'Kutai Timur', 'Kalimantan Timur', 'ST06', 'MAT2', 'Processing', 4000.00, 'Aktif', '2015-02-10', 40, 290),
('Stockpile Batubara Sangatta', 'SP-SA01', 'Kutai Timur', 'Kalimantan Timur', 'ST06', 'MAT2', 'Stockpile', 7000.00, 'Aktif', '2015-08-15', 55, 140),
('Pelabuhan Batubara Samarinda', 'PL-SM01', 'Samarinda', 'Kalimantan Timur', 'ST06', 'MAT2', 'Pelabuhan', 12000.00, 'Aktif', '2016-11-05', 30, 310),

-- Site Eksplorasi Halmahera (ST05)
('Exploration Plant Halmahera', 'EX-HL01', 'Halmahera Selatan', 'Maluku Utara', 'ST05', 'MAT5', 'Processing', 100.00, 'Under Construction', '2024-06-01', 25, 80);

-- Produksi Plant Bulan Januari - Oktober 2026
INSERT INTO produksi_plant (id_plant, periode_bulan, periode_tahun, jumlah_produksi, harga_per_satuan, nilai_produksi, biaya_operasional, laba_bersih, grade_rata_rata) VALUES
-- Plant CP-ME01: Coal Processing Muara Enim (Batubara Steam Coal - Ton)
(1, 1, 2026, 125000.00, 1250000.00, 156250000000.00, 45000000000.00, 111250000000.00, 62.50),
(1, 2, 2026, 118000.00, 1250000.00, 147500000000.00, 43000000000.00, 104500000000.00, 61.80),
(1, 3, 2026, 132000.00, 1260000.00, 166320000000.00, 46000000000.00, 120320000000.00, 63.10),
(1, 4, 2026, 128000.00, 1270000.00, 162560000000.00, 45500000000.00, 117060000000.00, 62.75),
(1, 5, 2026, 135000.00, 1280000.00, 172800000000.00, 47000000000.00, 125800000000.00, 63.00),
(1, 6, 2026, 129500.00, 1275000.00, 165112500000.00, 46200000000.00, 118912500000.00, 62.90),
(1, 7, 2026, 122000.00, 1285000.00, 156770000000.00, 44800000000.00, 111970000000.00, 62.40),
(1, 8, 2026, 130500.00, 1290000.00, 168345000000.00, 46800000000.00, 121545000000.00, 62.95),
(1, 9, 2026, 133000.00, 1295000.00, 172235000000.00, 47200000000.00, 125035000000.00, 63.20),
(1, 10, 2026, 131000.00, 1300000.00, 170300000000.00, 46500000000.00, 123800000000.00, 63.05),

-- Plant CR-PM01: Nickel Crushing Pomalaa (Nikel - Ton)
(4, 1, 2026, 68000.00, 850000.00, 57800000000.00, 22000000000.00, 35800000000.00, 1.85),
(4, 2, 2026, 72000.00, 855000.00, 61560000000.00, 23000000000.00, 38560000000.00, 1.88),
(4, 3, 2026, 70500.00, 860000.00, 60630000000.00, 22500000000.00, 38130000000.00, 1.86),
(4, 4, 2026, 74000.00, 865000.00, 64010000000.00, 23500000000.00, 40510000000.00, 1.89),
(4, 5, 2026, 71500.00, 870000.00, 62205000000.00, 22800000000.00, 39405000000.00, 1.87),
(4, 6, 2026, 73500.00, 875000.00, 64312500000.00, 23200000000.00, 41112500000.00, 1.88),
(4, 7, 2026, 75000.00, 880000.00, 66000000000.00, 23800000000.00, 42200000000.00, 1.90),
(4, 8, 2026, 72500.00, 885000.00, 64162500000.00, 22900000000.00, 41262500000.00, 1.87),
(4, 9, 2026, 76000.00, 890000.00, 67640000000.00, 24000000000.00, 43640000000.00, 1.91),
(4, 10, 2026, 74500.00, 895000.00, 66677500000.00, 23600000000.00, 43077500000.00, 1.89),

-- Plant TP-BK01: Tin Processing Bangka (Timah - Ton)
(7, 1, 2026, 3200.00, 285000000.00, 912000000000.00, 180000000000.00, 732000000000.00, 99.20),
(7, 2, 2026, 3350.00, 287000000.00, 961450000000.00, 185000000000.00, 776450000000.00, 99.25),
(7, 3, 2026, 3280.00, 288000000.00, 944640000000.00, 182000000000.00, 762640000000.00, 99.22),
(7, 4, 2026, 3420.00, 290000000.00, 991800000000.00, 188000000000.00, 803800000000.00, 99.28),
(7, 5, 2026, 3380.00, 292000000.00, 986960000000.00, 187000000000.00, 799960000000.00, 99.26),
(7, 6, 2026, 3450.00, 295000000.00, 1017750000000.00, 190000000000.00, 827750000000.00, 99.30),
(7, 7, 2026, 3400.00, 297000000.00, 1009800000000.00, 189000000000.00, 820800000000.00, 99.27),
(7, 8, 2026, 3480.00, 298000000.00, 1037040000000.00, 192000000000.00, 845040000000.00, 99.32),
(7, 9, 2026, 3520.00, 300000000.00, 1056000000000.00, 195000000000.00, 861000000000.00, 99.35),
(7, 10, 2026, 3500.00, 302000000.00, 1057000000000.00, 194000000000.00, 863000000000.00, 99.33),

-- Plant GP-BM01: Gold Processing Bombana (Emas - Gram)
(9, 1, 2026, 12500.00, 1350000.00, 16875000000.00, 5500000000.00, 11375000000.00, 99.60),
(9, 2, 2026, 13200.00, 1360000.00, 17952000000.00, 5800000000.00, 12152000000.00, 99.65),
(9, 3, 2026, 12800.00, 1370000.00, 17536000000.00, 5600000000.00, 11936000000.00, 99.62),
(9, 4, 2026, 13500.00, 1380000.00, 18630000000.00, 6000000000.00, 12630000000.00, 99.68),
(9, 5, 2026, 13800.00, 1390000.00, 19182000000.00, 6100000000.00, 13082000000.00, 99.70),
(9, 6, 2026, 14200.00, 1400000.00, 19880000000.00, 6300000000.00, 13580000000.00, 99.72),
(9, 7, 2026, 13900.00, 1410000.00, 19599000000.00, 6200000000.00, 13399000000.00, 99.69),
(9, 8, 2026, 14500.00, 1420000.00, 20590000000.00, 6500000000.00, 14090000000.00, 99.74),
(9, 9, 2026, 14800.00, 1430000.00, 21164000000.00, 6700000000.00, 14464000000.00, 99.76),
(9, 10, 2026, 14600.00, 1440000.00, 21024000000.00, 6600000000.00, 14424000000.00, 99.75),

-- Plant CP-KT01: Coal Processing Kutai (Coking Coal - Ton)
(11, 1, 2026, 95000.00, 2800000.00, 266000000000.00, 85000000000.00, 181000000000.00, 73.20),
(11, 2, 2026, 98000.00, 2820000.00, 276360000000.00, 87000000000.00, 189360000000.00, 73.50),
(11, 3, 2026, 96500.00, 2840000.00, 274060000000.00, 86000000000.00, 188060000000.00, 73.35),
(11, 4, 2026, 99000.00, 2860000.00, 283140000000.00, 88000000000.00, 195140000000.00, 73.60),
(11, 5, 2026, 100500.00, 2880000.00, 289440000000.00, 89000000000.00, 200440000000.00, 73.75),
(11, 6, 2026, 102000.00, 2900000.00, 295800000000.00, 90000000000.00, 205800000000.00, 73.90),
(11, 7, 2026, 98500.00, 2920000.00, 287620000000.00, 88500000000.00, 199120000000.00, 73.45),
(11, 8, 2026, 101000.00, 2940000.00, 296940000000.00, 91000000000.00, 205940000000.00, 73.80),
(11, 9, 2026, 103000.00, 2960000.00, 304880000000.00, 92000000000.00, 212880000000.00, 74.00),
(11, 10, 2026, 101500.00, 2980000.00, 302470000000.00, 91500000000.00, 210970000000.00, 73.85);

SELECT 
    pa.nama_plant,
    pa.kota,
    m.nama_material,
    SUM(pp.jumlah_produksi) AS total_produksi,
    SUM(pp.nilai_produksi) AS total_nilai_produksi,
    SUM(pp.laba_bersih) AS total_laba
FROM plant_area pa
JOIN produksi_plant pp ON pa.id_plant = pp.id_plant
JOIN material m ON pa.kode_mat = m.kode_mat
WHERE pp.periode_tahun = 2026
GROUP BY pa.id_plant, pa.nama_plant, pa.kota, m.nama_material
ORDER BY total_nilai_produksi DESC;

SELECT 
    pa.nama_plant,
    pa.kota,
    pp.periode_bulan,
    pp.nilai_produksi,
    RANK() OVER (PARTITION BY pp.periode_bulan ORDER BY pp.nilai_produksi DESC) AS ranking
FROM plant_area pa
JOIN produksi_plant pp ON pa.id_plant = pp.id_plant
WHERE pp.periode_tahun = 2026
ORDER BY pp.periode_bulan, ranking;

SELECT 
    pa.jenis_plant,
    COUNT(DISTINCT pa.id_plant) AS jumlah_plant,
    SUM(pp.nilai_produksi) AS total_nilai,
    AVG(pp.nilai_produksi) AS rata_rata_nilai,
    SUM(pp.laba_bersih) AS total_laba
FROM plant_area pa
JOIN produksi_plant pp ON pa.id_plant = pp.id_plant
WHERE pp.periode_tahun = 2026
GROUP BY pa.jenis_plant
ORDER BY total_nilai DESC;

SELECT 
    pa.nama_plant,
    pa.kota,
    m.nama_material,
    SUM(pp.nilai_produksi) AS total_pendapatan,
    SUM(pp.biaya_operasional) AS total_biaya,
    SUM(pp.laba_bersih) AS total_laba,
    ROUND((SUM(pp.laba_bersih) / SUM(pp.nilai_produksi)) * 100, 2) AS margin_laba_persen
FROM plant_area pa
JOIN produksi_plant pp ON pa.id_plant = pp.id_plant
JOIN material m ON pa.kode_mat = m.kode_mat
WHERE pp.periode_tahun = 2026
GROUP BY pa.id_plant, pa.nama_plant, pa.kota, m.nama_material
HAVING total_pendapatan > 0
ORDER BY margin_laba_persen DESC;

SELECT 
    pa.provinsi,
    COUNT(DISTINCT pa.id_plant) AS jumlah_plant,
    SUM(pp.nilai_produksi) AS total_nilai_produksi,
    SUM(pp.laba_bersih) AS total_laba_bersih
FROM plant_area pa
JOIN produksi_plant pp ON pa.id_plant = pp.id_plant
WHERE pp.periode_tahun = 2026
GROUP BY pa.provinsi
ORDER BY total_nilai_produksi DESC;

SELECT 
    m.nama_material,
    pp.periode_bulan,
    SUM(pp.jumlah_produksi) AS total_produksi,
    SUM(pp.nilai_produksi) AS total_nilai
FROM plant_area pa
JOIN produksi_plant pp ON pa.id_plant = pp.id_plant
JOIN material m ON pa.kode_mat = m.kode_mat
WHERE pp.periode_tahun = 2026
GROUP BY m.nama_material, pp.periode_bulan
ORDER BY m.nama_material, pp.periode_bulan;

SELECT 
    pa.nama_plant,
    pa.kota,
    pa.kapasitas_harian * 26 AS target_bulanan,  -- Asumsi 26 hari kerja
    AVG(pp.jumlah_produksi) AS rata_produksi_aktual,
    ROUND((AVG(pp.jumlah_produksi) / (pa.kapasitas_harian * 26)) * 100, 2) AS persentase_capaian
FROM plant_area pa
JOIN produksi_plant pp ON pa.id_plant = pp.id_plant
WHERE pp.periode_tahun = 2026 AND pa.status_operasional = 'Aktif'
GROUP BY pa.id_plant, pa.nama_plant, pa.kota, pa.kapasitas_harian
ORDER BY persentase_capaian DESC;

CREATE VIEW v_dashboard_plant AS
SELECT 
    pa.nama_plant,
    pa.kota,
    pa.provinsi,
    st.nama_site,
    m.nama_material,
    pa.jenis_plant,
    pa.status_operasional,
    pp.periode_bulan,
    pp.periode_tahun,
    pp.jumlah_produksi,
    pp.nilai_produksi,
    pp.biaya_operasional,
    pp.laba_bersih,
    pp.grade_rata_rata
FROM plant_area pa
JOIN site_tambang st ON pa.id_site = st.id_site
JOIN material m ON pa.kode_mat = m.kode_mat
JOIN produksi_plant pp ON pa.id_plant = pp.id_plant;

-- Test view
SELECT * FROM v_dashboard_plant 
WHERE periode_tahun = 2026 AND periode_bulan = 10;

