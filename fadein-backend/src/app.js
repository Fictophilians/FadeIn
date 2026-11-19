import express from 'express'
import cors from 'cors'
import 'dotenv/config'

import pool from './config/database.js'
import authRoutes from './routes/authRoutes.js'
import userRoutes from './routes/userRoutes.js'
import barberRoutes from './routes/barberRoutes.js'
import serviceRoutes from './routes/serviceRoutes.js'
import bookingRoutes from './routes/bookingRoutes.js'
import { notFound, errorHandler } from './middlewares/errorMiddleware.js'

const app = express()

app.use(cors())
app.use(express.json())
app.use(express.urlencoded({ extended: true }))

// Express 5 membiarkan req.body undefined bila request tidak membawa body.
// Disamakan menjadi objek kosong agar controller menjawab 400, bukan 500.
app.use((req, res, next) => {
  if (req.body === undefined) {
    req.body = {}
  }
  next()
})

// log sederhana biar mudah dilacak saat demo
app.use((req, res, next) => {
  console.log(`[REQUEST] ${req.method} ${req.originalUrl}`)
  next()
})

app.get('/', (req, res) => {
  res.json({
    message: 'FadeIn REST API aktif',
    data: { health: '/api/health' }
  })
})

// Dipakai untuk mengecek backend hidup (lokal maupun setelah deploy).
// Status database ikut ditampilkan supaya masalah koneksi Aiven
// langsung kelihatan tanpa perlu membuka log Vercel.
app.get('/api/health', async (req, res) => {
  let database = 'up'

  try {
    await pool.query('SELECT 1')
  } catch {
    database = 'down'
  }

  res.json({
    message: 'OK',
    data: { status: 'healthy', database, serverTime: new Date().toISOString() }
  })
})

app.use('/api/auth', authRoutes)
app.use('/api/users', userRoutes)
app.use('/api/barbers', barberRoutes)
app.use('/api/services', serviceRoutes)
app.use('/api/bookings', bookingRoutes)

app.use(notFound)
app.use(errorHandler)

export default app
