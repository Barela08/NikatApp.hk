import React, { useState, useEffect } from 'react';
import { Search as SearchIcon, SlidersHorizontal, X } from 'lucide-react';
import { useLocation } from '../context/LocationContext';
import api from '../utils/api';
import ProviderCard from '../components/ProviderCard';

export default function Search() {
  const { location } = useLocation();
  const [query, setQuery] = useState('');
  const [categories, setCategories] = useState([]);
  const [providers, setProviders] = useState([]);
  const [loading, setLoading] = useState(false);
  const [selectedCat, setSelectedCat] = useState(null);
  const [radius, setRadius] = useState(10);
  const [showFilters, setShowFilters] = useState(false);

  useEffect(() => { api.get('/categories').then(d => setCategories(d.categories || [])); }, []);

  const search = async () => {
    if (!location) return;
    setLoading(true);
    try {
      const params = new URLSearchParams({ lat: location.latitude, lng: location.longitude, radius, limit: 30 });
      if (selectedCat) params.append('category', selectedCat);
      const data = await api.get(`/providers/nearby?${params}`);
      let results = data.providers || [];
      if (query) results = results.filter(p => p.shop_name.toLowerCase().includes(query.toLowerCase()) || p.category_name?.toLowerCase().includes(query.toLowerCase()) || p.description?.toLowerCase().includes(query.toLowerCase()));
      setProviders(results);
    } catch {} finally { setLoading(false); }
  };

  useEffect(() => { search(); }, [location, selectedCat, radius]);

  return (
    <div style={{ paddingBottom: 80 }}>
      <div className="topbar" style={{ gap: 10 }}>
        <div style={{ flex: 1, display: 'flex', alignItems: 'center', gap: 10, background: '#111', border: '1px solid #222', borderRadius: 12, padding: '10px 14px' }}>
          <SearchIcon size={16} color="#888" />
          <input value={query} onChange={e => { setQuery(e.target.value); search(); }} placeholder="Search services..." style={{ flex: 1, background: 'none', border: 'none', color: '#fff', fontSize: 15, outline: 'none' }} autoFocus />
          {query && <button onClick={() => { setQuery(''); search(); }} style={{ background: 'none', border: 'none', cursor: 'pointer', color: '#888' }}><X size={15} /></button>}
        </div>
        <button onClick={() => setShowFilters(!showFilters)} style={{ width: 44, height: 44, borderRadius: 12, background: showFilters ? 'rgba(0,255,136,0.1)' : '#111', border: `1px solid ${showFilters ? '#00FF88' : '#222'}`, display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer', flexShrink: 0 }}>
          <SlidersHorizontal size={18} color={showFilters ? '#00FF88' : '#888'} />
        </button>
      </div>

      {showFilters && (
        <div style={{ padding: '12px 16px', background: '#0a0a0a', borderBottom: '1px solid #222' }}>
          <div style={{ marginBottom: 10 }}>
            <label style={{ color: '#888', fontSize: 12, marginBottom: 6, display: 'block' }}>Radius: {radius} km</label>
            <input type="range" min={1} max={25} value={radius} onChange={e => setRadius(e.target.value)} style={{ width: '100%', accentColor: '#00FF88' }} />
          </div>
          <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
            <button className={`pill${!selectedCat ? ' active' : ''}`} onClick={() => setSelectedCat(null)}>All</button>
            {categories.map(c => <button key={c.id} className={`pill${selectedCat === c.id ? ' active' : ''}`} onClick={() => setSelectedCat(selectedCat === c.id ? null : c.id)}>{c.icon} {c.name}</button>)}
          </div>
        </div>
      )}

      <div style={{ padding: '12px 16px 0' }}>
        <div style={{ display: 'flex', gap: 8, overflowX: 'auto', paddingBottom: 4, scrollbarWidth: 'none', marginBottom: 14 }}>
          <button className={`pill${!selectedCat ? ' active' : ''}`} onClick={() => setSelectedCat(null)}>All</button>
          {categories.slice(0, 8).map(c => <button key={c.id} className={`pill${selectedCat === c.id ? ' active' : ''}`} onClick={() => setSelectedCat(selectedCat === c.id ? null : c.id)} style={{ flexShrink: 0 }}>{c.icon} {c.name}</button>)}
        </div>
        {loading ? (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
            {[1,2,3].map(i => <div key={i} className="skeleton" style={{ height: 100, borderRadius: 16 }} />)}
          </div>
        ) : providers.length === 0 ? (
          <div style={{ textAlign: 'center', padding: '60px 20px', color: '#888' }}>
            <div style={{ fontSize: 48, marginBottom: 12 }}>🔍</div>
            <p style={{ fontWeight: 600 }}>No results found</p>
            <p style={{ fontSize: 13, marginTop: 6 }}>Try different keywords or increase radius</p>
          </div>
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
            <p style={{ color: '#888', fontSize: 13, marginBottom: 4 }}>{providers.length} services found</p>
            {providers.map(p => <ProviderCard key={p.id} provider={p} />)}
          </div>
        )}
      </div>
    </div>
  );
}
