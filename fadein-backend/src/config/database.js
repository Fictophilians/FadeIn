import mysql from 'mysql2/promise'
import 'dotenv/config'

// Satu pool dipakai seluruh aplikasi.
// DB_SSL dibuat fleksibel: false untuk MySQL lokal, true untuk Aiven.
// time_zone '+07:00' menjaga CURDATE()/NOW() tetap mengikuti WIB walaupun
// server Aiven berjalan pada UTC.
const pool = mysql.createPool({
  host: process.env.DB_HOST || '127.0.0.1',
  port: Number(process.env.DB_PORT) || 3306,
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'db_fadein',
  waitForConnections: true,
  // Serverless (Vercel) membuat banyak instance paralel; tiap instance punya
  // pool sendiri. 3 cukup untuk itu dan tidak menghabiskan kuota koneksi Aiven.
  connectionLimit: 3,
  queueLimit: 0,
  timezone: '+07:00',
  // DATE dikembalikan sebagai string 'YYYY-MM-DD' supaya JSON-nya
  // langsung bisa dipakai Flutter tanpa pergeseran timezone.
  dateStrings: true,
  ...(process.env.DB_SSL === 'true'
    ? { ssl: { rejectUnauthorized: false } }
    : {})
})

pool.on('connection', (connection) => {
  connection.query("SET time_zone = '+07:00'")
})

export default pool
