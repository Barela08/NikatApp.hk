import express from 'express';
import pool from '../db.js';
import { verifyToken } from '../middleware/auth.js';

const router = express.Router();

router.get('/', verifyToken, async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT f.id, f.provider_id, f.created_at,
        p.shop_name, p.address, p.city, p.rating, p.review_count,
        p.is_premium, p.is_online, p.is_verified, p.profile_image,
        sc.name as category_name, sc.icon as category_icon
      FROM favorites f
      JOIN providers p ON p.id = f.provider_id
      LEFT JOIN service_categories sc ON sc.id = p.category_id
      WHERE f.user_id = $1
      ORDER BY f.created_at DESC
    `, [req.user.id]);
    res.json({ success: true, favorites: result.rows });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

router.post('/:providerId', verifyToken, async (req, res) => {
  try {
    await pool.query(
      'INSERT INTO favorites (user_id, provider_id) VALUES ($1, $2) ON CONFLICT DO NOTHING',
      [req.user.id, req.params.providerId]
    );
    res.json({ success: true, favorited: true });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

router.delete('/:providerId', verifyToken, async (req, res) => {
  try {
    await pool.query(
      'DELETE FROM favorites WHERE user_id=$1 AND provider_id=$2',
      [req.user.id, req.params.providerId]
    );
    res.json({ success: true, favorited: false });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

router.get('/check/:providerId', verifyToken, async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT id FROM favorites WHERE user_id=$1 AND provider_id=$2',
      [req.user.id, req.params.providerId]
    );
    res.json({ success: true, favorited: result.rows.length > 0 });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

export default router;
