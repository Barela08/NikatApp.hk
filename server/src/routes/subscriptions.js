import express from 'express';
import pool from '../db.js';
import { verifyToken, requireAdmin } from '../middleware/auth.js';

const router = express.Router();

router.get('/plans', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM subscription_plans WHERE is_active=true ORDER BY type, price');
    res.json({ success: true, plans: result.rows });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

router.post('/apply-promo', verifyToken, async (req, res) => {
  const { code, plan_id } = req.body;
  try {
    const promo = await pool.query(
      `SELECT * FROM promo_codes WHERE UPPER(code)=UPPER($1) AND is_active=true AND (valid_till IS NULL OR valid_till > NOW()) AND (max_uses IS NULL OR used_count < max_uses)`,
      [code]
    );
    if (promo.rows.length === 0) return res.status(400).json({ success: false, message: 'Invalid or expired promo code' });
    const p = promo.rows[0];
    let plan = null;
    if (plan_id) {
      const planRes = await pool.query('SELECT * FROM subscription_plans WHERE id=$1', [plan_id]);
      plan = planRes.rows[0];
    }
    res.json({ success: true, promo: p, plan, message: 'Promo code applied!' });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

router.post('/subscribe', verifyToken, async (req, res) => {
  const { plan_id, promo_code } = req.body;
  try {
    const plan = await pool.query('SELECT * FROM subscription_plans WHERE id=$1 AND is_active=true', [plan_id]);
    if (plan.rows.length === 0) return res.status(404).json({ success: false, message: 'Plan not found' });
    const p = plan.rows[0];
    let promoId = null, isFree = false, endDate;
    const start = new Date();
    if (promo_code) {
      const promo = await pool.query(
        `SELECT * FROM promo_codes WHERE UPPER(code)=UPPER($1) AND is_active=true AND (valid_till IS NULL OR valid_till > NOW()) AND (max_uses IS NULL OR used_count < max_uses)`,
        [promo_code]
      );
      if (promo.rows.length > 0) {
        const pr = promo.rows[0];
        promoId = pr.id;
        if (pr.discount_type === 'full') { isFree = true; }
        if (pr.discount_type === 'free_days') {
          endDate = new Date(start.getTime() + pr.discount_value * 86400000);
        } else {
          endDate = new Date(start.getTime() + p.duration_days * 86400000);
        }
        await pool.query('UPDATE promo_codes SET used_count=used_count+1 WHERE id=$1', [pr.id]);
      }
    }
    if (!endDate) endDate = new Date(start.getTime() + p.duration_days * 86400000);
    await pool.query('UPDATE subscriptions SET status=$1 WHERE user_id=$2 AND status IN ($3,$4)', ['expired', req.user.id, 'active', 'trial']);
    const result = await pool.query(
      `INSERT INTO subscriptions (user_id, plan_id, promo_code_id, status, is_free, start_date, end_date)
       VALUES ($1,$2,$3,$4,$5,NOW(),$6) RETURNING *`,
      [req.user.id, p.id, promoId, isFree ? 'active' : 'active', isFree, endDate]
    );
    res.json({ success: true, subscription: result.rows[0], message: 'Subscription activated!' });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

router.get('/my', verifyToken, async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT s.*, sp.name as plan_name, sp.type as plan_type, sp.features, pc.code as promo_code
      FROM subscriptions s
      LEFT JOIN subscription_plans sp ON sp.id=s.plan_id
      LEFT JOIN promo_codes pc ON pc.id=s.promo_code_id
      WHERE s.user_id=$1 ORDER BY s.created_at DESC
    `, [req.user.id]);
    res.json({ success: true, subscriptions: result.rows });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

export default router;
