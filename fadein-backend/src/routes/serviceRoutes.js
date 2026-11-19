import { Router } from 'express'
import { authMiddleware } from '../middlewares/authMiddleware.js'
import { adminOnly } from '../middlewares/roleMiddleware.js'
import {
  getServices,
  getServiceById,
  createService,
  updateService,
  deleteService
} from '../controllers/serviceController.js'

const router = Router()

router.get('/', authMiddleware, getServices)
router.get('/:id', authMiddleware, getServiceById)

router.post('/', authMiddleware, adminOnly, createService)
router.put('/:id', authMiddleware, adminOnly, updateService)
router.delete('/:id', authMiddleware, adminOnly, deleteService)

export default router
