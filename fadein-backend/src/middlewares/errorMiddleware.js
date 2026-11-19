import multer from 'multer'

export function notFound(req, res) {
  res.status(404).json({
    message: `Endpoint ${req.method} ${req.originalUrl} tidak ditemukan!`
  })
}

// Semua error dari controller maupun middleware berakhir di sini,
// supaya aplikasi tidak pernah membalas HTML stack trace.
export function errorHandler(err, req, res, next) {
  if (err instanceof multer.MulterError) {
    const message =
      err.code === 'LIMIT_FILE_SIZE'
        ? 'Ukuran foto maksimal 2 MB!'
        : err.code === 'LIMIT_UNEXPECTED_FILE'
          ? 'Field upload harus bernama "photo"!'
          : err.message

    return res.status(400).json({ message })
  }

  // Validasi yang dilempar middleware sendiri (mis. filter tipe file upload)
  if (err?.status === 400) {
    return res.status(400).json({ message: err.message })
  }

  if (err?.code === 'ER_DUP_ENTRY') {
    return res.status(409).json({ message: 'Data tersebut sudah terdaftar!' })
  }

  if (err?.code === 'ER_NO_REFERENCED_ROW_2') {
    return res.status(400).json({ message: 'Data yang dirujuk tidak ditemukan!' })
  }

  if (err?.code === 'ER_ROW_IS_REFERENCED_2') {
    return res.status(400).json({ message: 'Data tidak bisa dihapus karena masih dipakai pada booking!' })
  }

  if (['ECONNREFUSED', 'ENOTFOUND', 'ETIMEDOUT', 'ER_ACCESS_DENIED_ERROR'].includes(err?.code)) {
    return res.status(503).json({ message: 'Tidak dapat terhubung ke database!' })
  }

  console.error('[ERROR]', err)

  // detail internal (query SQL, stack trace) hanya boleh muncul saat lokal
  const message =
    process.env.NODE_ENV === 'production'
      ? 'Terjadi kesalahan pada server!'
      : err?.message || 'Terjadi kesalahan pada server!'

  res.status(500).json({ message })
}
