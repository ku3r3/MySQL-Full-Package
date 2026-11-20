Hari 1: Senin, 23 November 2026 – Fondasi & Perancangan Database
Tujuan: Peserta memahami konsep relasional, mampu merancang tabel yang ternormalisasi, dan melakukan instalasi dasar.

    09:00 - 10:30: Konsep Dasar & Perancangan (Sumber: PPT)
        Pengenalan RDBMS, Entity Relationship Diagram (ERD), dan Normalisasi (1NF, 2NF, 3NF) dengan studi kasus nyata.
    10:45 - 12:00: Instalasi & Konfigurasi Awal (Sumber: PDF Bab 1)
        Instalasi MySQL/MariaDB, mysql_secure_installation (Hardening), dan manajemen user dasar.
    13:00 - 15:00: Data Definition Language (DDL) (Sumber: PDF Bab 2 & PPT Tipe Data)
        CREATE DATABASE, CREATE TABLE, Tipe Data (String, Numerik, Date, ENUM, SET), dan Constraints (NOT NULL, DEFAULT, AUTO_INCREMENT).
    15:15 - 16:30: Lab 1 
        Peserta merancang dan membuat database "Sistem Manajemen Pelatihan" (Tabel: peserta, instruktur, topik, sesi) berdasarkan hasil normalisasi.

Hari 2: Selasa, 24 November 2026 – Manipulasi Data & Query Dasar
Tujuan: Peserta mahir memasukkan, mengubah, menghapus, dan mengambil data dengan berbagai kondisi.

    09:00 - 10:30: Data Manipulation Language (DML) Dasar (Sumber: PDF Bab 3)
        INSERT, UPDATE, DELETE, dan SELECT dasar.
    10:45 - 12:00: Filtering & Pencarian Data (Sumber: PDF Bab 3)
        Klausa WHERE, Operator Logika (AND, OR, NOT), BETWEEN, LIKE, IN, IS NULL.
    13:00 - 14:30: Fungsi Agregat & Pengelompokan (Sumber: PDF Bab 3 & PPT)
        COUNT, SUM, AVG, MIN, MAX, GROUP BY, dan HAVING.
    14:45 - 16:30: Lab 2
        Mengisi data dummy ke tabel yang dibuat Hari 1, lalu membuat laporan: "Rata-rata nilai peserta per sesi", "Instruktur dengan honor di atas rata-rata", dll.

Hari 3: Rabu, 25 November 2026 – Relasi Tabel & Optimasi
Tujuan: Peserta mampu menggabungkan data dari banyak tabel dan memahami cara kerja index untuk performa.

    09:00 - 10:30: JOIN & Alias (Sumber: PDF Bab 3 & PPT JOIN)
        INNER JOIN, LEFT JOIN, RIGHT JOIN, dan penggunaan Alias untuk menyederhanakan query 3 tabel atau lebih.
    10:45 - 12:00: Integritas Referensial (Sumber: PDF Bab 2)
        Penerapan FOREIGN KEY, CASCADE, dan dampaknya terhadap DELETE/UPDATE.
    13:00 - 14:30: Optimasi Query & Index (Sumber: PPT Optimize Query)
        Konsep INDEX, kapan harus menggunakan index, kapan tidak, dan pengenalan EXPLAIN untuk membaca query plan.
    14:45 - 16:30: Lab 3
        Membuat Foreign Key antar tabel, menjalankan query JOIN kompleks, dan membandingkan kecepatan query sebelum dan sesudah diberi INDEX.

Hari 4: Kamis, 26 November 2026 – Advanced MySQL (Stored Objects & Transactions)
Tujuan: Peserta dapat mengotomatisasi tugas database dan memahami konsep transaksi yang aman.

    09:00 - 10:30: VIEW & Stored Procedure/Function (Sumber: PDF Bab 4 & PPT)
        Membuat VIEW sebagai virtual table, perbedaan Procedure (CALL) dan Function (RETURN), parameter IN/OUT.
    10:45 - 12:00: TRIGGERS & EVENT Scheduler (Sumber: PDF Bab 4 & PPT)
        Membuat Trigger (BEFORE/AFTER INSERT, UPDATE, DELETE) untuk audit log, dan menjadwalkan EVENT.
    13:00 - 14:30: TRANSACTIONS (Sumber: PPT Transactions)
        Konsep ACID, START TRANSACTION, COMMIT, ROLLBACK, dan Isolation Levels (Read Committed, Repeatable Read, dll).
    14:45 - 16:30: Lab 4
        Membuat Trigger yang otomatis mencatat perubahan harga di tabel catatan setiap kali tabel produk di-UPDATE. Simulasi transaksi perbankan (transfer saldo dengan ROLLBACK jika gagal).

Hari 5: Jumat, 27 November 2026 – Administrasi, Keamanan, Backup & Restore
Tujuan: Peserta mampu mengamankan database, melakukan backup strategis, dan memulihkan data saat terjadi kegagalan.

    09:00 - 10:30: MySQL Security & User Privileges (Sumber: PDF Bab 8 & PPT)
        CREATE USER, GRANT (privilege level: global, database, tabel, kolom), REVOKE, dan DROP USER.
    10:45 - 12:00: Backup & Restore Strategy (Sumber: PDF Bab 7 & PPT)
        mysqldump (full dan per tabel), mysqlimport, LOAD DATA INFILE (dari CSV), dan SELECT ... INTO OUTFILE.
    13:00 - 14:30: Database Maintenance (Sumber: PDF Bab 9)
        CHECK TABLE, REPAIR TABLE, OPTIMIZE TABLE (defragmentasi), dan utilitas mysqladmin / mysqlshow.
    14:45 - 16:00: Lab 5 & Mini Project
        Simulasi bencana: Hapus tabel/database, lalu restore menggunakan file .sql dari mysqldump. Import data dari file CSV Excel.
    16:00 - 16:30: Review, Q&A, dan Post-Test Singkat.
