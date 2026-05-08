import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { ArrowLeft, Clock, CheckCircle, XCircle, Truck } from 'lucide-react';
import api from '../utils/api';
import toast from 'react-hot-toast';

const STATUS_CONFIG = {
  pending: { color: '#FFD700', icon: Clock, label: 'Pending' },
  accepted: { color: '#00FF88', icon: CheckCircle, label: 'Accepted' },
  rejected: { color: '#FF4444', icon: XCircle, label: 'Rejected' },
  on_the_way: { color: '#00BBFF', icon: Truck, label: 'On the Way' },
  in_progress: { color: '#FF8800', icon: Clock, label: 'In Progress' },
  completed: { color: '#00FF88', icon: CheckCircle, label: 'Completed' },
  cancelled: { color: '#888', icon: XCircle, label: 'Cancelled' },
};

export default function Bookings() {
  const [bookings, setBookings] = useState([]);
  const [loading, setLoading] = useState(true);
  const [tab, setTab] = useState('active');
  const navigate = useNavigate();

  useEffect(() => {
    api.get('/bookings/my').then(d => { setBookings(d.bookings || []); setLoading(false); }).catch(() => setLoading(false));
  }, []);

  const filtered = bookings.filter(b => {
    if (tab === 'active') return ['pending','accepted','on_the_way','in_progress'].includes(b.status);
    if (tab === 'completed') return b.status === 'completed';
    return ['rejected','cancelled'].includes(b.status);
  });

  return (
    <div style={{ paddingBottom: 80 }}>
      <div className="topbar">
        <h2 style={{ fontWeight: 700, fontSize: 18 }}>My Bookings</h2>
      </div>
      <div style={{ display: 'flex', padding: '12px 16px', gap: 8, borderBottom: '1px solid #222' }}>
        {['active','completed','cancelled'].map(t => (
          <button key={t} onClick={() => setTab(t)} style={{ padding: '7px 16px', borderRadius: 10, background: tab === t ? 'rgba(0,255,136,0.1)' : '#111', border: `1px solid ${tab === t ? '#00FF88' : '#222'}`, color: tab === t ? '#00FF88' : '#888', fontSize: 13, fontWeight: 600, cursor: 'pointer', textTransform: 'capitalize' }}>{t}</button>
        ))}
      </div>
      <div style={{ padding: 16 }}>
        {loading ? (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
            {[1,2,3].map(i => <div key={i} className="skeleton" style={{ height: 100, borderRadius: 16 }} />)}
          </div>
        ) : filtered.length === 0 ? (
          <div style={{ textAlign: 'center', padding: '60px 20px', color: '#888' }}>
            <div style={{ fontSize: 48, marginBottom: 12 }}>📋</div>
            <p style={{ fontWeight: 600 }}>No {tab} bookings</p>
          </div>
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
            {filtered.map(b => {
              const cfg = STATUS_CONFIG[b.status] || STATUS_CONFIG.pending;
              const Icon = cfg.icon;
              return (
                <div key={b.id} className="card fade-in" style={{ cursor: 'pointer' }} onClick={() => navigate(`/provider/${b.provider_id}`)}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 10 }}>
                    <div>
                      <p style={{ fontWeight: 700, fontSize: 15 }}>{b.shop_name}</p>
                      {b.service_name && <p style={{ color: '#888', fontSize: 13, marginTop: 2 }}>{b.service_name}</p>}
                    </div>
                    <span style={{ display: 'flex', alignItems: 'center', gap: 4, background: `${cfg.color}22`, border: `1px solid ${cfg.color}66`, borderRadius: 8, padding: '4px 8px', color: cfg.color, fontSize: 11, fontWeight: 600, flexShrink: 0 }}>
                      <Icon size={11} /> {cfg.label}
                    </span>
                  </div>
                  <div style={{ display: 'flex', gap: 16, color: '#888', fontSize: 12 }}>
                    {b.price && <span style={{ color: '#00FF88', fontWeight: 600 }}>₹{parseFloat(b.price).toFixed(0)}</span>}
                    {b.scheduled_at && <span>📅 {new Date(b.scheduled_at).toLocaleDateString()}</span>}
                    <span>#{b.id}</span>
                    <span style={{ marginLeft: 'auto' }}>{new Date(b.created_at).toLocaleDateString()}</span>
                  </div>
                  {b.address && <p style={{ color: '#555', fontSize: 12, marginTop: 8 }}>📍 {b.address}</p>}
                </div>
              );
            })}
          </div>
        )}
      </div>
    </div>
  );
}
