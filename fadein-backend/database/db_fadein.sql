-- =====================================================================
--  DATABASE : db_fadein
--  PROYEK   : FadeIn - Sistem Aplikasi Booking Barbershop
--  PEMBUAT  : Adi Setio Nugroho - XI RPL 2
--  TARGET   : MySQL 8.x (lokal) dan MySQL 8.4 (Aiven for MySQL)
--
--  Skema sengaja dibuat sederhana: 4 tabel, relasi Primary Key /
--  Foreign Key, tanpa trigger dan tanpa generated column. Seluruh
--  aturan bisnis (jam operasional, tanggal lampau, slot terisi)
--  divalidasi oleh REST API Express sebelum data disimpan.
--
--  Skrip ini aman dijalankan berulang kali dan bisa dieksekusi
--  langsung dari MySQL Workbench maupun Query Editor Aiven.
-- =====================================================================

SET time_zone = '+07:00';

CREATE DATABASE IF NOT EXISTS db_fadein;
USE db_fadein;

-- hapus tabel anak dulu, baru tabel induk
DROP TABLE IF EXISTS bookings;
DROP TABLE IF EXISTS services;
DROP TABLE IF EXISTS barbers;
DROP TABLE IF EXISTS users;

-- ---------------------------------------------------------------------
-- 1. users : akun admin & customer (login email + password bcrypt)
-- ---------------------------------------------------------------------
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role ENUM('admin', 'customer') NOT NULL DEFAULT 'customer',
    photo VARCHAR(255) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ---------------------------------------------------------------------
-- 2. barbers : data kapster + URL foto hasil upload (Cloudinary)
-- ---------------------------------------------------------------------
CREATE TABLE barbers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    photo VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ---------------------------------------------------------------------
-- 3. services : daftar layanan (nama, harga rupiah, durasi menit)
-- ---------------------------------------------------------------------
CREATE TABLE services (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    price INT NOT NULL,
    duration INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ---------------------------------------------------------------------
-- 4. bookings : transaksi, menghubungkan users + barbers + services
--    status : pending -> confirmed -> completed, atau cancelled
-- ---------------------------------------------------------------------
CREATE TABLE bookings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    barber_id INT NOT NULL,
    service_id INT NOT NULL,
    booking_date DATE NOT NULL,
    booking_time VARCHAR(5) NOT NULL,
    status ENUM('pending', 'confirmed', 'completed', 'cancelled')
        NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id)    REFERENCES users(id)    ON DELETE CASCADE,
    FOREIGN KEY (barber_id)  REFERENCES barbers(id)  ON DELETE RESTRICT,
    FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE RESTRICT
);

-- index untuk pengecekan slot (dipakai saat validasi booking)
-- dan untuk halaman riwayat booking milik customer
CREATE INDEX idx_booking_slot ON bookings (barber_id, booking_date, booking_time);
CREATE INDEX idx_booking_user ON bookings (user_id, booking_date);

-- ---------------------------------------------------------------------
-- 5. DATA AWAL (SEED) UNTUK PENGUJIAN
--    password asli: admin123 dan customer123 (sudah berupa bcrypt hash)
-- ---------------------------------------------------------------------
INSERT INTO users (name, email, password, role, photo) VALUES
('Admin FadeIn', 'admin@fadein.com',
 '$2b$10$J0zdO8GuSf5RSeP9WcBgd.gcWWwQfKnpl1x/KpBFgIq9aGaRxAkqu', 'admin', NULL),
('Budi Santoso', 'budi@gmail.com',
 '$2b$10$dKnmJ4xnAnGXqZbvGMZvoe2yROitg.fVfvz7xMae1kge6tz9bh/oW', 'customer', NULL),
('Rina Putri', 'rina@gmail.com',
 '$2b$10$dKnmJ4xnAnGXqZbvGMZvoe2yROitg.fVfvz7xMae1kge6tz9bh/oW', 'customer', NULL);

-- foto memakai URL gambar sementara; admin dapat menggantinya lewat upload
INSERT INTO barbers (name, description, photo) VALUES
('Andi', 'Spesialis fade dan pompadour, pengalaman 5 tahun.',
 'https://i.pravatar.cc/400?img=12'),
('Budi', 'Ahli potongan klasik dan cukur jenggot.',
 'https://i.pravatar.cc/400?img=13'),
('Rizky', 'Fokus pada undercut dan styling modern.',
 'https://i.pravatar.cc/400?img=14');

INSERT INTO services (name, price, duration) VALUES
('Haircut', 35000, 30),
('Haircut + Wash', 50000, 45),
('Haircut + Wash + Styling', 70000, 60),
('Cukur Jenggot', 25000, 20);

-- contoh transaksi (tanggal sengaja besok/lusa untuk demo)
INSERT INTO bookings (user_id, barber_id, service_id, booking_date, booking_time, status) VALUES
(2, 1, 2, DATE_ADD(CURDATE(), INTERVAL 1 DAY), '10:00', 'pending'),
(3, 2, 1, DATE_ADD(CURDATE(), INTERVAL 2 DAY), '13:00', 'confirmed');

-- =====================================================================
-- 6. QUERY VERIFIKASI (untuk screenshot lampiran 5.2.c)
-- =====================================================================
SELECT * FROM users;
SELECT * FROM barbers;
SELECT * FROM services;
SELECT * FROM bookings;

-- jadwal lengkap: gabungan 4 tabel
SELECT
    b.id            AS id_booking,
    u.name          AS nama_customer,
    br.name         AS nama_barber,
    s.name          AS layanan,
    s.price         AS harga,
    s.duration      AS durasi_menit,
    b.booking_date  AS tanggal,
    b.booking_time  AS jam,
    b.status        AS status
FROM bookings b
JOIN users u    ON b.user_id = u.id
JOIN barbers br ON b.barber_id = br.id
JOIN services s ON b.service_id = s.id
ORDER BY b.booking_date, b.booking_time;
