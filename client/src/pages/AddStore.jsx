import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { ArrowLeft, MapPin } from 'lucide-react';
import { useAuth } from '../context/AuthContext';
import { useLocation } from '../context/LocationContext';
import api from '../utils/api';
import toast from 'react-hot-toast';

export default function AddStore() {
  const { user, refreshUser } = useAuth();
  const { location } = useLocation();
  const navigate = useNavigate();
  const [categories, setCategories] = useState([]);
  const [loading, setLoading] = useState(false);
  const [hasSub, setHasSub] = useState(user?.has_subscription);
  const [form, setForm] = useState({ shop_name: '', description: '', category_id: '', address: location?.address || '', latitude: location?.latitude || '', longitude: location?.longitude || '', city: location?.city || '', phone: user?.phone || '', whatsapp: '' });

  useEffect(() => { api.get('/categories').then(d => setCategories(d.categories || [])); }, []);

  const useCurrentLocation = () => {
    if (location) {
      setForm(f => ({ ...f, address: location.address, latitude: location.latitude, longitude: location.longitude, city: location.city }));
      toast.success('Location set!');
    }
  };

  const submit = async () => {
    if (!form.shop_name) return toast.error('Shop name required');
    if (!form.latitude || !form.longitude) return toast.error('Location required');
    if (!form.category_id) return toast.error('Select a category');
    setLoading(true);
    try {
      await api.post('/providers', form);
      await refreshUser();
      toast.success('Store created!');
      navigate('/provider-dashboard');
    } catch (err) {
      if (err.requires_subscription) {
        toast.error('You need a provider subscription to add a store');
        navigate('/subscribe');
      } else {
        toast.error(err.message);
      }
    } finally { setLoading(false); }
  };

  if (!hasSub && user?.role !== 'admin') {
    return (
      <div style={{ minHeight: '100vh', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: 24, textAlign: 'center' }}>
        <div style={{ fontSize: 48, marginBottom: 16 }}>🏪</div>
        <h2 style={{ marginBottom: 8 }}>Provider Subscription Required</h2>
        <p style={{ color: '#888', marginBottom: 24, fontSize: 14 }}>To add your store and services, you need an active provider subscription.</p>
        <button className="btn-primary" onClick={() => navigate('/subscribe')}>View Provider Plans</button>
        <button className="btn-secondary" style={{ marginTop: 10 }} onClick={() => navigate(-1)}>Go Back</button>
      </div>
    );
  }

  return (
    <div style={{ paddingBottom: 80 }}>
      <div className="topbar">
        <button onClick={() => navigate(-1)} style={{ background: '#111', border: '1px solid #222', borderRadius: 10, width: 38, height: 38, display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer' }}>
          <ArrowLeft size={18} />
        </button>
        <h2 style={{ fontWeight: 700, fontSize: 18 }}>Setup Store</h2>
      </div>
      <div style={{ padding: 16 }}>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
          <div>
            <label style={{ color: '#888', fontSize: 12, marginBottom: 6, display: 'block' }}>Shop Name *</label>
            <input className="input-field" placeholder="Your shop name" value={form.shop_name} onChange={e => setForm(f => ({ ...f, shop_name: e.target.value }))} />
          </div>
          <div>
            <label style={{ color: '#888', fontSize: 12, marginBottom: 6, display: 'block' }}>Category *</label>
            <select className="input-field" value={form.category_id} onChange={e => setForm(f => ({ ...f, category_id: e.target.value }))}>
              <option value="">Select category</option>
              {categories.map(c => <option key={c.id} value={c.id}>{c.icon} {c.name}</option>)}
            </select>
          </div>
          <div>
            <label style={{ color: '#888', fontSize: 12, marginBottom: 6, display: 'block' }}>Description</label>
            <textarea className="input-field" placeholder="What services do you offer?" value={form.description} onChange={e => setForm(f => ({ ...f, description: e.target.value }))} rows={3} style={{ resize: 'none' }} />
          </div>
          <div>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 6 }}>
              <label style={{ color: '#888', fontSize: 12 }}>Location *</label>
              <button onClick={useCurrentLocation} style={{ color: '#00FF88', fontSize: 12, background: 'none', border: 'none', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 4 }}><MapPin size={12} /> Use GPS</button>
            </div>
            <input className="input-field" placeholder="Full address" value={form.address} onChange={e => setForm(f => ({ ...f, address: e.target.value }))} style={{ marginBottom: 8 }} />
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 8 }}>
              <input className="input-field" type="number" placeholder="Latitude" value={form.latitude} onChange={e => setForm(f => ({ ...f, latitude: e.target.value }))} style={{ fontSize: 13 }} />
              <input className="input-field" type="number" placeholder="Longitude" value={form.longitude} onChange={e => setForm(f => ({ ...f, longitude: e.target.value }))} style={{ fontSize: 13 }} />
              <input className="input-field" placeholder="City" value={form.city} onChange={e => setForm(f => ({ ...f, city: e.target.value }))} style={{ fontSize: 13 }} />
            </div>
          </div>
          <div>
            <label style={{ color: '#888', fontSize: 12, marginBottom: 6, display: 'block' }}>Phone</label>
            <input className="input-field" type="tel" placeholder="Contact number" value={form.phone} onChange={e => setForm(f => ({ ...f, phone: e.target.value }))} />
          </div>
          <div>
            <label style={{ color: '#888', fontSize: 12, marginBottom: 6, display: 'block' }}>WhatsApp Number</label>
            <input className="input-field" type="tel" placeholder="WhatsApp (optional)" value={form.whatsapp} onChange={e => setForm(f => ({ ...f, whatsapp: e.target.value }))} />
          </div>
          <button className="btn-primary" onClick={submit} disabled={loading}>{loading ? 'Creating...' : 'Create Store'}</button>
        </div>
      </div>
    </div>
  );
}
