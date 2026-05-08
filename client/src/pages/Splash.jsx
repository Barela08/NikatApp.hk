import React, { useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

export default function Splash() {
  const navigate = useNavigate();
  const { user, loading } = useAuth();

  useEffect(() => {
    if (!loading) {
      setTimeout(() => {
        const lang = localStorage.getItem('nikat_lang');
        if (!lang) {
          navigate('/language');
        } else {
          navigate(user ? '/' : '/login');
        }
      }, 1800);
    }
  }, [loading, user]);

  return (
    <div style={{ height: '100vh', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', background: '#000', gap: 16 }}>
      <div style={{ animation: 'pulse 1.5s infinite' }}>
        <img src="/nikatlogo.png" alt="NIKAT" style={{ width: 160, height: 160, objectFit: 'contain' }} />
      </div>
      <div style={{ textAlign: 'center', marginTop: -8 }}>
        <p style={{ color: '#888', fontSize: 14, marginTop: 4 }}>Har dukaan, har service – ek jagah</p>
      </div>
      <div style={{ position: 'absolute', bottom: 40, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 8 }}>
        <div style={{ display: 'flex', gap: 6 }}>
          {[0,1,2].map(i => (
            <div key={i} style={{ width: 6, height: 6, borderRadius: '50%', background: '#00FF88', opacity: 0.3 + i * 0.35, animation: `dotPulse 1.2s ${i * 0.2}s infinite` }} />
          ))}
        </div>
        <p style={{ color: '#444', fontSize: 12 }}>by HackifyPro</p>
      </div>
      <style>{`
        @keyframes pulse { 0%,100%{box-shadow:0 0 40px rgba(0,255,136,0.5)} 50%{box-shadow:0 0 70px rgba(0,255,136,0.9)} }
        @keyframes dotPulse { 0%,100%{transform:scale(1);opacity:0.4} 50%{transform:scale(1.5);opacity:1} }
      `}</style>
    </div>
  );
}
