import express from 'express';
import pool from '../db.js';
import { verifyToken, requireProvider } from '../middleware/auth.js';

const router = express.Router();

const haversineDistance = (lat1, lon1, lat2, lon2) => {
  const R = 6371;
  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLon = (lon2 - lon1) * Math.PI / 180;
  const a = Math.sin(dLat/2)**2 + Math.cos(lat1*Math.PI/180)*Math.cos(lat2*Math.PI/180)*Math.sin(dLon/2)**2;
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
};

router.get('/nearby', async (req, res) => {
  const { lat, lng, radius = 10, category, limit = 20, offset = 0 } = req.query;
  try {
    let query = `
      SELECT p.*, u.phone, u.name as owner_name, sc.name as category_name, sc.icon as category_icon,
        (6371 * acos(LEAST(1, cos(radians($1)) * cos(radians(p.latitude)) * cos(radians(p.longitude) - radians($2)) + sin(radians($1)) * sin(radians(p.latitude))))) AS distance
      FROM providers p
      JOIN users u ON u.id = p.user_id
      LEFT JOIN service_categories sc ON sc.id = p.category_id
      WHERE p.status = 'active'
    `;
    const params = [lat || 28.6139, lng || 77.2090];
    if (category) { query += ` AND p.category_id = $${params.length+1}`; params.push(category); }
    query += ` HAVING (6371 * acos(LEAST(1, cos(radians($1)) * cos(radians(p.latitude)) * cos(radians(p.longitude) - radians($2)) + sin(radians($1)) * sin(radians(p.latitude))))) <= $${params.length+1}`;
    params.push(radius);
    query += ` ORDER BY p.is_premium DESC, distance ASC, p.rating DESC LIMIT $${params.length+1} OFFSET $${params.length+2}`;
    params.push(limit, offset);
    const result = await pool.query(query, params);
    res.json({ success: true, providers: result.rows, total: result.rows.length });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

router.get('/:id', async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT p.*, u.phone, u.name as owner_name, sc.name as category_name, sc.icon as category_icon
      FROM providers p
      JOIN users u ON u.id = p.user_id
      LEFT JOIN service_categories sc ON sc.id = p.category_id
      WHERE p.id = $1
    `, [req.params.id]);
    if (result.rows.length === 0) return res.status(404).json({ success: false, message: 'Provider not found' });
    const services = await pool.query('SELECT * FROM services WHERE provider_id=$1 AND is_active=true', [req.params.id]);
    const reviews = await pool.query(`
      SELECT r.*, u.name as user_name FROM reviews r
      JOIN users u ON u.id = r.user_id WHERE r.provider_id=$1 ORDER BY r.created_at DESC LIMIT 10
    `, [req.params.id]);
    const provider = result.rows[0];
    provider.services = services.rows;
    provider.reviews = reviews.rows;
    res.json({ success: true, provider });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

router.post('/:id/view', verifyToken, async (req, res) => {
  try {
    const user = await pool.query('SELECT * FROM users WHERE id=$1', [req.user.id]);
    const u = user.rows[0];
    const hasSubscription = await pool.query(
      `SELECT id FROM subscriptions WHERE user_id=$1 AND status IN ('active','trial') AND end_date > NOW()`, [u.id]
    );
    if (hasSubscription.rows.length === 0) {
      if (u.free_views_used >= u.free_views_limit) {
        return res.status(403).json({ success: false, message: 'Free limit reached', requires_subscription: true, used: u.free_views_used, limit: u.free_views_limit });
      }
      await pool.query('UPDATE users SET free_views_used=free_views_used+1 WHERE id=$1', [u.id]);
    }
    await pool.query('INSERT INTO provider_views (provider_id, viewer_id) VALUES ($1,$2)', [req.params.id, u.id]);
    await pool.query('UPDATE providers SET total_views=total_views+1 WHERE id=$1', [req.params.id]);
    const remaining = hasSubscription.rows.length > 0 ? -1 : (u.free_views_limit - u.free_views_used - 1);
    res.json({ success: true, remaining_free_views: remaining });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

router.post('/', verifyToken, requireProvider, async (req, res) => {
  const { shop_name, description, category_id, address, latitude, longitude, city, phone, whatsapp, kyc_status } = req.body;
  try {
    const hasSub = await pool.query(
      `SELECT id FROM subscriptions WHERE user_id=$1 AND status IN ('active','trial') AND end_date > NOW()`, [req.user.id]
    );
    if (hasSub.rows.length === 0) {
      return res.status(403).json({ success: false, message: 'Subscription required to add store', requires_subscription: true });
    }
    const existing = await pool.query('SELECT id FROM providers WHERE user_id=$1', [req.user.id]);
    if (existing.rows.length > 0) {
      return res.status(400).json({ success: false, message: 'You already have a store' });
    }
    const kycVerified = kyc_status === 'verified';
    const result = await pool.query(
      `INSERT INTO providers (user_id, shop_name, description, category_id, address, latitude, longitude, city, phone, whatsapp, kyc_status, is_verified)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12) RETURNING *`,
      [req.user.id, shop_name, description, category_id, address, latitude, longitude, city, phone, whatsapp,
       kyc_status || 'pending', kycVerified]
    );
    res.json({ success: true, provider: result.rows[0] });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

router.put('/:id', verifyToken, requireProvider, async (req, res) => {
  const { shop_name, description, category_id, address, latitude, longitude, city, phone, whatsapp, is_online } = req.body;
  try {
    const result = await pool.query(
      `UPDATE providers SET shop_name=$1,description=$2,category_id=$3,address=$4,latitude=$5,longitude=$6,
       city=$7,phone=$8,whatsapp=$9,is_online=$10,updated_at=NOW()
       WHERE id=$11 AND user_id=$12 RETURNING *`,
      [shop_name, description, category_id, address, latitude, longitude, city, phone, whatsapp, is_online, req.params.id, req.user.id]
    );
    if (result.rows.length === 0) return res.status(403).json({ success: false, message: 'Not authorized' });
    res.json({ success: true, provider: result.rows[0] });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

router.get('/my/dashboard', verifyToken, requireProvider, async (req, res) => {
  try {
    const provider = await pool.query('SELECT * FROM providers WHERE user_id=$1', [req.user.id]);
    if (provider.rows.length === 0) return res.status(404).json({ success: false, message: 'Provider profile not found' });
    const p = provider.rows[0];
    const bookings = await pool.query(`
      SELECT COUNT(*) as total, 
        SUM(CASE WHEN status='completed' THEN 1 ELSE 0 END) as completed,
        SUM(CASE WHEN status='pending' THEN 1 ELSE 0 END) as pending,
        SUM(CASE WHEN status='cancelled' THEN 1 ELSE 0 END) as cancelled
      FROM bookings WHERE provider_id=$1`, [p.id]);
    const earnings = await pool.query(`
      SELECT COALESCE(SUM(price),0) as total,
        COALESCE(SUM(CASE WHEN created_at >= CURRENT_DATE THEN price ELSE 0 END),0) as today,
        COALESCE(SUM(CASE WHEN created_at >= date_trunc('week',NOW()) THEN price ELSE 0 END),0) as this_week
      FROM bookings WHERE provider_id=$1 AND status='completed' AND payment_status='paid'`, [p.id]);
    const services = await pool.query('SELECT COUNT(*) as total FROM services WHERE provider_id=$1 AND is_active=true', [p.id]);
    const recentBookings = await pool.query(`
      SELECT b.*, u.name as user_name, u.phone as user_phone, s.name as service_name
      FROM bookings b JOIN users u ON u.id=b.user_id LEFT JOIN services s ON s.id=b.service_id
      WHERE b.provider_id=$1 ORDER BY b.created_at DESC LIMIT 10`, [p.id]);
    res.json({
      success: true,
      provider: p,
      stats: { ...bookings.rows[0], ...earnings.rows[0], services: services.rows[0].total, views: p.total_views, rating: p.rating, review_count: p.review_count },
      recent_bookings: recentBookings.rows
    });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

export default router;
