import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { User, MapPin, Bell, Shield, LogOut, Crown, ChevronRight, Globe } from 'lucide-react';
import { useAuth } from '../context/AuthContext';
import { useLocation } from '../context/LocationContext';
import { useLanguage } from '../context/LanguageContext';
import toast from 'react-hot-toast';

export default function Profile() {
  const { user, logout, refreshUser } = useAuth();
  const { location, detectLocation, locationLoading } = useLocation();
  const { language, LANGUAGES } = useLanguage();
  const navigate = useNavigate();
  const [refreshing, setRefreshing] = useState(false);
  const currentLang = LANGUAGES.find(l => l.code === language) || LANGUAGES[0];

  const handleLogout = () => { logout(); navigate('/login'); };

  const handleRefreshLocation = () => { detectLocation(); toast.success('Refreshing location...'); };

  const items = [
    { icon: Crown, label: 'My Subscription', sub: user?.has_subscription ? `Active until ${new Date(user.subscription_end).toLocaleDateString()}` : 'No active plan', action: () => navigate('/subscribe'), color: '#00FF88' },
    { icon: MapPin, label: 'Update Location', sub: location?.city || 'Not set', action: handleRefreshLocation },
    { icon: Globe, label: 'Language', sub: `${currentLang?.flag} ${currentLang?.nativeName || 'English'}`, action: () => navigate('/language') },
    ...(user?.role === 'provider' || user?.role === 'admin' ? [{ icon: User, label: 'My Store', sub: user?.shop_name || 'Manage your store', action: () => navigate('/provider-dashboard') }] : []),
    ...(user?.role === 'admin' ? [{ icon: Shield, label: 'Admin Panel', sub: 'Manage users & subscriptions', action: () => navigate('/admin'), color: '#FF6B6B' }] : []),
  ];

  return (
    <div style={{ paddingBottom: 80 }}>
      <div className="topbar">
        <h2 style={{ fontWeight: 700, fontSize: 18 }}>Profile</h2>
      </div>
      <div style={{ padding: 16 }}>
        <div className="card" style={{ textAlign: 'center', padding: '24px 16px', marginBottom: 16 }}>
          <div style={{ width: 80, height: 80, borderRadius: '50%', background: 'linear-gradient(135deg,#00FF88,#00cc6a)', display: 'flex', alignItems: 'center', justifyContent: 'center', margin: '0 auto 14px', boxShadow: '0 0 20px rgba(0,255,136,0.3)' }}>
            <span style={{ fontSize: 32, fontWeight: 800, color: '#000' }}>{user?.name?.[0]?.toUpperCase()}</span>
          </div>
          <h2 style={{ fontWeight: 800, fontSize: 20, marginBottom: 4 }}>{user?.name}</h2>
          <p style={{ color: '#888', fontSize: 14 }}>{user?.phone}</p>
          <div style={{ display: 'flex', justifyContent: 'center', gap: 10, marginTop: 12, flexWrap: 'wrap' }}>
            <span style={{ padding: '4px 12px', borderRadius: 20, background: user?.role === 'admin' ? '#FF6B6B22' : user?.role === 'provider' ? 'rgba(0,255,136,0.1)' : '#1a1a1a', border: `1px solid ${user?.role === 'admin' ? '#FF6B6B' : user?.role === 'provider' ? '#00FF88' : '#222'}`, color: user?.role === 'admin' ? '#FF6B6B' : user?.role === 'provider' ? '#00FF88' : '#888', fontSize: 12, textTransform: 'capitalize', fontWeight: 600 }}>
              {user?.role}
            </span>
            {user?.is_verified && <span style={{ padding: '4px 12px', borderRadius: 20, background: 'rgba(0,255,136,0.1)', border: '1px solid #00FF88', color: '#00FF88', fontSize: 12, fontWeight: 600 }}>✓ Verified</span>}
            {user?.has_subscription && <span style={{ padding: '4px 12px', borderRadius: 20, background: 'rgba(0,255,136,0.1)', border: '1px solid #00FF88', color: '#00FF88', fontSize: 12, fontWeight: 600 }}>⭐ Subscribed</span>}
          </div>
        </div>

        {!user?.has_subscription && user?.role === 'customer' && (
          <div className="card" style={{ background: 'linear-gradient(135deg,rgba(0,255,136,0.08),rgba(0,255,136,0.03))', border: '1px solid rgba(0,255,136,0.2)', marginBottom: 16, cursor: 'pointer' }} onClick={() => navigate('/subscribe')}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
              <Crown size={24} color="#00FF88" />
              <div>
                <p style={{ fontWeight: 700 }}>Upgrade to Premium</p>
                <p style={{ color: '#888', fontSize: 13 }}>{user?.free_views_limit - user?.free_views_used} free views remaining</p>
              </div>
              <ChevronRight size={18} color="#00FF88" style={{ marginLeft: 'auto' }} />
            </div>
          </div>
        )}

        <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
          {items.map(({ icon: Icon, label, sub, action, color }) => (
            <button key={label} onClick={action} style={{ display: 'flex', alignItems: 'center', gap: 12, background: '#111', border: '1px solid #222', borderRadius: 14, padding: '14px', width: '100%', cursor: 'pointer', transition: '150ms', textAlign: 'left' }}>
              <div style={{ width: 40, height: 40, borderRadius: 12, background: '#1a1a1a', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
                <Icon size={18} color={color || '#888'} />
              </div>
              <div style={{ flex: 1 }}>
                <p style={{ fontWeight: 600, fontSize: 14, color: color || '#fff' }}>{label}</p>
                {sub && <p style={{ color: '#888', fontSize: 12, marginTop: 2 }}>{sub}</p>}
              </div>
              <ChevronRight size={16} color="#444" />
            </button>
          ))}

          <button onClick={handleLogout} style={{ display: 'flex', alignItems: 'center', gap: 12, background: '#1a0a0a', border: '1px solid #FF444433', borderRadius: 14, padding: '14px', width: '100%', cursor: 'pointer', marginTop: 8 }}>
            <div style={{ width: 40, height: 40, borderRadius: 12, background: '#220a0a', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <LogOut size={18} color="#FF4444" />
            </div>
            <span style={{ fontWeight: 600, fontSize: 14, color: '#FF4444' }}>Logout</span>
          </button>
        </div>
      </div>
    </div>
  );
}
