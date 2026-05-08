import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import authRoutes from './routes/auth.js';
import providerRoutes from './routes/providers.js';
import subscriptionRoutes from './routes/subscriptions.js';
import adminRoutes from './routes/admin.js';
import categoryRoutes from './routes/categories.js';
import bookingRoutes from './routes/bookings.js';
import serviceRoutes from './routes/services.js';

dotenv.config();

const app = express();
const PORT = 3001;

app.use(cors({ origin: '*' }));
app.use(express.json());

app.use('/api/auth', authRoutes);
app.use('/api/providers', providerRoutes);
app.use('/api/subscriptions', subscriptionRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/categories', categoryRoutes);
app.use('/api/bookings', bookingRoutes);
app.use('/api/providers', serviceRoutes);

app.get('/api/health', (req, res) => res.json({ success: true, message: 'NIKAT API running' }));

app.listen(PORT, 'localhost', () => {
  console.log(`NIKAT API server running on port ${PORT}`);
});
