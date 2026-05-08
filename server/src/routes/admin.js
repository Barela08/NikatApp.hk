import express from 'express';
import pool from '../db.js';
import { verifyToken, requireAdmin } from '../middleware/auth.js';

const router = express.Router();
router.use(verifyToken, requireAdmin);

router.get('/stats', async (req, res) => {
  try {
    const users = await pool.query(`SELECT COUNT(*) as total, SUM(CASE WHEN role='provider' THEN 1 ELSE 0 END) as providers, SUM(CASE WHEN role='customer' THEN 1 ELSE 0 END) as customers FROM users`);
    const subs = await pool.query(`SELECT COUNT(*) as total, SUM(CASE WHEN status='active' AND end_date>NOW() THEN 1 ELSE 0 END) as active FROM subscriptions`);
    const bookings = await pool.query(`SELECT COUNT(*) as total, SUM(CASE WHEN status='completed' THEN 1 ELSE 0 END) as completed FROM bookings`);
    const providers = await pool.query(`SELECT COUNT(*) as total, SUM(CASE WHEN is_verified THEN 1 ELSE 0 END) as verified FROM providers`);
    res.json({ success: true, stats: { users: users.rows[0], subscriptions: subs.rows[0], bookings: bookings.rows[0], providers: providers.rows[0] } });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

router.get('/users', async (req, res) => {
  const { role, search, limit = 20, offset = 0 } = req.query;
  try {
    let query = `SELECT u.*, CASE WHEN s.id IS NOT NULL AND s.end_date>NOW() THEN true ELSE false END as has_subscription FROM users u LEFT JOIN subscriptions s ON s.user_id=u.id AND s.status='active' WHERE 1=1`;
    const params = [];
    if (role) { query += ` AND u.role=$${params.length+1}`; params.push(role); }
    if (search) { query += ` AND (u.name ILIKE $${params.length+1} OR u.phone ILIKE $${params.length+1})`; params.push(`%${search}%`); }
    query += ` ORDER BY u.created_at DESC LIMIT $${params.length+1} OFFSET $${params.length+2}`;
    params.push(limit, offset);
    const result = await pool.query(query, params);
    const count = await pool.query(`SELECT COUNT(*) FROM users WHERE 1=1 ${role ? `AND role='${role}'` : ''}`);
    res.json({ success: true, users: result.rows, total: parseInt(count.rows[0].count) });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

router.post('/grant-subscription', async (req, res) => {
  const { user_id, plan_id, days, is_trial = false } = req.body;
  try {
    const endDate = new Date(Date.now() + days * 86400000);
    await pool.query('UPDATE subscriptions SET status=$1 WHERE user_id=$2 AND status IN ($3,$4)', ['expired', user_id, 'active', 'trial']);
    const result = await pool.query(
      `INSERT INTO subscriptions (user_id, plan_id, status, is_free, start_date, end_date)
       VALUES ($1,$2,$3,true,NOW(),$4) RETURNING *`,
      [user_id, plan_id, is_trial ? 'trial' : 'active', endDate]
    );
    res.json({ success: true, subscription: result.rows[0], message: is_trial ? 'Trial granted!' : 'Free subscription granted!' });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

router.post('/plans', async (req, res) => {
  const { name, type, price, duration_days, features } = req.body;
  try {
    const result = await pool.query(
      `INSERT INTO subscription_plans (name, type, price, duration_days, features) VALUES ($1,$2,$3,$4,$5) RETURNING *`,
      [name, type, price, duration_days, JSON.stringify(features || [])]
    );
    res.json({ success: true, plan: result.rows[0] });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

router.put('/plans/:id', async (req, res) => {
  const { name, price, duration_days, features, is_active } = req.body;
  try {
    const result = await pool.query(
      `UPDATE subscription_plans SET name=$1,price=$2,duration_days=$3,features=$4,is_active=$5 WHERE id=$6 RETURNING *`,
      [name, price, duration_days, JSON.stringify(features), is_active, req.params.id]
    );
    res.json({ success: true, plan: result.rows[0] });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

router.get('/promo-codes', async (req, res) => {
  try {
    const result = await pool.query(`SELECT pc.*, u.name as created_by_name FROM promo_codes pc LEFT JOIN users u ON u.id=pc.created_by ORDER BY pc.created_at DESC`);
    res.json({ success: true, promo_codes: result.rows });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

router.post('/promo-codes', async (req, res) => {
  const { code, discount_type, discount_value, plan_type, max_uses, valid_till } = req.body;
  try {
    const result = await pool.query(
      `INSERT INTO promo_codes (code, discount_type, discount_value, plan_type, max_uses, valid_till, created_by)
       VALUES (UPPER($1),$2,$3,$4,$5,$6,$7) RETURNING *`,
      [code, discount_type, discount_value, plan_type, max_uses || null, valid_till || null, req.user.id]
    );
    res.json({ success: true, promo_code: result.rows[0] });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

router.put('/promo-codes/:id', async (req, res) => {
  const { is_active } = req.body;
  try {
    const result = await pool.query('UPDATE promo_codes SET is_active=$1 WHERE id=$2 RETURNING *', [is_active, req.params.id]);
    res.json({ success: true, promo_code: result.rows[0] });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

router.get('/providers', async (req, res) => {
  const { status, limit = 20, offset = 0 } = req.query;
  try {
    let query = `SELECT p.*, u.name as owner_name, u.phone as owner_phone, sc.name as category_name FROM providers p JOIN users u ON u.id=p.user_id LEFT JOIN service_categories sc ON sc.id=p.category_id WHERE 1=1`;
    const params = [];
    if (status) { query += ` AND p.status=$${params.length+1}`; params.push(status); }
    query += ` ORDER BY p.created_at DESC LIMIT $${params.length+1} OFFSET $${params.length+2}`;
    params.push(limit, offset);
    const result = await pool.query(query, params);
    res.json({ success: true, providers: result.rows });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

router.put('/providers/:id/status', async (req, res) => {
  const { status, is_verified, is_premium } = req.body;
  try {
    const result = await pool.query(
      `UPDATE providers SET status=COALESCE($1,status), is_verified=COALESCE($2,is_verified), is_premium=COALESCE($3,is_premium), updated_at=NOW() WHERE id=$4 RETURNING *`,
      [status, is_verified, is_premium, req.params.id]
    );
    res.json({ success: true, provider: result.rows[0] });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

router.put('/users/:id/status', async (req, res) => {
  const { is_active, free_views_limit } = req.body;
  try {
    const result = await pool.query(
      `UPDATE users SET is_active=COALESCE($1,is_active), free_views_limit=COALESCE($2,free_views_limit), updated_at=NOW() WHERE id=$3 RETURNING *`,
      [is_active, free_views_limit, req.params.id]
    );
    res.json({ success: true, user: result.rows[0] });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

router.get('/subscriptions', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT s.*, u.name as user_name, u.phone as user_phone, u.role as user_role,
        sp.name as plan_name, sp.type as plan_type, pc.code as promo_code
      FROM subscriptions s
      JOIN users u ON u.id=s.user_id
      LEFT JOIN subscription_plans sp ON sp.id=s.plan_id
      LEFT JOIN promo_codes pc ON pc.id=s.promo_code_id
      ORDER BY s.created_at DESC LIMIT 50
    `);
    res.json({ success: true, subscriptions: result.rows });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

export default router;
