import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { Heart, Star, MapPin } from 'lucide-react';
import api from '../utils/api';
import toast from 'react-hot-toast';

export default function Favorites() {
  const [favorites, setFavorites] = useState([]);
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();

  useEffect(() => {
    api.get('/favorites').then(d => { setFavorites(d.favorites || []); setLoading(false); }).catch(() => setLoading(false));
  }, []);

  const removeFavorite = async (e, providerId) => {
    e.stopPropagation();
    try {
      await api.delete(`/favorites/${providerId}`);
      setFavorites(f => f.filter(x => x.provider_id !== providerId));
      toast.success('Removed from saved');
    } catch { toast.error('Failed to remove'); }
  };

  return (
    <div style={{ paddingBottom: 80 }}>
      <div className="topbar">
        <h2 style={{ fontWeight: 700, fontSize: 18 }}>Saved Shops</h2>
        <span style={{ marginLeft: 'auto', color: '#888', fontSize: 13 }}>{favorites.length} saved</span>
      </div>
      <div style={{ padding: 16 }}>
        {loading ? (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
            {[1,2,3].map(i => <div key={i} className="skeleton" style={{ height: 90, borderRadius: 16 }} />)}
          </div>
        ) : favorites.length === 0 ? (
          <div style={{ textAlign: 'center', padding: '60px 20px' }}>
            <div style={{ width: 80, height: 80, borderRadius: '50%', background: '#1a1a1a', border: '1px solid #222', display: 'flex', alignItems: 'center', justifyContent: 'center', margin: '0 auto 16px' }}>
              <Heart size={34} color="#333" />
            </div>
            <p style={{ fontWeight: 700, fontSize: 17, marginBottom: 8 }}>No saved shops yet</p>
            <p style={{ color: '#888', fontSize: 14, marginBottom: 24 }}>Tap the heart icon on any shop to save it here</p>
            <button className="btn-primary" onClick={() => navigate('/')}>Browse Shops</button>
          </div>
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
            {favorites.map(p => (
              <div key={p.id} className="card fade-in" style={{ cursor: 'pointer', transition: 'transform 100ms' }}
                onClick={() => navigate(`/provider/${p.provider_id}`)}
                onMouseDown={e => e.currentTarget.style.transform = 'scale(0.98)'}
                onMouseUp={e => e.currentTarget.style.transform = 'scale(1)'}>
                <div style={{ display: 'flex', gap: 12 }}>
                  <div style={{ width: 64, height: 64, borderRadius: 14, background: '#1a1a1a', border: '1px solid #222', flexShrink: 0, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 28, overflow: 'hidden' }}>
                    {p.profile_image ? <img src={p.profile_image} alt="" style={{ width: '100%', height: '100%', objectFit: 'cover' }} /> : <span>{p.category_icon || '🏪'}</span>}
                  </div>
                  <div style={{ flex: 1, minWidth: 0 }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginBottom: 3 }}>
                      <h4 style={{ fontWeight: 700, fontSize: 15, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{p.shop_name}</h4>
                      {p.is_premium && <span className="badge-premium">PRO</span>}
                    </div>
                    <p style={{ color: '#888', fontSize: 12, marginBottom: 6 }}>{p.category_name}</p>
                    <div style={{ display: 'flex', gap: 12, alignItems: 'center' }}>
                      <div style={{ display: 'flex', alignItems: 'center', gap: 3 }}>
                        <Star size={12} fill="#FFD700" color="#FFD700" />
                        <span style={{ fontSize: 12, fontWeight: 600 }}>{parseFloat(p.rating || 0).toFixed(1)}</span>
                      </div>
                      {p.city && (
                        <div style={{ display: 'flex', alignItems: 'center', gap: 3 }}>
                          <MapPin size={12} color="#00FF88" />
                          <span style={{ fontSize: 12, color: '#888' }}>{p.city}</span>
                        </div>
                      )}
                      <span style={{ fontSize: 11, color: p.is_online ? '#00FF88' : '#555', marginLeft: 'auto' }}>● {p.is_online ? 'Open' : 'Closed'}</span>
                    </div>
                  </div>
                  <button onClick={e => removeFavorite(e, p.provider_id)} style={{ background: 'rgba(255,68,68,0.1)', border: '1px solid rgba(255,68,68,0.3)', borderRadius: 10, width: 36, height: 36, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0, cursor: 'pointer', alignSelf: 'center' }}>
                    <Heart size={16} fill="#FF4444" color="#FF4444" />
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
