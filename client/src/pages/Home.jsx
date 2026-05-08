import React, { useState, useEffect, useRef } from 'react';
import { useNavigate } from 'react-router-dom';
import { MapPin, Search, RefreshCw, Navigation, ChevronLeft, ChevronRight } from 'lucide-react';
import { useAuth } from '../context/AuthContext';
import { useLocation } from '../context/LocationContext';
import { useLanguage } from '../context/LanguageContext';
import api from '../utils/api';
import ProviderCard from '../components/ProviderCard';

const BANNERS = [
  { id: 1, bg: 'linear-gradient(135deg,#00FF88,#00aa55)', title: '🎉 Welcome to NIKAT', sub: 'Discover local services near you', emoji: '🏘️' },
  { id: 2, bg: 'linear-gradient(135deg,#4A90E2,#0040aa)', title: '📍 Hyperlocal Discovery', sub: 'Find trusted shops within 15km', emoji: '🗺️' },
  { id: 3, bg: 'linear-gradient(135deg,#FF6B35,#cc3300)', title: '⚡ Quick Booking', sub: 'Book any service in 30 seconds', emoji: '⏱️' },
  { id: 4, bg: 'linear-gradient(135deg,#9B59B6,#6c0099)', title: '✅ Verified Providers', sub: 'All shops are Aadhaar-verified', emoji: '🛡️' },
];

const EMERGENCY = [
  { label: 'Ambulance', icon: '🚑', number: '108', color: '#FF4444' },
  { label: 'Police', icon: '🚔', number: '100', color: '#4A90E2' },
  { label: 'Fire', icon: '🚒', number: '101', color: '#FF8800' },
  { label: 'Women', icon: '👩', number: '1091', color: '#9B59B6' },
];

function BannerSlider() {
  const [current, setCurrent] = useState(0);
  const timerRef = useRef(null);

  const next = () => setCurrent(c => (c + 1) % BANNERS.length);
  const prev = () => setCurrent(c => (c - 1 + BANNERS.length) % BANNERS.length);

  useEffect(() => {
    timerRef.current = setInterval(next, 3500);
    return () => clearInterval(timerRef.current);
  }, []);

  const b = BANNERS[current];
  return (
    <div style={{ padding: '14px 16px 0' }}>
      <div style={{ borderRadius: 18, background: b.bg, padding: '18px 20px', position: 'relative', overflow: 'hidden', transition: 'background 500ms', minHeight: 90 }}>
        <div style={{ position: 'absolute', right: -10, top: -10, fontSize: 72, opacity: 0.15 }}>{b.emoji}</div>
        <p style={{ fontWeight: 800, fontSize: 16, color: '#000', marginBottom: 4, position: 'relative' }}>{b.title}</p>
        <p style={{ fontSize: 13, color: 'rgba(0,0,0,0.7)', position: 'relative' }}>{b.sub}</p>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginTop: 14 }}>
          <div style={{ display: 'flex', gap: 5 }}>
            {BANNERS.map((_, i) => (
              <button key={i} onClick={() => setCurrent(i)} style={{ width: i === current ? 18 : 6, height: 6, borderRadius: 3, background: i === current ? '#000' : 'rgba(0,0,0,0.3)', border: 'none', cursor: 'pointer', padding: 0, transition: '200ms' }} />
            ))}
          </div>
          <div style={{ display: 'flex', gap: 6 }}>
            <button onClick={prev} style={{ width: 28, height: 28, borderRadius: '50%', background: 'rgba(0,0,0,0.2)', border: 'none', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <ChevronLeft size={16} color="#000" />
            </button>
            <button onClick={next} style={{ width: 28, height: 28, borderRadius: '50%', background: 'rgba(0,0,0,0.2)', border: 'none', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <ChevronRight size={16} color="#000" />
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}

function EmergencySection() {
  return (
    <div style={{ padding: '18px 16px 0' }}>
      <h3 style={{ fontWeight: 700, fontSize: 16, marginBottom: 12, display: 'flex', alignItems: 'center', gap: 6 }}>
        🆘 Emergency
        <span style={{ fontSize: 11, color: '#FF4444', background: 'rgba(255,68,68,0.1)', border: '1px solid rgba(255,68,68,0.2)', borderRadius: 6, padding: '2px 6px', fontWeight: 600 }}>Quick Dial</span>
      </h3>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 8 }}>
        {EMERGENCY.map(e => (
          <a key={e.label} href={`tel:${e.number}`} style={{ textDecoration: 'none' }}>
            <div style={{ background: '#111', border: `1px solid ${e.color}33`, borderRadius: 14, padding: '12px 8px', textAlign: 'center', cursor: 'pointer', transition: '150ms' }}
              onTouchStart={el => el.currentTarget.style.background = `${e.color}22`}
              onTouchEnd={el => el.currentTarget.style.background = '#111'}>
              <div style={{ fontSize: 26, marginBottom: 5 }}>{e.icon}</div>
              <p style={{ fontSize: 11, fontWeight: 700, color: e.color, marginBottom: 2 }}>{e.label}</p>
              <p style={{ fontSize: 12, color: '#888' }}>{e.number}</p>
            </div>
          </a>
        ))}
      </div>
    </div>
  );
}

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

      <BannerSlider />

      <EmergencySection />

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
        {(locationLoading || (location && loading)) && (
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
