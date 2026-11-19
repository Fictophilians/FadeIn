import { Router } from 'express'
import { authMiddleware } from '../middlewares/authMiddleware.js'
import { adminOnly } from '../middlewares/roleMiddleware.js'
import { uploadPhoto } from '../middlewares/uploadMiddleware.js'
import {
  getBarbers,
  getBarberById,
  createBarber,
  updateBarber,
  deleteBarber
} from '../controllers/barberController.js'

const router = Router()

router.get('/', authMiddleware, getBarbers)
router.get('/:id', authMiddleware, getBarberById)

router.post('/', authMiddleware, adminOnly, uploadPhoto, createBarber)
router.put('/:id', authMiddleware, adminOnly, uploadPhoto, updateBarber)
router.delete('/:id', authMiddleware, adminOnly, deleteBarber)

export default router
