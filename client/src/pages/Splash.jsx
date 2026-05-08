import React, { useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

export default function Splash() {
  const navigate = useNavigate();
  const { user, loading } = useAuth();

  useEffect(() => {
    if (!loading) {
      setTimeout(() => navigate(user ? '/' : '/login'), 1800);
    }
  }, [loading, user]);

  return (
    <div style={{ height: '100vh', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', background: '#000', gap: 16 }}>
      <div style={{ width: 90, height: 90, borderRadius: 24, background: 'linear-gradient(135deg,#00FF88,#00cc6a)', display: 'flex', alignItems: 'center', justifyContent: 'center', boxShadow: '0 0 40px rgba(0,255,136,0.5)', animation: 'pulse 1.5s infinite' }}>
        <span style={{ fontSize: 44, fontWeight: 900, color: '#000' }}>N</span>
      </div>
      <div style={{ textAlign: 'center' }}>
        <h1 style={{ fontSize: 32, fontWeight: 900, letterSpacing: 3 }}>NIKAT</h1>
        <p style={{ color: '#888', fontSize: 14, marginTop: 4 }}>Nearest Services, Instantly</p>
      </div>
      <style>{`@keyframes pulse { 0%,100%{box-shadow:0 0 40px rgba(0,255,136,0.5)} 50%{box-shadow:0 0 60px rgba(0,255,136,0.8)} }`}</style>
    </div>
  );
}
