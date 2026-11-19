import bcrypt from 'bcryptjs'
import jwt from 'jsonwebtoken'
import pool from '../config/database.js'
import { success, failure } from '../utils/response.js'
import { isFilledString } from '../utils/validation.js'

const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/

// Registrasi selalu menghasilkan role 'customer'.
// Role admin hanya diberikan lewat data seed / pengelola database,
// supaya pengguna tidak bisa mendaftarkan diri sebagai admin.
export async function register(req, res) {
  const { name, email, password } = req.body

  if (
    !isFilledString(name) ||
    !isFilledString(email) ||
    !isFilledString(password)
  ) {
    return failure(res, 'Nama, email, dan password wajib diisi!')
  }

  // batas panjang mengikuti kolom database dan batas aman bcrypt (72 byte)
  if (name.trim().length > 100) {
    return failure(res, 'Nama maksimal 100 karakter!')
  }

  if (!EMAIL_REGEX.test(email) || email.length > 100) {
    return failure(res, 'Format email tidak valid!')
  }

  if (password.length < 6) {
    return failure(res, 'Password minimal 6 karakter!')
  }

  if (password.length > 72) {
    return failure(res, 'Password maksimal 72 karakter!')
  }

  const [existing] = await pool.execute(
    'SELECT id FROM users WHERE email = ? LIMIT 1',
    [email.trim().toLowerCase()]
  )

  if (existing.length > 0) {
    return failure(res, 'Email sudah terdaftar!', 409)
  }

  const hashedPassword = await bcrypt.hash(password, 10)

  const [result] = await pool.execute(
    'INSERT INTO users (name, email, password, role) VALUES (?, ?, ?, ?)',
    [name.trim(), email.trim().toLowerCase(), hashedPassword, 'customer']
  )

  return success(
    res,
    'Registrasi berhasil, silakan login!',
    {
      id: result.insertId,
      name: name.trim(),
      email: email.trim().toLowerCase(),
      role: 'customer',
      photo: null
    },
    201
  )
}

export async function login(req, res) {
  const { email, password } = req.body

  if (!isFilledString(email) || !isFilledString(password)) {
    return failure(res, 'Email dan password wajib diisi!')
  }

  const [users] = await pool.execute(
    'SELECT * FROM users WHERE email = ? LIMIT 1',
    [email.trim().toLowerCase()]
  )

  if (users.length === 0) {
    return failure(res, 'Email atau password salah!', 401)
  }

  const user = users[0]
  const passwordMatch = await bcrypt.compare(password, user.password)

  if (!passwordMatch) {
    return failure(res, 'Email atau password salah!', 401)
  }

  const token = jwt.sign(
    { id: user.id, name: user.name, email: user.email, role: user.role },
    process.env.JWT_SECRET,
    { expiresIn: '12h' }
  )

  return success(res, 'Login berhasil!', {
    token,
    user: {
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
      photo: user.photo
    }
  })
}
