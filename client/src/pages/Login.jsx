import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { useLanguage } from '../context/LanguageContext';
import api from '../utils/api';
import toast from 'react-hot-toast';

export default function Login() {
  const [step, setStep] = useState('phone');
  const [phone, setPhone] = useState('');
  const [otp, setOtp] = useState('');
  const [name, setName] = useState('');
  const [role, setRole] = useState('customer');
  const [loading, setLoading] = useState(false);
  const [sentOtp, setSentOtp] = useState(null);
  const { login } = useAuth();
  const { t } = useLanguage();
  const navigate = useNavigate();

  const sendOtp = async () => {
    if (!phone || phone.replace(/\D/g, '').length < 10) return toast.error('Enter valid phone number');
    setLoading(true);
    try {
      const res = await api.post('/auth/send-otp', { phone: phone.replace(/\D/g, '') });
      setSentOtp(res.otp);
      toast.success('OTP sent!');
      setStep('otp');
    } catch (err) {
      toast.error(err.message);
    } finally { setLoading(false); }
  };

  const verifyOtp = async () => {
    if (!otp || otp.length !== 6) return toast.error('Enter 6-digit OTP');
    setLoading(true);
    try {
      const res = await api.post('/auth/verify-otp', { phone: phone.replace(/\D/g, ''), otp, name, role });
      login(res.token, res.user);
      toast.success(`Welcome, ${res.user.name}!`);
      navigate('/');
    } catch (err) {
      toast.error(err.message || 'Invalid OTP');
    } finally { setLoading(false); }
  };

  return (
    <div style={{ minHeight: '100vh', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: 24, background: '#000' }}>
      <div style={{ width: '100%', maxWidth: 400 }}>
        <div style={{ textAlign: 'center', marginBottom: 40 }}>
          <img src="/nikatlogo.png" alt="NIKAT" style={{ width: 120, height: 120, objectFit: 'contain', margin: '0 auto 8px', display: 'block' }} />
          <p style={{ color: '#888', marginTop: 6, fontSize: 14 }}>
            {step === 'phone' ? 'Har dukaan, har service – ek jagah' : 'OTP sent to your number'}
          </p>
        </div>

        {step === 'phone' ? (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
            <div>
              <label style={{ color: '#888', fontSize: 12, marginBottom: 8, display: 'block' }}>{t('iAm')}</label>
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
                {[
                  { value: 'customer', label: '👤 Customer', labelHi: 'ग्राहक' },
                  { value: 'provider', label: '🏪 Provider', labelHi: 'दुकानदार' },
                ].map(r => (
                  <button key={r.value} onClick={() => setRole(r.value)} style={{ padding: '14px 10px', borderRadius: 14, border: `2px solid ${role === r.value ? '#00FF88' : '#222'}`, background: role === r.value ? 'rgba(0,255,136,0.1)' : '#111', color: role === r.value ? '#00FF88' : '#888', fontWeight: 700, fontSize: 14, transition: '150ms', display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4 }}>
                    <span style={{ fontSize: 24 }}>{r.value === 'customer' ? '👤' : '🏪'}</span>
                    <span>{r.value === 'customer' ? t('customer') : t('provider')}</span>
                  </button>
                ))}
              </div>
            </div>
            <div>
              <label style={{ color: '#888', fontSize: 12, marginBottom: 6, display: 'block' }}>{t('fullName')}</label>
              <input className="input-field" placeholder="Your name" value={name} onChange={e => setName(e.target.value)} />
            </div>
            <div>
              <label style={{ color: '#888', fontSize: 12, marginBottom: 6, display: 'block' }}>{t('phoneNumber')}</label>
              <input className="input-field" type="tel" placeholder="+91 XXXXX XXXXX" value={phone} onChange={e => setPhone(e.target.value)} maxLength={15} style={{ fontSize: 17 }} />
            </div>
            <button className="btn-primary" onClick={sendOtp} disabled={loading} style={{ height: 52, fontSize: 16 }}>
              {loading ? 'Sending...' : t('sendOtp')}
            </button>
            <button onClick={() => navigate('/language')} style={{ background: 'none', border: 'none', color: '#555', fontSize: 13, cursor: 'pointer', textAlign: 'center', marginTop: 4 }}>
              🌐 Change Language
            </button>
          </div>
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
            <div style={{ textAlign: 'center', padding: '8px 16px', background: '#1a1a1a', borderRadius: 12, border: '1px solid #222' }}>
              <p style={{ color: '#888', fontSize: 12, marginBottom: 2 }}>OTP sent to</p>
              <p style={{ fontWeight: 600 }}>{phone}</p>
            </div>
            {sentOtp && (
              <div className="card" style={{ textAlign: 'center', background: 'rgba(0,255,136,0.05)', border: '1px solid rgba(0,255,136,0.3)' }}>
                <span style={{ color: '#888', fontSize: 13 }}>Demo OTP: </span>
                <span style={{ color: '#00FF88', fontWeight: 700, fontSize: 22, letterSpacing: 6 }}>{sentOtp}</span>
              </div>
            )}
            <div>
              <label style={{ color: '#888', fontSize: 12, marginBottom: 6, display: 'block' }}>{t('enterOtp')}</label>
              <input
                className="input-field"
                type="number"
                placeholder="• • • • • •"
                value={otp}
                onChange={e => setOtp(e.target.value.slice(0, 6))}
                style={{ fontSize: 28, letterSpacing: 10, textAlign: 'center', height: 64 }}
                autoFocus
              />
            </div>
            <button className="btn-primary" onClick={verifyOtp} disabled={loading} style={{ height: 52, fontSize: 16 }}>
              {loading ? 'Verifying...' : t('verifyLogin')}
            </button>
            <button className="btn-secondary" onClick={() => { setStep('phone'); setOtp(''); setSentOtp(null); }}>
              ← Change Number
            </button>
          </div>
        )}
      </div>
    </div>
  );
}
