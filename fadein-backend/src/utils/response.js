// Bentuk respons seragam untuk seluruh endpoint: { message, data }
export const success = (res, message, data = null, status = 200) => {
  return res.status(status).json({ message, data })
}

export const failure = (res, message, status = 400) => {
  return res.status(status).json({ message })
}
