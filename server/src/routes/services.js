import express from 'express';
import pool from '../db.js';
import { verifyToken, requireProvider } from '../middleware/auth.js';

const router = express.Router();

router.post('/:providerId/services', verifyToken, requireProvider, async (req, res) => {
  const { name, description, price, price_type, duration_minutes } = req.body;
  try {
    const provider = await pool.query('SELECT * FROM providers WHERE id=$1 AND user_id=$2', [req.params.providerId, req.user.id]);
    if (provider.rows.length === 0) return res.status(403).json({ success: false, message: 'Not authorized' });
    const result = await pool.query(
      `INSERT INTO services (provider_id, name, description, price, price_type, duration_minutes)
       VALUES ($1,$2,$3,$4,$5,$6) RETURNING *`,
      [req.params.providerId, name, description, price || null, price_type || 'fixed', duration_minutes || null]
    );
    res.json({ success: true, service: result.rows[0] });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

router.put('/services/:id', verifyToken, requireProvider, async (req, res) => {
  const { name, description, price, is_active } = req.body;
  try {
    const result = await pool.query(
      `UPDATE services SET name=COALESCE($1,name), description=COALESCE($2,description), price=COALESCE($3,price), is_active=COALESCE($4,is_active)
       WHERE id=$5 RETURNING *`,
      [name, description, price, is_active, req.params.id]
    );
    res.json({ success: true, service: result.rows[0] });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

export default router;
