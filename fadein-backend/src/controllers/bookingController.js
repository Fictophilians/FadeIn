import pool from '../config/database.js'
import { success, failure } from '../utils/response.js'

const DATE_REGEX = /^\d{4}-\d{2}-\d{2}$/
const TIME_REGEX = /^([01][0-9]|2[0-3]):[0-5][0-9]$/
const OPENING_HOUR = 9
const CLOSING_HOUR = 20
// konstanta internal (bukan input pengguna), aman disisipkan langsung ke query
const ACTIVE_STATUSES = "('pending', 'confirmed')"
const ALLOWED_STATUSES = ['pending', 'confirmed', 'completed', 'cancelled']

// tanggal & jam sekarang menurut WIB, apa pun timezone servernya
function todayWIB() {
  return new Date(Date.now() + 7 * 60 * 60 * 1000).toISOString().slice(0, 10)
}

function nowTimeWIB() {
  return new Date(Date.now() + 7 * 60 * 60 * 1000).toISOString().slice(11, 16)
}

function buildSlots() {
  const slots = []
  for (let hour = OPENING_HOUR; hour <= CLOSING_HOUR; hour++) {
    slots.push(`${String(hour).padStart(2, '0')}:00`)
  }
  return slots
}

const BOOKING_SELECT = `
  SELECT
    b.id,
    b.user_id,
    b.barber_id,
    b.service_id,
    b.booking_date,
    b.booking_time,
    b.status,
    b.created_at,
    u.name  AS customer_name,
    br.name AS barber_name,
    s.name  AS service_name,
    s.price,
    s.duration
  FROM bookings b
  JOIN users u    ON b.user_id = u.id
  JOIN barbers br ON b.barber_id = br.id
  JOIN services s ON b.service_id = s.id
`

// Aturan yang dulu dijaga trigger database, sekarang divalidasi di sini.
async function isSlotTaken(barberId, date, time, exceptId = null) {
  const [rows] = await pool.execute(
    `SELECT id FROM bookings
     WHERE barber_id = ? AND booking_date = ? AND booking_time = ?
       AND status IN ${ACTIVE_STATUSES}
       ${exceptId ? 'AND id <> ?' : ''}
     LIMIT 1`,
    exceptId ? [barberId, date, time, exceptId] : [barberId, date, time]
  )

  return rows.length > 0
}

export async function createBooking(req, res) {
  const { barber_id, service_id, booking_date, booking_time } = req.body

  // admin boleh membuatkan booking untuk customer lain
  const userId =
    req.user.role === 'admin' && req.body.user_id
      ? Number(req.body.user_id)
      : req.user.id

  if (!barber_id || !service_id || !booking_date || !booking_time) {
    return failure(
      res,
      'Barber, layanan, tanggal, dan jam booking wajib diisi!'
    )
  }

  if (!DATE_REGEX.test(booking_date)) {
    return failure(res, 'Format tanggal harus YYYY-MM-DD!')
  }

  if (booking_date < todayWIB()) {
    return failure(res, 'Tanggal booking tidak boleh tanggal yang sudah lewat!')
  }

  if (!TIME_REGEX.test(booking_time)) {
    return failure(res, 'Format jam harus HH:MM!')
  }

  if (booking_time < '09:00' || booking_time > '20:00') {
    return failure(res, 'Jam booking harus di antara 09:00 sampai 20:00!')
  }

  // hari ini boleh, tapi jam yang sudah lewat tidak boleh
  if (booking_date === todayWIB() && booking_time <= nowTimeWIB()) {
    return failure(res, 'Jam booking hari ini sudah lewat, silakan pilih jam lain!')
  }

  const [barbers] = await pool.execute(
    'SELECT id FROM barbers WHERE id = ? LIMIT 1',
    [barber_id]
  )

  if (barbers.length === 0) {
    return failure(res, 'Barber tidak ditemukan!', 404)
  }

  const [services] = await pool.execute(
    'SELECT id FROM services WHERE id = ? LIMIT 1',
    [service_id]
  )

  if (services.length === 0) {
    return failure(res, 'Layanan tidak ditemukan!', 404)
  }

  // Pengecekan slot + insert dijalankan dalam satu transaksi.
  // SELECT ... FOR UPDATE mengunci rentang slot tersebut sehingga dua
  // request yang datang bersamaan tidak bisa sama-sama lolos.
  const connection = await pool.getConnection()

  try {
    await connection.beginTransaction()

    const [conflict] = await connection.execute(
      `SELECT id FROM bookings
       WHERE barber_id = ? AND booking_date = ? AND booking_time = ?
         AND status IN ${ACTIVE_STATUSES}
       LIMIT 1
       FOR UPDATE`,
      [barber_id, booking_date, booking_time]
    )

    if (conflict.length > 0) {
      await connection.rollback()
      return failure(
        res,
        'Jadwal tersebut sudah dipesan, silakan pilih jam lain!',
        409
      )
    }

    const [result] = await connection.execute(
      `INSERT INTO bookings
         (user_id, barber_id, service_id, booking_date, booking_time, status)
       VALUES (?, ?, ?, ?, ?, 'pending')`,
      [userId, barber_id, service_id, booking_date, booking_time]
    )

    await connection.commit()

    const [rows] = await pool.execute(`${BOOKING_SELECT} WHERE b.id = ?`, [
      result.insertId
    ])

    return success(res, 'Booking berhasil dibuat!', rows[0], 201)
  } catch (error) {
    await connection.rollback()
    throw error
  } finally {
    connection.release()
  }
}

export async function getBookings(req, res) {
  const conditions = []
  const params = []

  // customer hanya melihat booking miliknya sendiri
  if (req.user.role !== 'admin') {
    conditions.push('b.user_id = ?')
    params.push(req.user.id)
  }

  if (req.query.status) {
    conditions.push('b.status = ?')
    params.push(req.query.status)
  }

  if (req.query.date) {
    conditions.push('b.booking_date = ?')
    params.push(req.query.date)
  }

  if (req.query.barber_id) {
    conditions.push('b.barber_id = ?')
    params.push(req.query.barber_id)
  }

  const where = conditions.length > 0 ? `WHERE ${conditions.join(' AND ')}` : ''

  const [rows] = await pool.execute(
    `${BOOKING_SELECT} ${where}
     ORDER BY b.booking_date DESC, b.booking_time DESC`,
    params
  )

  return success(res, 'Daftar booking berhasil diambil!', rows)
}

export async function getBookingById(req, res) {
  const [rows] = await pool.execute(`${BOOKING_SELECT} WHERE b.id = ?`, [
    req.params.id
  ])

  if (rows.length === 0) {
    return failure(res, 'Booking tidak ditemukan!', 404)
  }

  const booking = rows[0]

  if (req.user.role !== 'admin' && booking.user_id !== req.user.id) {
    return failure(res, 'Anda tidak berhak melihat booking ini!', 403)
  }

  return success(res, 'Detail booking berhasil diambil!', booking)
}

export async function getSlots(req, res) {
  const { barber_id, date } = req.query

  if (!barber_id || !date) {
    return failure(res, 'Parameter barber_id dan date wajib diisi!')
  }

  if (!DATE_REGEX.test(date)) {
    return failure(res, 'Format tanggal harus YYYY-MM-DD!')
  }

  if (date < todayWIB()) {
    return failure(res, 'Tanggal sudah lewat, silakan pilih tanggal lain!')
  }

  const [barbers] = await pool.execute(
    'SELECT id FROM barbers WHERE id = ? LIMIT 1',
    [barber_id]
  )

  if (barbers.length === 0) {
    return failure(res, 'Barber tidak ditemukan!', 404)
  }

  const [booked] = await pool.execute(
    `SELECT booking_time FROM bookings
     WHERE barber_id = ? AND booking_date = ? AND status IN ${ACTIVE_STATUSES}`,
    [barber_id, date]
  )

  const taken = new Set(booked.map((row) => row.booking_time))

  const slots = buildSlots().map((time) => ({
    time,
    available: !taken.has(time)
  }))

  return success(res, 'Slot berhasil diambil!', {
    barber_id: Number(barber_id),
    date,
    slots
  })
}

export async function updateStatus(req, res) {
  const { status } = req.body

  if (!ALLOWED_STATUSES.includes(status)) {
    return failure(
      res,
      `Status harus salah satu dari: ${ALLOWED_STATUSES.join(', ')}!`
    )
  }

  const [rows] = await pool.execute('SELECT * FROM bookings WHERE id = ?', [
    req.params.id
  ])

  if (rows.length === 0) {
    return failure(res, 'Booking tidak ditemukan!', 404)
  }

  const booking = rows[0]

  if (['completed', 'cancelled'].includes(booking.status)) {
    return failure(
      res,
      'Booking yang sudah selesai atau dibatalkan tidak dapat diubah statusnya!'
    )
  }

  if (booking.status === status) {
    return success(res, 'Status booking tidak berubah!', booking)
  }

  // mengaktifkan kembali booking tidak boleh menabrak slot yang sudah dipakai
  if (
    ['pending', 'confirmed'].includes(status) &&
    (await isSlotTaken(
      booking.barber_id,
      booking.booking_date,
      booking.booking_time,
      booking.id
    ))
  ) {
    return failure(res, 'Slot tersebut sudah dipakai booking lain!', 409)
  }

  await pool.execute('UPDATE bookings SET status = ? WHERE id = ?', [
    status,
    booking.id
  ])

  const [updated] = await pool.execute(`${BOOKING_SELECT} WHERE b.id = ?`, [
    booking.id
  ])

  return success(res, 'Status booking berhasil diperbarui!', updated[0])
}

export async function cancelBooking(req, res) {
  const [rows] = await pool.execute('SELECT * FROM bookings WHERE id = ?', [
    req.params.id
  ])

  if (rows.length === 0) {
    return failure(res, 'Booking tidak ditemukan!', 404)
  }

  const booking = rows[0]

  if (req.user.role !== 'admin' && booking.user_id !== req.user.id) {
    return failure(res, 'Anda tidak berhak membatalkan booking ini!', 403)
  }

  if (!['pending', 'confirmed'].includes(booking.status)) {
    return failure(
      res,
      'Hanya booking berstatus pending atau confirmed yang dapat dibatalkan!'
    )
  }

  await pool.execute('UPDATE bookings SET status = ? WHERE id = ?', [
    'cancelled',
    booking.id
  ])

  return success(res, 'Booking berhasil dibatalkan!', {
    id: booking.id,
    status: 'cancelled'
  })
}
