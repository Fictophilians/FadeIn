// Dipakai untuk memastikan nilai benar-benar string berisi.
// Mencegah error 500 saat client mengirim angka/null/objek di field teks.
export function isFilledString(value) {
  return typeof value === 'string' && value.trim().length > 0
}
