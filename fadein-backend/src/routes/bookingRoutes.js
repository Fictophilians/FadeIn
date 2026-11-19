import { Router } from 'express'
import { authMiddleware } from '../middlewares/authMiddleware.js'
import { adminOnly } from '../middlewares/roleMiddleware.js'
import {
  createBooking,
  getBookings,
  getBookingById,
  getSlots,
  updateStatus,
  cancelBooking
} from '../controllers/bookingController.js'

const router = Router()

// /slots harus didaftarkan sebelum /:id agar tidak dianggap sebagai id
router.get('/slots', authMiddleware, getSlots)

router.get('/', authMiddleware, getBookings)
router.get('/:id', authMiddleware, getBookingById)
router.post('/', authMiddleware, createBooking)

router.patch('/:id/status', authMiddleware, adminOnly, updateStatus)
router.patch('/:id/cancel', authMiddleware, cancelBooking)

export default router
