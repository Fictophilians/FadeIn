import pool from '../config/database.js'
import { success, failure } from '../utils/response.js'
import { uploadToCloudinary } from '../utils/uploadToCloudinary.js'

export async function getProfile(req, res) {
  const [users] = await pool.execute(
    'SELECT id, name, email, role, photo, created_at FROM users WHERE id = ? LIMIT 1',
    [req.user.id]
  )

  if (users.length === 0) {
    return failure(res, 'User tidak ditemukan!', 404)
  }

  return success(res, 'Profil berhasil diambil!', users[0])
}

export async function updatePhoto(req, res) {
  if (!req.file) {
    return failure(res, 'Foto belum dipilih!')
  }

  const result = await uploadToCloudinary(req.file.buffer, 'fadein/users')

  await pool.execute('UPDATE users SET photo = ? WHERE id = ?', [
    result.secure_url,
    req.user.id
  ])

  return success(res, 'Foto profil berhasil diperbarui!', {
    photo: result.secure_url
  })
}
