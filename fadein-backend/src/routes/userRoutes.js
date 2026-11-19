import { Router } from 'express'
import { authMiddleware } from '../middlewares/authMiddleware.js'
import { uploadPhoto } from '../middlewares/uploadMiddleware.js'
import { getProfile, updatePhoto } from '../controllers/userController.js'

const router = Router()

router.get('/profile', authMiddleware, getProfile)
router.put('/photo', authMiddleware, uploadPhoto, updatePhoto)

export default router
