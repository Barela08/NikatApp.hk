import React, { useState, useMemo } from 'react';
import { useNavigate } from 'react-router-dom';
import { useLanguage, LANGUAGES } from '../context/LanguageContext';
import { useAuth } from '../context/AuthContext';

export default function LanguageSelect() {
  const { setLanguage, language } = useLanguage();
  const { user } = useAuth();
  const navigate = useNavigate();
  const [search, setSearch] = useState('');
  const [selecting, setSelecting] = useState(null);

  const filtered = useMemo(() => {
    if (!search.trim()) return LANGUAGES;
    const q = search.toLowerCase();
    return LANGUAGES.filter(l =>
      l.name.toLowerCase().includes(q) ||
      l.nativeName.toLowerCase().includes(q)
    );
  }, [search]);

  const handleSelect = (code) => {
    if (selecting) return;
    setSelecting(code);
    setLanguage(code);
    setTimeout(() => {
      if (user) navigate('/');
      else navigate('/role');
    }, 350);
  };

  return (
    <div style={{
      minHeight: '100vh',
      background: '#000',
      display: 'flex',
      flexDirection: 'column',
      position: 'relative',
      overflow: 'hidden',
    }}>
      <div style={{ position: 'absolute', top: -80, right: -80, width: 260, height: 260, background: 'radial-gradient(circle,rgba(0,255,136,0.05),transparent)', borderRadius: '50%', pointerEvents: 'none' }} />

      <div style={{ position: 'sticky', top: 0, zIndex: 10, background: 'rgba(0,0,0,0.95)', backdropFilter: 'blur(12px)', borderBottom: '1px solid #111', padding: '20px 20px 16px' }}>
        <div style={{ maxWidth: 480, margin: '0 auto' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 14, marginBottom: 16 }}>
            <img src="/nikatlogo.png" alt="NIKAT" style={{ width: 42, height: 42, objectFit: 'contain', flexShrink: 0 }} />
            <div>
              <h1 style={{ fontSize: 20, fontWeight: 900, letterSpacing: -0.3, lineHeight: 1.1 }}>
                Choose Language
              </h1>
              <p style={{ color: '#666', fontSize: 13, marginTop: 2 }}>भाषा चुनें • ভাষা বেছে নিন</p>
            </div>
          </div>
          <div style={{ position: 'relative' }}>
            <span style={{ position: 'absolute', left: 14, top: '50%', transform: 'translateY(-50%)', fontSize: 16, pointerEvents: 'none' }}>🔍</span>
            <input
              type="text"
              placeholder="Search language..."
              value={search}
              onChange={e => setSearch(e.target.value)}
              autoFocus
              style={{
                width: '100%',
                background: '#111',
                border: '1px solid #222',
                borderRadius: 14,
                padding: '12px 14px 12px 42px',
                color: '#fff',
                fontSize: 15,
                outline: 'none',
                fontFamily: 'inherit',
              }}
            />
            {search && (
              <button onClick={() => setSearch('')} style={{ position: 'absolute', right: 12, top: '50%', transform: 'translateY(-50%)', background: 'none', border: 'none', color: '#555', cursor: 'pointer', fontSize: 18, padding: 4 }}>×</button>
            )}
          </div>
        </div>
      </div>

      <div style={{ flex: 1, overflowY: 'auto', padding: '12px 16px 40px' }}>
        <div style={{ maxWidth: 480, margin: '0 auto' }}>
          {filtered.length === 0 ? (
            <div style={{ textAlign: 'center', padding: '60px 20px', color: '#555' }}>
              <p style={{ fontSize: 32, marginBottom: 12 }}>🔍</p>
              <p style={{ fontSize: 15 }}>No language found for "{search}"</p>
            </div>
          ) : (
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
              {filtered.map((lang) => {
                const isActive = language === lang.code;
                const isSelecting = selecting === lang.code;
                return (
                  <button
                    key={lang.code}
                    onClick={() => handleSelect(lang.code)}
                    style={{
                      background: isSelecting ? lang.gradient : isActive ? lang.gradient : '#111',
                      border: `2px solid ${isSelecting || isActive ? '#00FF88' : '#1e1e1e'}`,
                      borderRadius: 18,
                      padding: '18px 14px',
                      cursor: 'pointer',
                      textAlign: 'center',
                      transition: 'all 250ms cubic-bezier(0.34,1.56,0.64,1)',
                      transform: isSelecting ? 'scale(0.95)' : 'scale(1)',
                      boxShadow: isSelecting || isActive ? '0 0 20px rgba(0,255,136,0.15)' : 'none',
                      position: 'relative',
                      overflow: 'hidden',
                      display: 'flex',
                      flexDirection: 'column',
                      alignItems: 'center',
                      gap: 8,
                    }}
                  >
                    {(isActive || isSelecting) && (
                      <div style={{ position: 'absolute', top: 8, right: 8, width: 18, height: 18, borderRadius: '50%', background: '#00FF88', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                        <span style={{ color: '#000', fontSize: 10, fontWeight: 900 }}>{isSelecting ? '⏳' : '✓'}</span>
                      </div>
                    )}

                    <div style={{ fontSize: 32, lineHeight: 1, filter: 'drop-shadow(0 2px 4px rgba(0,0,0,0.5))' }}>
                      {lang.flag}
                    </div>

                    <div>
                      <div style={{
                        fontWeight: 800,
                        fontSize: 17,
                        color: isSelecting || isActive ? '#00FF88' : '#fff',
                        lineHeight: 1.2,
                        marginBottom: 3,
                        transition: 'color 200ms',
                        fontFamily: 'inherit',
                      }}>
                        {lang.nativeName}
                      </div>
                      <div style={{ fontSize: 11, color: isSelecting || isActive ? '#00FF8888' : '#555', fontWeight: 500, letterSpacing: 0.3 }}>
                        {lang.name}
                      </div>
                    </div>
                  </button>
                );
              })}
            </div>
          )}

          {!search && (
            <p style={{ textAlign: 'center', color: '#333', fontSize: 12, marginTop: 24, lineHeight: 1.6 }}>
              Tap any language to instantly select it
            </p>
          )}
        </div>
      </div>

      <style>{`
        input::placeholder { color: #555; }
        input:focus { border-color: #333 !important; }
      `}</style>
    </div>
  );
}
