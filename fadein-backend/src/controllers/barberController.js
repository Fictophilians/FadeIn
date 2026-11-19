import pool from '../config/database.js'
import { success, failure } from '../utils/response.js'
import { uploadToCloudinary } from '../utils/uploadToCloudinary.js'
import { isFilledString } from '../utils/validation.js'

const SELECT_FIELDS = 'id, name, description, photo, created_at'

export async function getBarbers(req, res) {
  const [barbers] = await pool.query(
    `SELECT ${SELECT_FIELDS} FROM barbers ORDER BY id ASC`
  )

  return success(res, 'Daftar barber berhasil diambil!', barbers)
}

export async function getBarberById(req, res) {
  const [barbers] = await pool.execute(
    `SELECT ${SELECT_FIELDS} FROM barbers WHERE id = ? LIMIT 1`,
    [req.params.id]
  )

  if (barbers.length === 0) {
    return failure(res, 'Barber tidak ditemukan!', 404)
  }

  return success(res, 'Detail barber berhasil diambil!', barbers[0])
}

export async function createBarber(req, res) {
  const { name, description } = req.body

  if (!isFilledString(name)) {
    return failure(res, 'Nama barber wajib diisi!')
  }

  // foto boleh dikirim sebagai file (multipart) atau URL langsung (JSON)
  const photo = req.file
    ? (await uploadToCloudinary(req.file.buffer, 'fadein/barbers')).secure_url
    : req.body.photo

  if (!photo) {
    return failure(res, 'Foto barber wajib diunggah!')
  }

  const [result] = await pool.execute(
    'INSERT INTO barbers (name, description, photo) VALUES (?, ?, ?)',
    [name.trim(), description ?? null, photo]
  )

  const [rows] = await pool.execute(
    `SELECT ${SELECT_FIELDS} FROM barbers WHERE id = ?`,
    [result.insertId]
  )

  return success(res, 'Barber berhasil ditambahkan!', rows[0], 201)
}

export async function updateBarber(req, res) {
  const { id } = req.params
  const { name, description } = req.body

  const [existing] = await pool.execute(
    'SELECT * FROM barbers WHERE id = ? LIMIT 1',
    [id]
  )

  if (existing.length === 0) {
    return failure(res, 'Barber tidak ditemukan!', 404)
  }

  const current = existing[0]

  if (name !== undefined && !isFilledString(name)) {
    return failure(res, 'Nama barber tidak boleh kosong!')
  }

  const photo = req.file
    ? (await uploadToCloudinary(req.file.buffer, 'fadein/barbers')).secure_url
    : (req.body.photo ?? current.photo)

  await pool.execute(
    'UPDATE barbers SET name = ?, description = ?, photo = ? WHERE id = ?',
    [name ?? current.name, description ?? current.description, photo, id]
  )

  const [rows] = await pool.execute(
    `SELECT ${SELECT_FIELDS} FROM barbers WHERE id = ?`,
    [id]
  )

  return success(res, 'Data barber berhasil diperbarui!', rows[0])
}

export async function deleteBarber(req, res) {
  const [result] = await pool.execute('DELETE FROM barbers WHERE id = ?', [
    req.params.id
  ])

  if (result.affectedRows === 0) {
    return failure(res, 'Barber tidak ditemukan!', 404)
  }

  return success(res, 'Barber berhasil dihapus!')
}
