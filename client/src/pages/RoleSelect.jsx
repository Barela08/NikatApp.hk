import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useLanguage } from '../context/LanguageContext';

export default function RoleSelect() {
  const navigate = useNavigate();
  const { t } = useLanguage();
  const [selected, setSelected] = useState(null);
  const [animating, setAnimating] = useState(false);

  const roles = [
    {
      key: 'customer',
      emoji: '👤',
      title: t('customer'),
      desc: t('userDesc'),
      features: ['Find nearby shops & services', 'Book appointments instantly', 'Compare prices & reviews', 'Exclusive member deals'],
      gradient: 'linear-gradient(145deg,#0a2a1a,#0d3d22,#0a1a10)',
      borderColor: '#00FF88',
      glow: 'rgba(0,255,136,0.2)',
      badge: 'For Everyone',
      badgeColor: '#00FF88',
    },
    {
      key: 'provider',
      emoji: '🏪',
      title: t('provider'),
      desc: t('providerDesc'),
      features: ['List your shop for free', 'Get discovered by customers', 'Manage orders & bookings', 'Analytics & Khata Book'],
      gradient: 'linear-gradient(145deg,#0a1a2a,#0d2a40,#0a1020)',
      borderColor: '#7B61FF',
      glow: 'rgba(123,97,255,0.2)',
      badge: 'For Businesses',
      badgeColor: '#7B61FF',
    },
  ];

  const handleSelect = (roleKey) => {
    if (animating) return;
    setSelected(roleKey);
    setAnimating(true);
    setTimeout(() => {
      navigate(`/login?role=${roleKey}`);
    }, 400);
  };

  return (
    <div style={{
      minHeight: '100vh',
      background: '#000',
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      justifyContent: 'center',
      padding: '24px 20px',
      position: 'relative',
      overflow: 'hidden',
    }}>
      <div style={{ position: 'absolute', top: -100, left: -100, width: 300, height: 300, background: 'radial-gradient(circle,rgba(0,255,136,0.04),transparent)', borderRadius: '50%', pointerEvents: 'none' }} />
      <div style={{ position: 'absolute', bottom: -100, right: -100, width: 300, height: 300, background: 'radial-gradient(circle,rgba(123,97,255,0.04),transparent)', borderRadius: '50%', pointerEvents: 'none' }} />

      <div style={{ width: '100%', maxWidth: 420 }}>
        <div style={{ textAlign: 'center', marginBottom: 40 }}>
          <img src="/nikatlogo.png" alt="NIKAT" style={{ width: 80, height: 80, objectFit: 'contain', marginBottom: 16 }} />
          <h1 style={{ fontSize: 26, fontWeight: 900, letterSpacing: -0.5, marginBottom: 8 }}>
            {t('iAmA') || 'I am a'}
          </h1>
          <p style={{ color: '#666', fontSize: 15 }}>Choose how you want to use NIKAT</p>
        </div>

        <div style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
          {roles.map((role) => {
            const isSelected = selected === role.key;
            return (
              <button
                key={role.key}
                onClick={() => handleSelect(role.key)}
                style={{
                  background: isSelected ? role.gradient : '#111',
                  border: `2px solid ${isSelected ? role.borderColor : '#222'}`,
                  borderRadius: 24,
                  padding: '24px 22px',
                  cursor: 'pointer',
                  textAlign: 'left',
                  transition: 'all 300ms cubic-bezier(0.34,1.56,0.64,1)',
                  transform: isSelected ? 'scale(1.02)' : 'scale(1)',
                  boxShadow: isSelected ? `0 0 40px ${role.glow}` : 'none',
                  width: '100%',
                  position: 'relative',
                  overflow: 'hidden',
                }}
              >
                {isSelected && (
                  <div style={{ position: 'absolute', inset: 0, background: role.gradient, opacity: 0.6, borderRadius: 22 }} />
                )}

                <div style={{ position: 'absolute', top: 14, right: 14 }}>
                  <span style={{ background: role.badgeColor + '22', border: `1px solid ${role.badgeColor}44`, color: role.badgeColor, fontSize: 10, fontWeight: 700, padding: '3px 8px', borderRadius: 6, letterSpacing: 0.5 }}>
                    {role.badge}
                  </span>
                </div>

                <div style={{ position: 'relative', zIndex: 1 }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: 14, marginBottom: 16 }}>
                    <div style={{
                      width: 64, height: 64, borderRadius: 20,
                      background: isSelected ? role.borderColor + '22' : '#1a1a1a',
                      border: `2px solid ${isSelected ? role.borderColor + '44' : '#2a2a2a'}`,
                      display: 'flex', alignItems: 'center', justifyContent: 'center',
                      fontSize: 30, transition: 'all 300ms', flexShrink: 0,
                    }}>
                      {role.emoji}
                    </div>
                    <div>
                      <h2 style={{ fontSize: 22, fontWeight: 900, marginBottom: 3, color: isSelected ? role.borderColor : '#fff', transition: 'color 200ms' }}>
                        {role.title}
                      </h2>
                      <p style={{ color: isSelected ? role.borderColor + 'aa' : '#666', fontSize: 13 }}>{role.desc}</p>
                    </div>
                  </div>

                  <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
                    {role.features.map((f, i) => (
                      <div key={i} style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                        <div style={{ width: 18, height: 18, borderRadius: '50%', background: isSelected ? role.borderColor + '33' : '#1a1a1a', border: `1px solid ${isSelected ? role.borderColor + '66' : '#2a2a2a'}`, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0, transition: 'all 200ms' }}>
                          <span style={{ color: isSelected ? role.borderColor : '#555', fontSize: 10 }}>✓</span>
                        </div>
                        <span style={{ color: isSelected ? '#ccc' : '#666', fontSize: 13, transition: 'color 200ms' }}>{f}</span>
                      </div>
                    ))}
                  </div>

                  <div style={{
                    marginTop: 18, padding: '12px', borderRadius: 14,
                    background: isSelected ? role.borderColor : '#1a1a1a',
                    display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8,
                    transition: 'all 300ms',
                  }}>
                    <span style={{ color: isSelected ? '#000' : '#555', fontWeight: 700, fontSize: 15 }}>
                      {isSelected ? (animating ? 'Opening...' : `Continue as ${role.title}`) : `Select ${role.title}`}
                    </span>
                    <span style={{ color: isSelected ? '#000' : '#444', fontSize: 18 }}>{isSelected && animating ? '⏳' : '→'}</span>
                  </div>
                </div>
              </button>
            );
          })}
        </div>

        <button
          onClick={() => navigate('/language')}
          style={{ marginTop: 24, background: 'none', border: 'none', color: '#555', fontSize: 13, cursor: 'pointer', width: '100%', textAlign: 'center', padding: 8 }}
        >
          🌐 Change Language
        </button>
      </div>

      <style>{`
        @keyframes fadeSlideUp {
          from { opacity: 0; transform: translateY(30px); }
          to { opacity: 1; transform: translateY(0); }
        }
      `}</style>
    </div>
  );
}
