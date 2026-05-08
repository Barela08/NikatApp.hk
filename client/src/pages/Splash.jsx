import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

export default function Splash() {
  const navigate = useNavigate();
  const { user, loading } = useAuth();
  const [progress, setProgress] = useState(0);

  useEffect(() => {
    const interval = setInterval(() => {
      setProgress(p => Math.min(p + 4, 100));
    }, 60);
    return () => clearInterval(interval);
  }, []);

  useEffect(() => {
    if (!loading) {
      const timer = setTimeout(() => {
        const lang = localStorage.getItem('nikat_lang');
        if (!lang) {
          navigate('/language');
        } else if (!user) {
          navigate('/role');
        } else {
          navigate('/');
        }
      }, 1800);
      return () => clearTimeout(timer);
    }
  }, [loading, user, navigate]);

  return (
    <div style={{
      height: '100vh',
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      justifyContent: 'center',
      background: '#000',
      position: 'relative',
      overflow: 'hidden',
    }}>
      <div style={{ position: 'absolute', inset: 0, background: 'radial-gradient(ellipse at 50% 40%,rgba(0,255,136,0.06),transparent 60%)', pointerEvents: 'none' }} />

      <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 0 }}>
        <div style={{ position: 'relative', marginBottom: 24 }}>
          <div style={{
            position: 'absolute', inset: -20,
            borderRadius: '50%',
            background: 'radial-gradient(circle,rgba(0,255,136,0.15),transparent)',
            animation: 'pulse 2s ease-in-out infinite',
          }} />
          <img
            src="/nikatlogo.png"
            alt="NIKAT"
            style={{ width: 130, height: 130, objectFit: 'contain', position: 'relative', zIndex: 1 }}
          />
        </div>

        <div style={{ textAlign: 'center' }}>
          <p style={{ color: '#555', fontSize: 14, letterSpacing: 0.5 }}>
            Har dukaan, har service – ek jagah
          </p>
        </div>
      </div>

      <div style={{ position: 'absolute', bottom: 60, width: '100%', display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 16, padding: '0 48px' }}>
        <div style={{ width: '100%', height: 2, background: '#111', borderRadius: 4, overflow: 'hidden' }}>
          <div style={{ height: '100%', width: `${progress}%`, background: 'linear-gradient(90deg,#00FF88,#00cc6a)', borderRadius: 4, transition: 'width 60ms linear', boxShadow: '0 0 8px rgba(0,255,136,0.5)' }} />
        </div>
        <p style={{ color: '#333', fontSize: 11, letterSpacing: 1 }}>by HackifyPro</p>
      </div>

      <style>{`
        @keyframes pulse {
          0%, 100% { transform: scale(1); opacity: 0.6; }
          50% { transform: scale(1.1); opacity: 1; }
        }
      `}</style>
    </div>
  );
}
