import jwt from 'jsonwebtoken';

const JWT_SECRET = process.env.JWT_SECRET || 'nikat_secret_key_2024';

export const generateToken = (user) => {
  return jwt.sign({ id: user.id, role: user.role, phone: user.phone }, JWT_SECRET, { expiresIn: '30d' });
};

export const verifyToken = (req, res, next) => {
  const auth = req.headers.authorization;
  if (!auth || !auth.startsWith('Bearer ')) {
    return res.status(401).json({ success: false, message: 'Unauthorized' });
  }
  try {
    const token = auth.split(' ')[1];
    req.user = jwt.verify(token, JWT_SECRET);
    next();
  } catch {
    return res.status(401).json({ success: false, message: 'Invalid token' });
  }
};

export const requireAdmin = (req, res, next) => {
  if (req.user?.role !== 'admin') {
    return res.status(403).json({ success: false, message: 'Admin access required' });
  }
  next();
};

export const requireProvider = (req, res, next) => {
  if (!['provider', 'admin'].includes(req.user?.role)) {
    return res.status(403).json({ success: false, message: 'Provider access required' });
  }
  next();
};
