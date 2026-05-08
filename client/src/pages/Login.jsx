import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
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
  const navigate = useNavigate();

  const sendOtp = async () => {
    if (!phone || phone.length < 10) return toast.error('Enter valid phone number');
    setLoading(true);
    try {
      const res = await api.post('/auth/send-otp', { phone });
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
      const res = await api.post('/auth/verify-otp', { phone, otp, name, role });
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
          <div style={{ width: 70, height: 70, borderRadius: 20, background: 'linear-gradient(135deg,#00FF88,#00cc6a)', display: 'flex', alignItems: 'center', justifyContent: 'center', margin: '0 auto 16px', boxShadow: '0 0 30px rgba(0,255,136,0.4)' }}>
            <span style={{ fontSize: 34, fontWeight: 900, color: '#000' }}>N</span>
          </div>
          <h1 style={{ fontSize: 28, fontWeight: 900 }}>NIKAT</h1>
          <p style={{ color: '#888', marginTop: 6 }}>{step === 'phone' ? 'Enter your phone number' : 'Verify OTP'}</p>
        </div>

        {step === 'phone' ? (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
            <div>
              <label style={{ color: '#888', fontSize: 12, marginBottom: 6, display: 'block' }}>I am a</label>
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
                {['customer', 'provider'].map(r => (
                  <button key={r} onClick={() => setRole(r)} style={{ padding: '12px', borderRadius: 12, border: `1px solid ${role === r ? '#00FF88' : '#222'}`, background: role === r ? 'rgba(0,255,136,0.1)' : '#111', color: role === r ? '#00FF88' : '#888', fontWeight: 600, fontSize: 14, textTransform: 'capitalize', transition: '150ms' }}>
                    {r === 'customer' ? '👤 Customer' : '🏪 Provider'}
                  </button>
                ))}
              </div>
            </div>
            <div>
              <label style={{ color: '#888', fontSize: 12, marginBottom: 6, display: 'block' }}>Full Name</label>
              <input className="input-field" placeholder="Your name" value={name} onChange={e => setName(e.target.value)} />
            </div>
            <div>
              <label style={{ color: '#888', fontSize: 12, marginBottom: 6, display: 'block' }}>Phone Number</label>
              <input className="input-field" type="tel" placeholder="+91 XXXXX XXXXX" value={phone} onChange={e => setPhone(e.target.value)} maxLength={15} />
            </div>
            <button className="btn-primary" onClick={sendOtp} disabled={loading}>{loading ? 'Sending...' : 'Send OTP'}</button>
          </div>
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
            {sentOtp && <div className="card" style={{ textAlign: 'center', background: 'rgba(0,255,136,0.05)', border: '1px solid rgba(0,255,136,0.3)' }}><span style={{ color: '#888', fontSize: 13 }}>Demo OTP: </span><span style={{ color: '#00FF88', fontWeight: 700, fontSize: 20, letterSpacing: 4 }}>{sentOtp}</span></div>}
            <div>
              <label style={{ color: '#888', fontSize: 12, marginBottom: 6, display: 'block' }}>Enter OTP</label>
              <input className="input-field" type="number" placeholder="6-digit OTP" value={otp} onChange={e => setOtp(e.target.value)} maxLength={6} style={{ fontSize: 24, letterSpacing: 8, textAlign: 'center' }} />
            </div>
            <button className="btn-primary" onClick={verifyOtp} disabled={loading}>{loading ? 'Verifying...' : 'Verify & Login'}</button>
            <button className="btn-secondary" onClick={() => setStep('phone')}>Change Number</button>
          </div>
        )}
      </div>
    </div>
  );
}
