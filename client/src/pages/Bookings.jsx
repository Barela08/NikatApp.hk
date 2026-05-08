import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { ArrowLeft, Clock, CheckCircle, XCircle, Truck, Package, AlertCircle } from 'lucide-react';
import api from '../utils/api';
import toast from 'react-hot-toast';

const ORDER_TIMELINE = [
  { key: 'pending',    label: 'Placed',     icon: Package,       color: '#FFD700' },
  { key: 'accepted',   label: 'Confirmed',  icon: CheckCircle,   color: '#00FF88' },
  { key: 'on_the_way', label: 'On the Way', icon: Truck,         color: '#00BBFF' },
  { key: 'in_progress',label: 'In Progress',icon: Clock,         color: '#FF8800' },
  { key: 'completed',  label: 'Done',       icon: CheckCircle,   color: '#00FF88' },
];

const STATUS_CONFIG = {
  pending:     { color: '#FFD700', icon: Package,       label: 'Placed' },
  accepted:    { color: '#00FF88', icon: CheckCircle,   label: 'Confirmed' },
  rejected:    { color: '#FF4444', icon: XCircle,       label: 'Rejected' },
  on_the_way:  { color: '#00BBFF', icon: Truck,         label: 'On the Way' },
  in_progress: { color: '#FF8800', icon: Clock,         label: 'In Progress' },
  completed:   { color: '#00FF88', icon: CheckCircle,   label: 'Completed' },
  cancelled:   { color: '#888',    icon: XCircle,       label: 'Cancelled' },
};

function StatusTimeline({ status }) {
  if (['rejected', 'cancelled'].includes(status)) return null;

  const activeIndex = ORDER_TIMELINE.findIndex(s => s.key === status);
  const effectiveIndex = activeIndex === -1 ? 0 : activeIndex;

  return (
    <div style={{ marginTop: 14, paddingTop: 14, borderTop: '1px solid #1a1a1a' }}>
      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', position: 'relative' }}>
        <div style={{ position: 'absolute', top: 14, left: '10%', right: '10%', height: 2, background: '#222', zIndex: 0 }} />
        <div style={{ position: 'absolute', top: 14, left: '10%', width: `${Math.min(effectiveIndex / (ORDER_TIMELINE.length - 1), 1) * 80}%`, height: 2, background: '#00FF88', zIndex: 1, transition: 'width 600ms ease' }} />
        {ORDER_TIMELINE.map((step, i) => {
          const done = i <= effectiveIndex;
          const active = i === effectiveIndex;
          const Icon = step.icon;
          return (
            <div key={step.key} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 6, zIndex: 2, flex: 1 }}>
              <div style={{ width: 28, height: 28, borderRadius: '50%', background: done ? step.color : '#1a1a1a', border: `2px solid ${done ? step.color : '#333'}`, display: 'flex', alignItems: 'center', justifyContent: 'center', transition: '300ms', boxShadow: active ? `0 0 10px ${step.color}66` : 'none' }}>
                <Icon size={13} color={done ? '#000' : '#444'} />
              </div>
              <span style={{ fontSize: 9, color: done ? step.color : '#555', fontWeight: done ? 700 : 400, textAlign: 'center', lineHeight: 1.2, maxWidth: 44 }}>{step.label}</span>
            </div>
          );
        })}
      </div>
    </div>
  );
}

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
        <span style={{ marginLeft: 'auto', color: '#888', fontSize: 12 }}>{bookings.length} total</span>
      </div>
      <div style={{ display: 'flex', padding: '12px 16px', gap: 8, borderBottom: '1px solid #222' }}>
        {['active','completed','cancelled'].map(t => (
          <button key={t} onClick={() => setTab(t)} style={{ padding: '7px 16px', borderRadius: 10, background: tab === t ? 'rgba(0,255,136,0.1)' : '#111', border: `1px solid ${tab === t ? '#00FF88' : '#222'}`, color: tab === t ? '#00FF88' : '#888', fontSize: 13, fontWeight: 600, cursor: 'pointer', textTransform: 'capitalize' }}>{t}</button>
        ))}
      </div>
      <div style={{ padding: 16 }}>
        {loading ? (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
            {[1,2,3].map(i => <div key={i} className="skeleton" style={{ height: 140, borderRadius: 16 }} />)}
          </div>
        ) : filtered.length === 0 ? (
          <div style={{ textAlign: 'center', padding: '60px 20px', color: '#888' }}>
            <div style={{ fontSize: 48, marginBottom: 12 }}>📋</div>
            <p style={{ fontWeight: 600, marginBottom: 6 }}>No {tab} bookings</p>
            <p style={{ fontSize: 13 }}>Your bookings will appear here</p>
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
                  <div style={{ display: 'flex', gap: 16, color: '#888', fontSize: 12, flexWrap: 'wrap' }}>
                    {b.price && <span style={{ color: '#00FF88', fontWeight: 600 }}>₹{parseFloat(b.price).toFixed(0)}</span>}
                    {b.scheduled_at && <span>📅 {new Date(b.scheduled_at).toLocaleDateString()}</span>}
                    <span style={{ color: '#444' }}>#{b.id}</span>
                    <span style={{ marginLeft: 'auto' }}>{new Date(b.created_at).toLocaleDateString()}</span>
                  </div>
                  {b.address && <p style={{ color: '#555', fontSize: 12, marginTop: 8 }}>📍 {b.address}</p>}
                  <StatusTimeline status={b.status} />
                </div>
              );
            })}
          </div>
        )}
      </div>
    </div>
  );
}
