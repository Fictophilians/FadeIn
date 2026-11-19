import jwt from 'jsonwebtoken'
import 'dotenv/config'

// Memastikan request membawa token JWT yang valid.
// Hasil verifikasi disimpan di req.user = { id, name, email, role }
export function authMiddleware(req, res, next) {
  const header = req.headers.authorization

  if (!header || !header.startsWith('Bearer ')) {
    return res.status(401).json({ message: 'Token tidak ditemukan, silakan login!' })
  }

  const token = header.split(' ')[1]

  try {
    req.user = jwt.verify(token, process.env.JWT_SECRET)
    next()
  } catch {
    res.status(401).json({ message: 'Token tidak valid atau sudah kedaluwarsa!' })
  }
}
