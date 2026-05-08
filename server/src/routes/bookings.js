import express from 'express';
import pool from '../db.js';
import { verifyToken } from '../middleware/auth.js';

const router = express.Router();
router.use(verifyToken);

router.post('/', async (req, res) => {
  const { provider_id, service_id, scheduled_at, address, notes, price, payment_method } = req.body;
  try {
    const result = await pool.query(
      `INSERT INTO bookings (user_id, provider_id, service_id, scheduled_at, address, notes, price, payment_method)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8) RETURNING *`,
      [req.user.id, provider_id, service_id, scheduled_at, address, notes, price, payment_method || 'cash']
    );
    await pool.query('UPDATE providers SET total_bookings=total_bookings+1 WHERE id=$1', [provider_id]);
    res.json({ success: true, booking: result.rows[0] });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

router.get('/my', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT b.*, p.shop_name, p.profile_image as provider_image, s.name as service_name, u.name as provider_owner
      FROM bookings b
      JOIN providers p ON p.id=b.provider_id
      JOIN users u ON u.id=p.user_id
      LEFT JOIN services s ON s.id=b.service_id
      WHERE b.user_id=$1 ORDER BY b.created_at DESC
    `, [req.user.id]);
    res.json({ success: true, bookings: result.rows });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

router.put('/:id/status', async (req, res) => {
  const { status } = req.body;
  try {
    const booking = await pool.query('SELECT * FROM bookings WHERE id=$1', [req.params.id]);
    if (booking.rows.length === 0) return res.status(404).json({ success: false, message: 'Booking not found' });
    const b = booking.rows[0];
    const provider = await pool.query('SELECT * FROM providers WHERE id=$1', [b.provider_id]);
    const isProvider = req.user.id === provider.rows[0]?.user_id;
    const isUser = req.user.id === b.user_id;
    if (!isProvider && !isUser && req.user.role !== 'admin') {
      return res.status(403).json({ success: false, message: 'Not authorized' });
    }
    const result = await pool.query('UPDATE bookings SET status=$1, updated_at=NOW() WHERE id=$2 RETURNING *', [status, req.params.id]);
    res.json({ success: true, booking: result.rows[0] });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

router.post('/:id/review', async (req, res) => {
  const { rating, comment } = req.body;
  try {
    const booking = await pool.query('SELECT * FROM bookings WHERE id=$1 AND user_id=$2 AND status=$3', [req.params.id, req.user.id, 'completed']);
    if (booking.rows.length === 0) return res.status(400).json({ success: false, message: 'Can only review completed bookings' });
    const b = booking.rows[0];
    const result = await pool.query(
      'INSERT INTO reviews (user_id, provider_id, booking_id, rating, comment) VALUES ($1,$2,$3,$4,$5) RETURNING *',
      [req.user.id, b.provider_id, b.id, rating, comment]
    );
    await pool.query(`
      UPDATE providers SET 
        rating=(SELECT AVG(rating) FROM reviews WHERE provider_id=$1),
        review_count=(SELECT COUNT(*) FROM reviews WHERE provider_id=$1)
      WHERE id=$1`, [b.provider_id]);
    res.json({ success: true, review: result.rows[0] });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

export default router;
