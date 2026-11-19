import 'dotenv/config'
import app from './src/app.js'

const port = process.env.PORT || 3000

app.listen(port, () => {
  console.log(`FadeIn API berjalan di http://localhost:${port}`)
})
