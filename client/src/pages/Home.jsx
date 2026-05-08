import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { MapPin, Search, RefreshCw, Navigation } from 'lucide-react';
import { useAuth } from '../context/AuthContext';
import { useLocation } from '../context/LocationContext';
import { useLanguage } from '../context/LanguageContext';
import api from '../utils/api';
import ProviderCard from '../components/ProviderCard';

export default function Home() {
  const { user } = useAuth();
  const { location, locationLoading, detectLocation } = useLocation();
  const { t } = useLanguage();
  const [categories, setCategories] = useState([]);
  const [providers, setProviders] = useState([]);
  const [loading, setLoading] = useState(true);
  const [selectedCategory, setSelectedCategory] = useState(null);
  const navigate = useNavigate();

  useEffect(() => {
    api.get('/categories').then(d => setCategories(d.categories || []));
  }, []);

  useEffect(() => {
    if (location) fetchProviders();
  }, [location, selectedCategory]);

  const fetchProviders = async () => {
    setLoading(true);
    try {
      const params = new URLSearchParams({ lat: location.latitude, lng: location.longitude, radius: 15, limit: 20 });
      if (selectedCategory) params.append('category', selectedCategory);
      const data = await api.get(`/providers/nearby?${params}`);
      setProviders(data.providers || []);
    } catch {} finally { setLoading(false); }
  };

  const hour = new Date().getHours();
  const greeting = hour < 12 ? t('greeting_morning') : hour < 17 ? t('greeting_afternoon') : t('greeting_evening');

  return (
    <div style={{ paddingBottom: 80 }}>
      <div className="topbar" style={{ flexDirection: 'column', alignItems: 'flex-start', gap: 10, padding: '14px 16px' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', width: '100%', alignItems: 'center' }}>
          <div>
            <p style={{ color: '#888', fontSize: 12 }}>{greeting},</p>
            <h2 style={{ fontSize: 18, fontWeight: 700 }}>{user?.name?.split(' ')[0]} 👋</h2>
          </div>
          <div style={{ width: 40, height: 40, borderRadius: 12, background: '#111', border: '1px solid #222', display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer' }} onClick={() => navigate('/profile')}>
            <span style={{ fontSize: 18 }}>👤</span>
          </div>
        </div>
        <button onClick={() => locationLoading ? null : detectLocation()} style={{ display: 'flex', alignItems: 'center', gap: 6, background: '#111', border: '1px solid #222', borderRadius: 10, padding: '7px 12px', cursor: 'pointer', transition: '150ms', width: '100%' }}>
          {locationLoading ? <RefreshCw size={14} color="#00FF88" style={{ animation: 'spin 1s linear infinite' }} /> : <MapPin size={14} color="#00FF88" />}
          <span style={{ color: '#ccc', fontSize: 13, flex: 1, textAlign: 'left', overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' }}>
            {locationLoading ? 'Detecting location...' : location?.city || location?.address?.split(',')[0] || 'Tap to detect location'}
          </span>
          <Navigation size={12} color="#00FF88" />
        </button>
        <style>{`@keyframes spin{from{transform:rotate(0deg)}to{transform:rotate(360deg)}}`}</style>
      </div>

      <div style={{ padding: '14px 16px 0' }}>
        <button onClick={() => navigate('/search')} style={{ display: 'flex', alignItems: 'center', gap: 10, background: '#111', border: '1px solid #222', borderRadius: 14, padding: '13px 16px', width: '100%', cursor: 'pointer' }}>
          <Search size={18} color="#888" />
          <span style={{ color: '#555', fontSize: 15 }}>{t('searchPlaceholder')}</span>
        </button>
      </div>

      {categories.length > 0 && (
        <div style={{ padding: '18px 0 0' }}>
          <div style={{ padding: '0 16px', marginBottom: 12, display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <h3 style={{ fontWeight: 700, fontSize: 16 }}>{t('categories')}</h3>
            <button onClick={() => setSelectedCategory(null)} style={{ color: selectedCategory ? '#888' : '#00FF88', fontSize: 13, background: 'none', border: 'none', cursor: 'pointer' }}>{t('allCategories')}</button>
          </div>
          <div style={{ display: 'flex', gap: 10, overflowX: 'auto', padding: '0 16px', paddingBottom: 4, scrollbarWidth: 'none' }}>
            {categories.map(cat => (
              <button key={cat.id} onClick={() => setSelectedCategory(selectedCategory === cat.id ? null : cat.id)} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 6, minWidth: 70, padding: '10px 8px', borderRadius: 14, background: selectedCategory === cat.id ? 'rgba(0,255,136,0.1)' : '#111', border: `1px solid ${selectedCategory === cat.id ? '#00FF88' : '#222'}`, cursor: 'pointer', transition: '150ms', flexShrink: 0 }}>
                <span style={{ fontSize: 24 }}>{cat.icon}</span>
                <span style={{ fontSize: 10, color: selectedCategory === cat.id ? '#00FF88' : '#888', textAlign: 'center', lineHeight: 1.2 }}>{cat.name}</span>
              </button>
            ))}
          </div>
        </div>
      )}

      <div style={{ padding: '18px 16px 0' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 12 }}>
          <h3 style={{ fontWeight: 700, fontSize: 16 }}>{t('nearbyServices')}</h3>
          {!loading && <span style={{ color: '#888', fontSize: 12 }}>{providers.length} found</span>}
        </div>
        {!location && !locationLoading && (
          <div style={{ textAlign: 'center', padding: '32px 20px', background: '#111', borderRadius: 16, border: '1px solid #222' }}>
            <div style={{ fontSize: 40, marginBottom: 12 }}>📍</div>
            <p style={{ fontWeight: 600, marginBottom: 6 }}>Enable Location</p>
            <p style={{ fontSize: 13, color: '#888', marginBottom: 16 }}>Allow location access to see services near you</p>
            <button className="btn-primary" onClick={detectLocation}>Detect My Location</button>
          </div>
        )}
        {locationLoading && (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
            {[1,2,3].map(i => <div key={i} className="skeleton" style={{ height: 90, borderRadius: 16 }} />)}
          </div>
        )}
        {location && loading && (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
            {[1,2,3].map(i => <div key={i} className="skeleton" style={{ height: 90, borderRadius: 16 }} />)}
          </div>
        )}
        {location && !loading && providers.length === 0 && (
          <div style={{ textAlign: 'center', padding: '40px 20px', color: '#888' }}>
            <div style={{ fontSize: 48, marginBottom: 12 }}>🔍</div>
            <p style={{ fontWeight: 600, marginBottom: 6 }}>{t('noShopsNearby')}</p>
            <p style={{ fontSize: 13 }}>Try expanding the search area or change category</p>
          </div>
        )}
        {location && !loading && providers.length > 0 && (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
            {providers.map(p => <ProviderCard key={p.id} provider={p} />)}
          </div>
        )}
      </div>
    </div>
  );
}
