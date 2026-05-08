import React, { useState, useEffect } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { useLanguage } from '../context/LanguageContext';
import api from '../utils/api';
import toast from 'react-hot-toast';
import { ArrowLeft } from 'lucide-react';

export default function Login() {
  const [searchParams] = useSearchParams();
  const roleParam = searchParams.get('role') || 'customer';

  const [step, setStep] = useState('phone');
  const [phone, setPhone] = useState('');
  const [otp, setOtp] = useState('');
  const [name, setName] = useState('');
  const [role] = useState(roleParam === 'provider' ? 'provider' : 'customer');
  const [loading, setLoading] = useState(false);
  const [sentOtp, setSentOtp] = useState(null);
  const [countdown, setCountdown] = useState(0);

  const { login } = useAuth();
  const { t } = useLanguage();
  const navigate = useNavigate();

  const isProvider = role === 'provider';

  useEffect(() => {
    if (countdown > 0) {
      const timer = setTimeout(() => setCountdown(c => c - 1), 1000);
      return () => clearTimeout(timer);
    }
  }, [countdown]);

  const sendOtp = async () => {
    if (!phone || phone.replace(/\D/g, '').length < 10) return toast.error('Enter a valid 10-digit phone number');
    setLoading(true);
    try {
      const res = await api.post('/auth/send-otp', { phone: phone.replace(/\D/g, '') });
      setSentOtp(res.otp);
      setCountdown(30);
      toast.success('OTP sent!');
      setStep('otp');
    } catch (err) {
      toast.error(err.message || 'Failed to send OTP');
    } finally { setLoading(false); }
  };

  const verifyOtp = async () => {
    if (!otp || otp.length !== 6) return toast.error('Enter the 6-digit OTP');
    setLoading(true);
    try {
      const res = await api.post('/auth/verify-otp', { phone: phone.replace(/\D/g, ''), otp, name, role });
      login(res.token, res.user);
      toast.success(`Welcome${res.user.name ? `, ${res.user.name}` : ''}! 🎉`);
      navigate('/');
    } catch (err) {
      toast.error(err.message || 'Invalid OTP');
    } finally { setLoading(false); }
  };

  const roleConfig = {
    customer: { emoji: '👤', label: 'Customer', color: '#00FF88', bg: 'rgba(0,255,136,0.1)', border: 'rgba(0,255,136,0.3)' },
    provider: { emoji: '🏪', label: 'Provider', color: '#7B61FF', bg: 'rgba(123,97,255,0.1)', border: 'rgba(123,97,255,0.3)' },
  };
  const rc = roleConfig[role];

  return (
    <div style={{ minHeight: '100vh', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: '24px 20px', background: '#000', position: 'relative', overflow: 'hidden' }}>
      <div style={{ position: 'absolute', top: -120, left: -120, width: 360, height: 360, background: `radial-gradient(circle,${rc.bg},transparent)`, borderRadius: '50%', pointerEvents: 'none' }} />

      <div style={{ width: '100%', maxWidth: 400, position: 'relative', zIndex: 1 }}>
        {step === 'otp' && (
          <button onClick={() => { setStep('phone'); setOtp(''); setSentOtp(null); }} style={{ background: '#111', border: '1px solid #222', borderRadius: 10, width: 38, height: 38, display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer', marginBottom: 24 }}>
            <ArrowLeft size={16} />
          </button>
        )}

        <div style={{ textAlign: 'center', marginBottom: 36 }}>
          <img src="/nikatlogo.png" alt="NIKAT" style={{ width: 100, height: 100, objectFit: 'contain', margin: '0 auto 16px', display: 'block' }} />

          <div style={{ display: 'inline-flex', alignItems: 'center', gap: 8, background: rc.bg, border: `1px solid ${rc.border}`, borderRadius: 24, padding: '6px 16px', marginBottom: 14 }}>
            <span style={{ fontSize: 18 }}>{rc.emoji}</span>
            <span style={{ color: rc.color, fontWeight: 700, fontSize: 14 }}>
              {step === 'phone' ? `Login as ${rc.label}` : 'Verify OTP'}
            </span>
          </div>

          <h2 style={{ fontSize: 22, fontWeight: 900, marginBottom: 6, letterSpacing: -0.3 }}>
            {step === 'phone' ? t('welcomeBack') : 'Enter your OTP'}
          </h2>
          <p style={{ color: '#666', fontSize: 14 }}>
            {step === 'phone' ? t('loginToContinue') : `Code sent to +91 ${phone.replace(/\D/g, '').slice(-10)}`}
          </p>
        </div>

        {step === 'phone' ? (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
            <div>
              <label style={{ color: '#888', fontSize: 12, marginBottom: 6, display: 'block', fontWeight: 600 }}>
                {t('fullName')} <span style={{ color: '#555' }}>(for new users)</span>
              </label>
              <input
                className="input-field"
                placeholder="Your full name"
                value={name}
                onChange={e => setName(e.target.value)}
                style={{ height: 50 }}
              />
            </div>

            <div>
              <label style={{ color: '#888', fontSize: 12, marginBottom: 6, display: 'block', fontWeight: 600 }}>
                {t('phoneNumber')}
              </label>
              <div style={{ position: 'relative' }}>
                <div style={{ position: 'absolute', left: 14, top: '50%', transform: 'translateY(-50%)', color: '#888', fontWeight: 600, fontSize: 15, display: 'flex', alignItems: 'center', gap: 6 }}>
                  🇮🇳 +91
                  <div style={{ width: 1, height: 18, background: '#333', marginLeft: 2 }} />
                </div>
                <input
                  className="input-field"
                  type="tel"
                  placeholder="XXXXX XXXXX"
                  value={phone}
                  onChange={e => setPhone(e.target.value)}
                  maxLength={15}
                  style={{ height: 54, paddingLeft: 88, fontSize: 18, letterSpacing: 1 }}
                  onKeyDown={e => e.key === 'Enter' && sendOtp()}
                />
              </div>
            </div>

            <button
              className="btn-primary"
              onClick={sendOtp}
              disabled={loading}
              style={{ height: 54, fontSize: 16, borderRadius: 16, background: rc.color, boxShadow: `0 0 20px ${rc.bg}` }}
            >
              {loading ? (
                <span style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                  <div style={{ width: 16, height: 16, border: '2px solid #000', borderTopColor: 'transparent', borderRadius: '50%', animation: 'spin 0.6s linear infinite' }} />
                  Sending OTP...
                </span>
              ) : t('sendOtp')}
            </button>

            <div style={{ display: 'flex', alignItems: 'center', gap: 12, margin: '4px 0' }}>
              <div style={{ flex: 1, height: 1, background: '#1a1a1a' }} />
              <span style={{ color: '#444', fontSize: 12 }}>or</span>
              <div style={{ flex: 1, height: 1, background: '#1a1a1a' }} />
            </div>

            <button
              onClick={() => navigate('/role')}
              style={{ height: 46, borderRadius: 14, background: '#111', border: '1px solid #222', color: '#888', fontSize: 14, fontWeight: 600, cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 8, transition: '150ms' }}
            >
              <span style={{ fontSize: 18 }}>{isProvider ? '👤' : '🏪'}</span>
              Switch to {isProvider ? 'Customer' : 'Provider'}
            </button>

            <button onClick={() => navigate('/language')} style={{ background: 'none', border: 'none', color: '#444', fontSize: 12, cursor: 'pointer', textAlign: 'center', padding: 4 }}>
              🌐 Change Language
            </button>
          </div>
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
            {sentOtp && (
              <div style={{ textAlign: 'center', padding: '14px 16px', background: 'rgba(0,255,136,0.06)', borderRadius: 14, border: '1px solid rgba(0,255,136,0.2)' }}>
                <p style={{ color: '#888', fontSize: 12, marginBottom: 4 }}>Demo OTP (for testing)</p>
                <p style={{ color: '#00FF88', fontWeight: 900, fontSize: 28, letterSpacing: 8 }}>{sentOtp}</p>
              </div>
            )}

            <div>
              <label style={{ color: '#888', fontSize: 12, marginBottom: 6, display: 'block', fontWeight: 600 }}>{t('enterOtp')}</label>
              <input
                className="input-field"
                type="number"
                inputMode="numeric"
                placeholder="• • • • • •"
                value={otp}
                onChange={e => setOtp(e.target.value.slice(0, 6))}
                style={{ fontSize: 32, letterSpacing: 14, textAlign: 'center', height: 70 }}
                autoFocus
                onKeyDown={e => e.key === 'Enter' && verifyOtp()}
              />
            </div>

            <button
              className="btn-primary"
              onClick={verifyOtp}
              disabled={loading || otp.length !== 6}
              style={{ height: 54, fontSize: 16, borderRadius: 16, background: otp.length === 6 ? rc.color : '#1a1a1a', color: otp.length === 6 ? '#000' : '#555', boxShadow: otp.length === 6 ? `0 0 20px ${rc.bg}` : 'none', transition: '200ms' }}
            >
              {loading ? (
                <span style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                  <div style={{ width: 16, height: 16, border: `2px solid ${otp.length === 6 ? '#000' : '#555'}`, borderTopColor: 'transparent', borderRadius: '50%', animation: 'spin 0.6s linear infinite' }} />
                  Verifying...
                </span>
              ) : t('verifyLogin')}
            </button>

            <button
              onClick={countdown === 0 ? sendOtp : undefined}
              style={{ background: 'none', border: 'none', color: countdown > 0 ? '#555' : '#00FF88', fontSize: 14, cursor: countdown > 0 ? 'default' : 'pointer', textAlign: 'center', padding: 8, fontWeight: 600 }}
            >
              {countdown > 0 ? `Resend OTP in ${countdown}s` : 'Resend OTP'}
            </button>
          </div>
        )}
      </div>

      <style>{`@keyframes spin { to { transform: rotate(360deg); } }`}</style>
    </div>
  );
}
