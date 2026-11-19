// Dipakai setelah authMiddleware.
// Customer yang mencoba endpoint admin mendapat 403 Forbidden
// (bukan 401, karena ia sudah terautentikasi, hanya tidak berhak).
export function adminOnly(req, res, next) {
  if (req.user?.role !== 'admin') {
    return res.status(403).json({ message: 'Akses ditolak, endpoint ini khusus admin!' })
  }

  next()
}
