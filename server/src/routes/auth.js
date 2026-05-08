import express from 'express';
import pool from '../db.js';
import { generateToken, verifyToken } from '../middleware/auth.js';

const router = express.Router();

router.post('/send-otp', async (req, res) => {
  const { phone } = req.body;
  if (!phone) return res.status(400).json({ success: false, message: 'Phone required' });
  const otp = Math.floor(100000 + Math.random() * 900000).toString();
  global.otpStore = global.otpStore || {};
  global.otpStore[phone] = { otp, expires: Date.now() + 10 * 60 * 1000 };
  console.log(`OTP for ${phone}: ${otp}`);
  res.json({ success: true, message: 'OTP sent', otp });
});

router.post('/verify-otp', async (req, res) => {
  const { phone, otp, name, role = 'customer' } = req.body;
  global.otpStore = global.otpStore || {};
  const stored = global.otpStore[phone];
  if (!stored || stored.otp !== otp || Date.now() > stored.expires) {
    return res.status(400).json({ success: false, message: 'Invalid or expired OTP' });
  }
  delete global.otpStore[phone];
  try {
    let user = await pool.query('SELECT * FROM users WHERE phone = $1', [phone]);
    if (user.rows.length === 0) {
      user = await pool.query(
        'INSERT INTO users (name, phone, role) VALUES ($1, $2, $3) RETURNING *',
        [name || 'User', phone, role]
      );
    }
    const u = user.rows[0];
    const token = generateToken(u);
    res.json({ success: true, token, user: { id: u.id, name: u.name, phone: u.phone, role: u.role, is_verified: u.is_verified } });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

router.get('/me', verifyToken, async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT u.*, 
        CASE WHEN s.id IS NOT NULL AND s.end_date > NOW() AND s.status = 'active' THEN true ELSE false END as has_subscription,
        s.end_date as subscription_end,
        s.status as subscription_status,
        p.id as provider_id,
        p.shop_name
      FROM users u
      LEFT JOIN subscriptions s ON s.user_id = u.id AND s.status IN ('active','trial') AND s.end_date > NOW()
      LEFT JOIN providers p ON p.user_id = u.id
      WHERE u.id = $1
    `, [req.user.id]);
    if (result.rows.length === 0) return res.status(404).json({ success: false, message: 'User not found' });
    res.json({ success: true, user: result.rows[0] });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

router.put('/location', verifyToken, async (req, res) => {
  const { latitude, longitude, address, city } = req.body;
  try {
    await pool.query(
      'UPDATE users SET latitude=$1, longitude=$2, address=$3, city=$4, updated_at=NOW() WHERE id=$5',
      [latitude, longitude, address, city, req.user.id]
    );
    res.json({ success: true, message: 'Location updated' });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

export default router;
