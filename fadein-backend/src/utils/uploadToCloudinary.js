import cloudinary from '../config/cloudinary.js'

const TIMEOUT_MS = 20000

/**
 * Unggah buffer ke Cloudinary.
 *
 * `uploader.upload_stream` bisa menggantung tanpa batas pada sebagian
 * jaringan (pernah terjadi di mesin pengembang), jadi:
 *   1. dicoba dengan base64 — satu request HTTP biasa, lebih andal,
 *   2. bila gagal, baru `upload_stream` dengan timer.
 *
 * Tidak ada berkas yang ditulis ke disk, sehingga aman di Vercel.
 */
export async function uploadToCloudinary(buffer, folder) {
  try {
    return await cloudinary.uploader.upload(
      `data:image/jpeg;base64,${buffer.toString('base64')}`,
      { folder, resource_type: 'image', timeout: TIMEOUT_MS }
    )
  } catch (error) {
    if (process.env.NODE_ENV !== 'test') {
      console.error(`[cloudinary] base64 gagal: ${error.message}`)
    }
    return uploadViaStream(buffer, folder)
  }
}

function uploadViaStream(buffer, folder) {
  return new Promise((resolve, reject) => {
    const timer = setTimeout(
      () => reject(new Error('Upload ke Cloudinary melebihi batas waktu')),
      TIMEOUT_MS
    )

    const stream = cloudinary.uploader.upload_stream(
      { folder, resource_type: 'image' },
      (error, result) => {
        clearTimeout(timer)
        if (error || !result) {
          return reject(error ?? new Error('Upload ke Cloudinary gagal'))
        }
        resolve(result)
      }
    )

    stream.on('error', (error) => {
      clearTimeout(timer)
      reject(error)
    })

    stream.end(buffer)
  })
}