import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useLanguage } from '../context/LanguageContext';
import { useAuth } from '../context/AuthContext';

export default function LanguageSelect() {
  const { LANGUAGES, setLanguage, language } = useLanguage();
  const { user } = useAuth();
  const navigate = useNavigate();
  const [selected, setSelected] = useState(language || 'en');

  const handleContinue = () => {
    setLanguage(selected);
    navigate(user ? '/' : '/login');
  };

  return (
    <div style={{ minHeight: '100vh', background: '#000', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: 24 }}>
      <div style={{ width: '100%', maxWidth: 420 }}>
        <div style={{ textAlign: 'center', marginBottom: 40 }}>
          <div style={{ width: 80, height: 80, borderRadius: 22, background: 'linear-gradient(135deg,#00FF88,#00cc6a)', display: 'flex', alignItems: 'center', justifyContent: 'center', margin: '0 auto 18px', boxShadow: '0 0 40px rgba(0,255,136,0.5)' }}>
            <span style={{ fontSize: 40, fontWeight: 900, color: '#000' }}>N</span>
          </div>
          <h1 style={{ fontSize: 30, fontWeight: 900, letterSpacing: 2, marginBottom: 6 }}>NIKAT</h1>
          <p style={{ color: '#888', fontSize: 15 }}>Choose your language / भाषा चुनें</p>
        </div>

        <div style={{ display: 'flex', flexDirection: 'column', gap: 12, marginBottom: 28 }}>
          {LANGUAGES.map(lang => (
            <button
              key={lang.code}
              onClick={() => setSelected(lang.code)}
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: 16,
                padding: '16px 20px',
                borderRadius: 16,
                border: `2px solid ${selected === lang.code ? '#00FF88' : '#222'}`,
                background: selected === lang.code ? 'rgba(0,255,136,0.08)' : '#111',
                cursor: 'pointer',
                transition: '150ms',
                textAlign: 'left',
              }}
            >
              <span style={{ fontSize: 30, width: 38, textAlign: 'center', flexShrink: 0 }}>{lang.flag}</span>
              <div style={{ flex: 1 }}>
                <div style={{ fontWeight: 700, fontSize: 16, color: selected === lang.code ? '#00FF88' : '#fff' }}>{lang.nativeName}</div>
                <div style={{ fontSize: 13, color: '#666', marginTop: 2 }}>{lang.name}</div>
              </div>
              {selected === lang.code && (
                <div style={{ width: 22, height: 22, borderRadius: '50%', background: '#00FF88', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
                  <span style={{ color: '#000', fontSize: 13, fontWeight: 800 }}>✓</span>
                </div>
              )}
            </button>
          ))}
        </div>

        <button
          onClick={handleContinue}
          style={{ width: '100%', height: 52, borderRadius: 16, background: '#00FF88', color: '#000', fontWeight: 800, fontSize: 17, border: 'none', cursor: 'pointer', boxShadow: '0 0 20px rgba(0,255,136,0.4)', transition: '150ms' }}
        >
          Continue →
        </button>
      </div>
    </div>
  );
}
