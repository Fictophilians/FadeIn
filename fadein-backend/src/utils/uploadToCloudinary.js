import cloudinary from '../config/cloudinary.js'

// Buffer berasal dari Multer memoryStorage, lalu dialirkan ke Cloudinary.
// Tidak ada berkas yang ditulis ke disk, sehingga aman dijalankan di Vercel.
export function uploadToCloudinary(buffer, folder) {
  return new Promise((resolve, reject) => {
    const stream = cloudinary.uploader.upload_stream(
      { folder, resource_type: 'image' },
      (error, result) => {
        if (error || !result) {
          return reject(error ?? new Error('Upload ke Cloudinary gagal'))
        }
        resolve(result)
      }
    )

    stream.end(buffer)
  })
}
