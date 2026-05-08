import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { TrendingUp, Eye, Star, Package, Plus, Edit, CheckCircle, XCircle, Clock } from 'lucide-react';
import { useAuth } from '../context/AuthContext';
import api from '../utils/api';
import toast from 'react-hot-toast';

const STATUS_COLORS = { pending: '#FFD700', accepted: '#00FF88', rejected: '#FF4444', completed: '#00FF88', cancelled: '#888', on_the_way: '#00BBFF', in_progress: '#FF8800' };

export default function ProviderDashboard() {
  const { user } = useAuth();
  const navigate = useNavigate();
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [services, setServices] = useState([]);
  const [showAddService, setShowAddService] = useState(false);
  const [newService, setNewService] = useState({ name: '', description: '', price: '', duration_minutes: '' });
  const [addingService, setAddingService] = useState(false);

  useEffect(() => {
    fetchDashboard();
  }, []);

  const fetchDashboard = async () => {
    try {
      const dash = await api.get('/providers/my/dashboard');
      setData(dash);
      const svc = await api.get(`/providers/${dash.provider.id}`);
      setServices(svc.provider?.services || []);
    } catch (err) {
      if (err.message?.includes('not found') || err.message?.includes('profile')) {
        navigate('/add-store');
      }
    } finally { setLoading(false); }
  };

  const updateBookingStatus = async (id, status) => {
    try {
      await api.put(`/bookings/${id}/status`, { status });
      toast.success(`Booking ${status}`);
      fetchDashboard();
    } catch (err) { toast.error(err.message); }
  };

  const addService = async () => {
    if (!newService.name) return toast.error('Service name required');
    setAddingService(true);
    try {
      await api.post(`/providers/${data.provider.id}/services`, newService);
      toast.success('Service added!');
      setShowAddService(false);
      setNewService({ name: '', description: '', price: '', duration_minutes: '' });
      fetchDashboard();
    } catch (err) { toast.error(err.message); } finally { setAddingService(false); }
  };

  if (loading) return <div style={{ padding: 16 }}><div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>{[1,2,3].map(i => <div key={i} className="skeleton" style={{ height: 80, borderRadius: 16 }} />)}</div></div>;

  if (!data) return (
    <div style={{ padding: 24, textAlign: 'center' }}>
      <p style={{ color: '#888', marginBottom: 16 }}>No store found</p>
      <button className="btn-primary" onClick={() => navigate('/add-store')}>Create Store</button>
    </div>
  );

  const { provider, stats, recent_bookings } = data;

  return (
    <div style={{ paddingBottom: 80 }}>
      <div className="topbar" style={{ justifyContent: 'space-between' }}>
        <div>
          <h2 style={{ fontWeight: 700, fontSize: 17 }}>{provider.shop_name}</h2>
          <p style={{ color: '#888', fontSize: 12 }}>{provider.status}</p>
        </div>
        <button onClick={() => navigate('/add-store')} style={{ background: '#111', border: '1px solid #222', borderRadius: 10, width: 36, height: 36, display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer' }}>
          <Edit size={15} color="#888" />
        </button>
      </div>

      <div style={{ padding: 16 }}>
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10, marginBottom: 16 }}>
          {[
            { label: 'Today', value: `₹${parseFloat(stats.today || 0).toFixed(0)}`, icon: TrendingUp, color: '#00FF88' },
            { label: 'Total Views', value: stats.views || 0, icon: Eye, color: '#00BBFF' },
            { label: 'Rating', value: `${parseFloat(stats.rating || 0).toFixed(1)} ⭐`, icon: Star, color: '#FFD700' },
            { label: 'Bookings', value: stats.total || 0, icon: Package, color: '#FF8800' },
          ].map(({ label, value, icon: Icon, color }) => (
            <div key={label} className="card">
              <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 8 }}>
                <Icon size={16} color={color} />
                <span style={{ color: '#888', fontSize: 12 }}>{label}</span>
              </div>
              <p style={{ fontWeight: 800, fontSize: 20, color }}>{value}</p>
            </div>
          ))}
        </div>

        <div style={{ marginBottom: 16 }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 12 }}>
            <h3 style={{ fontWeight: 700, fontSize: 16 }}>Services</h3>
            <button onClick={() => setShowAddService(true)} style={{ display: 'flex', alignItems: 'center', gap: 5, color: '#00FF88', background: 'rgba(0,255,136,0.1)', border: '1px solid rgba(0,255,136,0.2)', borderRadius: 8, padding: '6px 10px', cursor: 'pointer', fontSize: 13, fontWeight: 600 }}>
              <Plus size={14} /> Add
            </button>
          </div>
          {services.length === 0 ? (
            <div className="card" style={{ textAlign: 'center', padding: '24px', color: '#888' }}>
              <p style={{ marginBottom: 10 }}>No services added yet</p>
              <button className="btn-primary btn-sm" style={{ width: 'auto', margin: '0 auto' }} onClick={() => setShowAddService(true)}>Add First Service</button>
            </div>
          ) : (
            <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
              {services.map(s => (
                <div key={s.id} className="card" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                  <div>
                    <p style={{ fontWeight: 600, fontSize: 14 }}>{s.name}</p>
                    {s.duration_minutes && <p style={{ color: '#888', fontSize: 12 }}>{s.duration_minutes} min</p>}
                  </div>
                  {s.price ? <span style={{ color: '#00FF88', fontWeight: 700 }}>₹{parseFloat(s.price).toFixed(0)}</span> : <span style={{ color: '#888', fontSize: 13 }}>Negotiable</span>}
                </div>
              ))}
            </div>
          )}
        </div>

        {recent_bookings?.length > 0 && (
          <div>
            <h3 style={{ fontWeight: 700, fontSize: 16, marginBottom: 12 }}>Recent Orders</h3>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
              {recent_bookings.map(b => (
                <div key={b.id} className="card">
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 8 }}>
                    <div>
                      <p style={{ fontWeight: 600, fontSize: 14 }}>{b.user_name}</p>
                      <p style={{ color: '#888', fontSize: 12 }}>{b.user_phone} • {b.service_name || 'General'}</p>
                    </div>
                    <span style={{ color: STATUS_COLORS[b.status] || '#888', fontSize: 12, fontWeight: 600, flexShrink: 0 }}>
                      {b.status?.replace('_',' ').toUpperCase()}
                    </span>
                  </div>
                  {b.status === 'pending' && (
                    <div style={{ display: 'flex', gap: 8, marginTop: 8 }}>
                      <button className="btn-primary btn-sm" style={{ flex: 1 }} onClick={() => updateBookingStatus(b.id, 'accepted')}>Accept</button>
                      <button className="btn-secondary btn-sm" style={{ flex: 1, color: '#FF4444', borderColor: '#FF444433' }} onClick={() => updateBookingStatus(b.id, 'rejected')}>Reject</button>
                    </div>
                  )}
                  {b.status === 'accepted' && (
                    <button className="btn-primary btn-sm" style={{ marginTop: 8, width: '100%' }} onClick={() => updateBookingStatus(b.id, 'completed')}>Mark Complete</button>
                  )}
                </div>
              ))}
            </div>
          </div>
        )}
      </div>

      {showAddService && (
        <div className="modal-overlay" onClick={e => e.target === e.currentTarget && setShowAddService(false)}>
          <div className="modal-sheet">
            <h3 style={{ fontWeight: 700, fontSize: 18, marginBottom: 16 }}>Add Service</h3>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
              <input className="input-field" placeholder="Service name *" value={newService.name} onChange={e => setNewService(s => ({ ...s, name: e.target.value }))} />
              <textarea className="input-field" placeholder="Description" value={newService.description} onChange={e => setNewService(s => ({ ...s, description: e.target.value }))} rows={2} style={{ resize: 'none' }} />
              <input className="input-field" type="number" placeholder="Price (₹)" value={newService.price} onChange={e => setNewService(s => ({ ...s, price: e.target.value }))} />
              <input className="input-field" type="number" placeholder="Duration (minutes)" value={newService.duration_minutes} onChange={e => setNewService(s => ({ ...s, duration_minutes: e.target.value }))} />
              <button className="btn-primary" onClick={addService} disabled={addingService}>{addingService ? 'Adding...' : 'Add Service'}</button>
              <button className="btn-secondary" onClick={() => setShowAddService(false)}>Cancel</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
