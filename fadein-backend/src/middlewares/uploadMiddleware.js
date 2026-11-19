import multer from 'multer'

// Error validasi dari fileFilter bukan MulterError, jadi diberi status 400
// secara eksplisit agar errorMiddleware membalas 400 (bukan 500).
function validationError(message) {
  const error = new Error(message)
  error.status = 400
  return error
}

const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 2 * 1024 * 1024 }, // maksimal 2 MB
  fileFilter: (req, file, cb) => {
    const isImageMime = file.mimetype.startsWith('image/')
    const isImageExt = /\.(jpe?g|png)$/i.test(file.originalname)

    if (!isImageMime || !isImageExt) {
      return cb(validationError('File harus berupa gambar JPG atau PNG!'))
    }

    cb(null, true)
  }
})

// nama field pada multipart/form-data harus "photo"
export const uploadPhoto = upload.single('photo')
