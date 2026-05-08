import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { ArrowLeft, Star, MapPin, Phone, MessageCircle, Lock, CheckCircle } from 'lucide-react';
import { useAuth } from '../context/AuthContext';
import api from '../utils/api';
import toast from 'react-hot-toast';

export default function ProviderDetail() {
  const { id } = useParams();
  const navigate = useNavigate();
  const { user, refreshUser } = useAuth();
  const [provider, setProvider] = useState(null);
  const [loading, setLoading] = useState(true);
  const [viewData, setViewData] = useState(null);
  const [viewError, setViewError] = useState(null);
  const [showBooking, setShowBooking] = useState(false);
  const [selectedService, setSelectedService] = useState(null);
  const [booking, setBooking] = useState({ address: '', scheduled_at: '', notes: '' });
  const [bookingLoading, setBookingLoading] = useState(false);

  useEffect(() => {
    fetchProvider();
    trackView();
  }, [id]);

  const fetchProvider = async () => {
    try {
      const data = await api.get(`/providers/${id}`);
      setProvider(data.provider);
    } catch {} finally { setLoading(false); }
  };

  const trackView = async () => {
    try {
      const data = await api.post(`/providers/${id}/view`);
      setViewData(data);
      if (data.remaining_free_views !== undefined && data.remaining_free_views >= 0) {
        if (data.remaining_free_views === 0) toast('Last free view used!', { icon: '⚠️' });
      }
    } catch (err) {
      if (err.requires_subscription) {
        setViewError(err);
      }
    }
  };

  const submitBooking = async () => {
    if (!booking.address) return toast.error('Enter your address');
    setBookingLoading(true);
    try {
      await api.post('/bookings', { provider_id: parseInt(id), service_id: selectedService?.id, address: booking.address, scheduled_at: booking.scheduled_at || null, notes: booking.notes, price: selectedService?.price });
      toast.success('Booking confirmed!');
      setShowBooking(false);
    } catch (err) { toast.error(err.message); } finally { setBookingLoading(false); }
  };

  if (loading) return <div style={{ padding: 16 }}><div className="skeleton" style={{ height: 200, borderRadius: 16 }} /></div>;

  if (viewError) return (
    <div style={{ minHeight: '100vh', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: 24, textAlign: 'center' }}>
      <div style={{ fontSize: 48, marginBottom: 16 }}>🔒</div>
      <h2 style={{ marginBottom: 8 }}>Subscription Required</h2>
      <p style={{ color: '#888', marginBottom: 8 }}>You've used all {viewError.limit} free views.</p>
      <p style={{ color: '#888', marginBottom: 24, fontSize: 13 }}>Subscribe to unlock unlimited access to all service providers.</p>
      <button className="btn-primary" onClick={() => navigate('/subscribe')}>View Plans</button>
      <button className="btn-secondary" style={{ marginTop: 10 }} onClick={() => navigate(-1)}>Go Back</button>
    </div>
  );

  if (!provider) return null;

  const contactUnlocked = viewData?.success && !viewError;

  return (
    <div style={{ paddingBottom: 80 }}>
      <div className="topbar">
        <button onClick={() => navigate(-1)} style={{ background: '#111', border: '1px solid #222', borderRadius: 10, width: 38, height: 38, display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer', flexShrink: 0 }}>
          <ArrowLeft size={18} />
        </button>
        <h2 style={{ fontWeight: 700, fontSize: 16, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{provider.shop_name}</h2>
        {provider.is_premium && <span className="badge-premium" style={{ marginLeft: 'auto', flexShrink: 0 }}>PRO</span>}
      </div>

      <div style={{ padding: 16 }}>
        <div className="card" style={{ marginBottom: 12 }}>
          <div style={{ display: 'flex', gap: 14, marginBottom: 14 }}>
            <div style={{ width: 80, height: 80, borderRadius: 16, background: '#1a1a1a', border: '1px solid #222', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 36, flexShrink: 0 }}>
              {provider.profile_image ? <img src={provider.profile_image} alt="" style={{ width: '100%', height: '100%', objectFit: 'cover', borderRadius: 16 }} /> : <span>{provider.category_icon || '🏪'}</span>}
            </div>
            <div style={{ flex: 1 }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginBottom: 4 }}>
                <h2 style={{ fontWeight: 800, fontSize: 18 }}>{provider.shop_name}</h2>
                {provider.is_verified && <CheckCircle size={16} color="#00FF88" />}
              </div>
              <p style={{ color: '#888', fontSize: 13, marginBottom: 6 }}>{provider.category_name}</p>
              <div style={{ display: 'flex', gap: 10, alignItems: 'center', flexWrap: 'wrap' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 3 }}>
                  <Star size={13} fill="#FFD700" color="#FFD700" />
                  <span style={{ fontWeight: 700 }}>{parseFloat(provider.rating || 0).toFixed(1)}</span>
                  <span style={{ color: '#888', fontSize: 12 }}>({provider.review_count || 0} reviews)</span>
                </div>
                <span style={{ color: provider.is_online ? '#00FF88' : '#888', fontSize: 12 }}>● {provider.is_online ? 'Open Now' : 'Closed'}</span>
              </div>
            </div>
          </div>

          {provider.description && <p style={{ color: '#ccc', fontSize: 14, lineHeight: 1.6, marginBottom: 12 }}>{provider.description}</p>}

          <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginBottom: provider.city ? 8 : 0 }}>
            <MapPin size={13} color="#00FF88" />
            <span style={{ color: '#888', fontSize: 13 }}>{provider.address}</span>
          </div>

          <div style={{ borderTop: '1px solid #222', marginTop: 14, paddingTop: 14 }}>
            <p style={{ color: '#888', fontSize: 12, marginBottom: 10 }}>Contact</p>
            {contactUnlocked ? (
              <div style={{ display: 'flex', gap: 10 }}>
                <a href={`tel:${provider.phone}`} style={{ flex: 1 }}>
                  <button className="btn-secondary btn-sm" style={{ width: '100%', gap: 6 }}><Phone size={15} color="#00FF88" />Call</button>
                </a>
                {provider.whatsapp && (
                  <a href={`https://wa.me/${provider.whatsapp?.replace(/\D/g, '')}`} target="_blank" rel="noreferrer" style={{ flex: 1 }}>
                    <button className="btn-secondary btn-sm" style={{ width: '100%', gap: 6 }}><MessageCircle size={15} color="#25D366" />WhatsApp</button>
                  </a>
                )}
              </div>
            ) : (
              <div className="lock-overlay">
                <Lock size={16} color="#888" />
                <span>XXXXXXX</span>
                <span style={{ marginLeft: 'auto', color: '#555', fontSize: 11 }}>Subscribe to unlock</span>
              </div>
            )}
          </div>
        </div>

        {provider.services?.length > 0 && (
          <div style={{ marginBottom: 12 }}>
            <h3 className="section-title">Services</h3>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
              {provider.services.map(s => (
                <div key={s.id} className="card" style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                  <div>
                    <p style={{ fontWeight: 600, fontSize: 14 }}>{s.name}</p>
                    {s.description && <p style={{ color: '#888', fontSize: 12, marginTop: 2 }}>{s.description}</p>}
                    {s.duration_minutes && <p style={{ color: '#555', fontSize: 11, marginTop: 2 }}>{s.duration_minutes} min</p>}
                  </div>
                  <div style={{ textAlign: 'right', flexShrink: 0 }}>
                    {s.price ? <p style={{ color: '#00FF88', fontWeight: 700 }}>₹{parseFloat(s.price).toFixed(0)}</p> : <p style={{ color: '#888', fontSize: 13 }}>Negotiable</p>}
                    <button className="btn-primary btn-sm" style={{ marginTop: 6, width: 'auto' }} onClick={() => { setSelectedService(s); setShowBooking(true); }}>Book</button>
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        {provider.reviews?.length > 0 && (
          <div>
            <h3 className="section-title">Reviews</h3>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
              {provider.reviews.map(r => (
                <div key={r.id} className="card">
                  <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 6 }}>
                    <span style={{ fontWeight: 600, fontSize: 14 }}>{r.user_name}</span>
                    <div style={{ display: 'flex', gap: 2 }}>{[1,2,3,4,5].map(i => <Star key={i} size={12} fill={i <= r.rating ? '#FFD700' : 'none'} color={i <= r.rating ? '#FFD700' : '#444'} />)}</div>
                  </div>
                  {r.comment && <p style={{ color: '#ccc', fontSize: 13 }}>{r.comment}</p>}
                </div>
              ))}
            </div>
          </div>
        )}

        <button className="btn-primary" style={{ marginTop: 16 }} onClick={() => setShowBooking(true)}>Book Service</button>
      </div>

      {showBooking && (
        <div className="modal-overlay" onClick={e => e.target === e.currentTarget && setShowBooking(false)}>
          <div className="modal-sheet">
            <h3 style={{ fontWeight: 700, fontSize: 18, marginBottom: 16 }}>Book Service</h3>
            {provider.services?.length > 0 && (
              <div style={{ marginBottom: 14 }}>
                <label style={{ color: '#888', fontSize: 12, marginBottom: 8, display: 'block' }}>Select Service</label>
                <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
                  {provider.services.map(s => (
                    <button key={s.id} onClick={() => setSelectedService(s)} style={{ display: 'flex', justifyContent: 'space-between', padding: '10px 12px', borderRadius: 10, background: selectedService?.id === s.id ? 'rgba(0,255,136,0.1)' : '#1a1a1a', border: `1px solid ${selectedService?.id === s.id ? '#00FF88' : '#222'}`, cursor: 'pointer', color: '#fff' }}>
                      <span style={{ fontSize: 14 }}>{s.name}</span>
                      {s.price && <span style={{ color: '#00FF88', fontWeight: 600 }}>₹{parseFloat(s.price).toFixed(0)}</span>}
                    </button>
                  ))}
                </div>
              </div>
            )}
            <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
              <input className="input-field" placeholder="Your address" value={booking.address} onChange={e => setBooking(b => ({ ...b, address: e.target.value }))} />
              <input className="input-field" type="datetime-local" value={booking.scheduled_at} onChange={e => setBooking(b => ({ ...b, scheduled_at: e.target.value }))} style={{ colorScheme: 'dark' }} />
              <textarea className="input-field" placeholder="Additional notes (optional)" value={booking.notes} onChange={e => setBooking(b => ({ ...b, notes: e.target.value }))} rows={3} style={{ resize: 'none' }} />
              <button className="btn-primary" onClick={submitBooking} disabled={bookingLoading}>{bookingLoading ? 'Booking...' : 'Confirm Booking'}</button>
              <button className="btn-secondary" onClick={() => setShowBooking(false)}>Cancel</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
