import pool from '../config/database.js'
import { success, failure } from '../utils/response.js'
import { isFilledString } from '../utils/validation.js'

const SELECT_FIELDS = 'id, name, price, duration, created_at'

export async function getServices(req, res) {
  const [services] = await pool.query(
    `SELECT ${SELECT_FIELDS} FROM services ORDER BY price ASC`
  )

  return success(res, 'Daftar layanan berhasil diambil!', services)
}

export async function getServiceById(req, res) {
  const [services] = await pool.execute(
    `SELECT ${SELECT_FIELDS} FROM services WHERE id = ? LIMIT 1`,
    [req.params.id]
  )

  if (services.length === 0) {
    return failure(res, 'Layanan tidak ditemukan!', 404)
  }

  return success(res, 'Detail layanan berhasil diambil!', services[0])
}

export async function createService(req, res) {
  const { name, price, duration } = req.body

  if (!isFilledString(name) || price === undefined || duration === undefined) {
    return failure(res, 'Nama, harga, dan durasi layanan wajib diisi!')
  }

  const priceValue = Number(price)
  const durationValue = Number(duration)

  if (
    !Number.isFinite(priceValue) ||
    !Number.isFinite(durationValue) ||
    priceValue <= 0 ||
    durationValue <= 0
  ) {
    return failure(res, 'Harga dan durasi harus berupa angka lebih dari 0!')
  }

  const [result] = await pool.execute(
    'INSERT INTO services (name, price, duration) VALUES (?, ?, ?)',
    [name.trim(), priceValue, durationValue]
  )

  const [rows] = await pool.execute(
    `SELECT ${SELECT_FIELDS} FROM services WHERE id = ?`,
    [result.insertId]
  )

  return success(res, 'Layanan berhasil ditambahkan!', rows[0], 201)
}

export async function updateService(req, res) {
  const { id } = req.params
  const { name, price, duration } = req.body

  const [existing] = await pool.execute(
    'SELECT * FROM services WHERE id = ? LIMIT 1',
    [id]
  )

  if (existing.length === 0) {
    return failure(res, 'Layanan tidak ditemukan!', 404)
  }

  const current = existing[0]

  if (name !== undefined && !isFilledString(name)) {
    return failure(res, 'Nama layanan tidak boleh kosong!')
  }

  const priceValue = Number(price ?? current.price)
  const durationValue = Number(duration ?? current.duration)

  if (
    !Number.isFinite(priceValue) ||
    !Number.isFinite(durationValue) ||
    priceValue <= 0 ||
    durationValue <= 0
  ) {
    return failure(res, 'Harga dan durasi harus berupa angka lebih dari 0!')
  }

  await pool.execute(
    'UPDATE services SET name = ?, price = ?, duration = ? WHERE id = ?',
    [name ?? current.name, priceValue, durationValue, id]
  )

  const [rows] = await pool.execute(
    `SELECT ${SELECT_FIELDS} FROM services WHERE id = ?`,
    [id]
  )

  return success(res, 'Layanan berhasil diperbarui!', rows[0])
}

export async function deleteService(req, res) {
  const [result] = await pool.execute('DELETE FROM services WHERE id = ?', [
    req.params.id
  ])

  if (result.affectedRows === 0) {
    return failure(res, 'Layanan tidak ditemukan!', 404)
  }

  return success(res, 'Layanan berhasil dihapus!')
}
