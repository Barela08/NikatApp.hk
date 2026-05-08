import React from 'react';
import { useNavigate } from 'react-router-dom';
import { Star, MapPin } from 'lucide-react';

export default function ProviderCard({ provider }) {
  const navigate = useNavigate();
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
            <h4 style={{ fontWeight: 700, fontSize: 15, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>{provider.shop_name}</h4>
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
      </div>
    </div>
  );
}
