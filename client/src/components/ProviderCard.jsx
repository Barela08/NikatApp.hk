import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Star, MapPin, Heart } from 'lucide-react';
import api from '../utils/api';
import toast from 'react-hot-toast';

export default function ProviderCard({ provider, initialFavorited = false }) {
  const navigate = useNavigate();
  const [favorited, setFavorited] = useState(initialFavorited);
  const [favLoading, setFavLoading] = useState(false);

  const toggleFavorite = async (e) => {
    e.stopPropagation();
    if (favLoading) return;
    setFavLoading(true);
    try {
      if (favorited) {
        await api.delete(`/favorites/${provider.id}`);
        setFavorited(false);
        toast('Removed from saved', { icon: '🗑️' });
      } else {
        await api.post(`/favorites/${provider.id}`);
        setFavorited(true);
        toast.success('Saved to favorites');
      }
    } catch { toast.error('Sign in to save shops'); }
    finally { setFavLoading(false); }
  };

  return (
    <div className="card fade-in" style={{ cursor: 'pointer', transition: 'transform 100ms' }}
      onClick={() => navigate(`/provider/${provider.id}`)}
      onMouseDown={e => e.currentTarget.style.transform = 'scale(0.98)'}
      onMouseUp={e => e.currentTarget.style.transform = 'scale(1)'}
      onTouchStart={e => e.currentTarget.style.transform = 'scale(0.98)'}
      onTouchEnd={e => e.currentTarget.style.transform = 'scale(1)'}>
      <div style={{ display: 'flex', gap: 12 }}>
        <div style={{ width: 64, height: 64, borderRadius: 14, background: '#1a1a1a', border: '1px solid #222', flexShrink: 0, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 28, overflow: 'hidden' }}>
          {provider.profile_image ? <img src={provider.profile_image} alt="" style={{ width: '100%', height: '100%', objectFit: 'cover' }} /> : <span>{provider.category_icon || '🏪'}</span>}
        </div>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 6, marginBottom: 3 }}>
            <h4 style={{ fontWeight: 700, fontSize: 15, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap', flex: 1 }}>{provider.shop_name}</h4>
            {provider.is_premium && <span className="badge-premium">PRO</span>}
            {provider.is_verified && <span className="badge-verified">✓</span>}
          </div>
          <p style={{ color: '#888', fontSize: 12, marginBottom: 6 }}>{provider.category_name}</p>
          <div style={{ display: 'flex', gap: 12, alignItems: 'center' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 3 }}>
              <Star size={12} fill="#FFD700" color="#FFD700" />
              <span style={{ fontSize: 12, fontWeight: 600 }}>{parseFloat(provider.rating || 0).toFixed(1)}</span>
              <span style={{ fontSize: 11, color: '#888' }}>({provider.review_count || 0})</span>
            </div>
            <div style={{ display: 'flex', alignItems: 'center', gap: 3 }}>
              <MapPin size={12} color="#00FF88" />
              <span style={{ fontSize: 12, color: '#888' }}>{provider.distance ? `${parseFloat(provider.distance).toFixed(1)} km` : 'Nearby'}</span>
            </div>
            <div style={{ marginLeft: 'auto' }}>
              <span style={{ fontSize: 11, color: provider.is_online ? '#00FF88' : '#888' }}>● {provider.is_online ? 'Open' : 'Closed'}</span>
            </div>
          </div>
        </div>
        <button onClick={toggleFavorite} style={{ background: favorited ? 'rgba(255,68,68,0.1)' : 'transparent', border: `1px solid ${favorited ? 'rgba(255,68,68,0.3)' : '#222'}`, borderRadius: 10, width: 34, height: 34, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0, cursor: 'pointer', alignSelf: 'flex-start', marginTop: 2, transition: '150ms' }}>
          <Heart size={15} fill={favorited ? '#FF4444' : 'none'} color={favorited ? '#FF4444' : '#555'} />
        </button>
      </div>
    </div>
  );
}
