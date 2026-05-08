import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { ArrowLeft, MapPin, Shield, CheckCircle, Store } from 'lucide-react';
import { useAuth } from '../context/AuthContext';
import { useLocation } from '../context/LocationContext';
import api from '../utils/api';
import toast from 'react-hot-toast';

const STEPS = [
  { id: 1, label: 'Shop Details', icon: '🏪' },
  { id: 2, label: 'Aadhaar KYC', icon: '🪪' },
  { id: 3, label: 'Go Live', icon: '🚀' },
];

export default function AddStore() {
  const { user, refreshUser } = useAuth();
  const { location } = useLocation();
  const navigate = useNavigate();
  const [categories, setCategories] = useState([]);
  const [loading, setLoading] = useState(false);
  const [hasSub, setHasSub] = useState(user?.has_subscription);
  const [step, setStep] = useState(1);

  const [form, setForm] = useState({
    shop_name: '',
    description: '',
    category_id: '',
    address: location?.address || '',
    latitude: location?.latitude || '',
    longitude: location?.longitude || '',
    city: location?.city || '',
    phone: user?.phone || '',
    whatsapp: '',
  });

  const [kyc, setKyc] = useState({
    aadhaar: '',
    otp: '',
    otpSent: false,
    verified: false,
    loading: false,
    mockOtp: null,
  });

  useEffect(() => {
    api.get('/categories').then(d => setCategories(d.categories || []));
  }, []);

  const useCurrentLocation = () => {
    if (location) {
      setForm(f => ({ ...f, address: location.address, latitude: location.latitude, longitude: location.longitude, city: location.city }));
      toast.success('Location set!');
    }
  };

  const validateStep1 = () => {
    if (!form.shop_name.trim()) { toast.error('Shop name required'); return false; }
    if (!form.category_id) { toast.error('Select a category'); return false; }
    if (!form.latitude || !form.longitude) { toast.error('Location required — use GPS or enter coordinates'); return false; }
    return true;
  };

  const sendAadhaarOtp = async () => {
    const num = kyc.aadhaar.replace(/\s/g, '');
    if (num.length !== 12 || !/^\d{12}$/.test(num)) {
      return toast.error('Enter valid 12-digit Aadhaar number');
    }
    setKyc(k => ({ ...k, loading: true }));
    await new Promise(r => setTimeout(r, 1200));
    const mockOtp = String(Math.floor(100000 + Math.random() * 900000));
    setKyc(k => ({ ...k, loading: false, otpSent: true, mockOtp }));
    toast.success('OTP sent to Aadhaar-linked mobile');
  };

  const verifyAadhaarOtp = async () => {
    if (kyc.otp.length !== 6) return toast.error('Enter 6-digit OTP');
    setKyc(k => ({ ...k, loading: true }));
    await new Promise(r => setTimeout(r, 1000));
    if (kyc.otp === kyc.mockOtp) {
      setKyc(k => ({ ...k, loading: false, verified: true }));
      toast.success('Aadhaar verified successfully!');
      setTimeout(() => setStep(3), 800);
    } else {
      setKyc(k => ({ ...k, loading: false }));
      toast.error('Invalid OTP. Please try again.');
    }
  };

  const submit = async () => {
    setLoading(true);
    try {
      await api.post('/providers', { ...form, kyc_status: 'verified' });
      await refreshUser();
      toast.success('🎉 Your store is now LIVE!');
      navigate('/provider-dashboard');
    } catch (err) {
      if (err.requires_subscription) {
        toast.error('Provider subscription required');
        navigate('/subscribe');
      } else {
        toast.error(err.message || 'Failed to create store');
      }
    } finally { setLoading(false); }
  };

  if (!hasSub && user?.role !== 'admin') {
    return (
      <div style={{ minHeight: '100vh', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', padding: 24, textAlign: 'center' }}>
        <div style={{ fontSize: 56, marginBottom: 16 }}>🏪</div>
        <h2 style={{ marginBottom: 8, fontSize: 22 }}>Provider Subscription Required</h2>
        <p style={{ color: '#888', marginBottom: 6, fontSize: 14, lineHeight: 1.6 }}>To list your shop and reach customers, you need an active provider subscription.</p>
        <p style={{ color: '#555', marginBottom: 28, fontSize: 13 }}>Starting at just ₹99/month</p>
        <button className="btn-primary" onClick={() => navigate('/subscribe')}>View Provider Plans</button>
        <button className="btn-secondary" style={{ marginTop: 10 }} onClick={() => navigate(-1)}>Go Back</button>
      </div>
    );
  }

  return (
    <div style={{ paddingBottom: 80 }}>
      <div className="topbar">
        <button onClick={() => step > 1 ? setStep(s => s - 1) : navigate(-1)} style={{ background: '#111', border: '1px solid #222', borderRadius: 10, width: 38, height: 38, display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer' }}>
          <ArrowLeft size={18} />
        </button>
        <h2 style={{ fontWeight: 700, fontSize: 18 }}>Setup Store</h2>
        <span style={{ color: '#555', fontSize: 13 }}>{step}/3</span>
      </div>

      <div style={{ padding: '16px 16px 0' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 0, marginBottom: 28 }}>
          {STEPS.map((s, i) => (
            <React.Fragment key={s.id}>
              <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 5, flex: 1 }}>
                <div style={{ width: 36, height: 36, borderRadius: '50%', background: step >= s.id ? '#00FF88' : '#1a1a1a', border: `2px solid ${step >= s.id ? '#00FF88' : '#333'}`, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: step > s.id ? 16 : 15, transition: '200ms' }}>
                  {step > s.id ? <span style={{ color: '#000', fontWeight: 800, fontSize: 14 }}>✓</span> : <span>{s.icon}</span>}
                </div>
                <span style={{ fontSize: 10, color: step >= s.id ? '#00FF88' : '#555', fontWeight: step === s.id ? 700 : 400, textAlign: 'center' }}>{s.label}</span>
              </div>
              {i < STEPS.length - 1 && <div style={{ flex: 1, height: 2, background: step > s.id ? '#00FF88' : '#1a1a1a', marginBottom: 20, transition: '200ms' }} />}
            </React.Fragment>
          ))}
        </div>
      </div>

      <div style={{ padding: '0 16px' }}>

        {step === 1 && (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
            <div>
              <label style={{ color: '#888', fontSize: 12, marginBottom: 6, display: 'block' }}>Shop Name *</label>
              <input className="input-field" placeholder="e.g. Rahul Electricals" value={form.shop_name} onChange={e => setForm(f => ({ ...f, shop_name: e.target.value }))} />
            </div>
            <div>
              <label style={{ color: '#888', fontSize: 12, marginBottom: 6, display: 'block' }}>Category *</label>
              <select className="input-field" value={form.category_id} onChange={e => setForm(f => ({ ...f, category_id: e.target.value }))}>
                <option value="">Select category</option>
                {categories.map(c => <option key={c.id} value={c.id}>{c.icon} {c.name}</option>)}
              </select>
            </div>
            <div>
              <label style={{ color: '#888', fontSize: 12, marginBottom: 6, display: 'block' }}>Description</label>
              <textarea className="input-field" placeholder="What services do you offer?" value={form.description} onChange={e => setForm(f => ({ ...f, description: e.target.value }))} rows={3} style={{ resize: 'none' }} />
            </div>
            <div>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 6 }}>
                <label style={{ color: '#888', fontSize: 12 }}>Location *</label>
                <button onClick={useCurrentLocation} style={{ color: '#00FF88', fontSize: 12, background: 'none', border: 'none', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 4 }}>
                  <MapPin size={12} /> Use GPS
                </button>
              </div>
              <input className="input-field" placeholder="Full address" value={form.address} onChange={e => setForm(f => ({ ...f, address: e.target.value }))} style={{ marginBottom: 8 }} />
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: 8 }}>
                <input className="input-field" type="number" placeholder="Latitude" value={form.latitude} onChange={e => setForm(f => ({ ...f, latitude: e.target.value }))} style={{ fontSize: 13 }} />
                <input className="input-field" type="number" placeholder="Longitude" value={form.longitude} onChange={e => setForm(f => ({ ...f, longitude: e.target.value }))} style={{ fontSize: 13 }} />
                <input className="input-field" placeholder="City" value={form.city} onChange={e => setForm(f => ({ ...f, city: e.target.value }))} style={{ fontSize: 13 }} />
              </div>
            </div>
            <div>
              <label style={{ color: '#888', fontSize: 12, marginBottom: 6, display: 'block' }}>Phone</label>
              <input className="input-field" type="tel" placeholder="Contact number" value={form.phone} onChange={e => setForm(f => ({ ...f, phone: e.target.value }))} />
            </div>
            <div>
              <label style={{ color: '#888', fontSize: 12, marginBottom: 6, display: 'block' }}>WhatsApp Number</label>
              <input className="input-field" type="tel" placeholder="WhatsApp (optional)" value={form.whatsapp} onChange={e => setForm(f => ({ ...f, whatsapp: e.target.value }))} />
            </div>
            <button className="btn-primary" onClick={() => validateStep1() && setStep(2)}>
              Next: Aadhaar Verification →
            </button>
          </div>
        )}

        {step === 2 && (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
            <div className="card" style={{ background: 'rgba(0,255,136,0.04)', border: '1px solid rgba(0,255,136,0.2)', textAlign: 'center', padding: 20 }}>
              <div style={{ fontSize: 44, marginBottom: 10 }}>🪪</div>
              <h3 style={{ fontWeight: 700, marginBottom: 6 }}>Aadhaar Verification</h3>
              <p style={{ color: '#888', fontSize: 13, lineHeight: 1.6 }}>
                To prevent fraud and build trust, we verify your identity using Aadhaar. Your data is encrypted and never stored raw.
              </p>
            </div>

            <div style={{ display: 'flex', gap: 10, padding: '10px 14px', background: '#1a1a1a', borderRadius: 12, border: '1px solid #222' }}>
              <Shield size={16} color="#00FF88" style={{ flexShrink: 0, marginTop: 2 }} />
              <div>
                <p style={{ fontSize: 13, fontWeight: 600, marginBottom: 2 }}>One Aadhaar = One Account</p>
                <p style={{ fontSize: 12, color: '#666' }}>Duplicate Aadhaar registrations are automatically blocked.</p>
              </div>
            </div>

            {!kyc.verified ? (
              <>
                <div>
                  <label style={{ color: '#888', fontSize: 12, marginBottom: 6, display: 'block' }}>Aadhaar Number *</label>
                  <input
                    className="input-field"
                    placeholder="XXXX XXXX XXXX"
                    value={kyc.aadhaar}
                    onChange={e => {
                      const val = e.target.value.replace(/\D/g, '').slice(0, 12);
                      const formatted = val.replace(/(\d{4})(?=\d)/g, '$1 ');
                      setKyc(k => ({ ...k, aadhaar: formatted }));
                    }}
                    maxLength={14}
                    style={{ letterSpacing: 3, fontSize: 18, textAlign: 'center' }}
                    disabled={kyc.otpSent}
                  />
                </div>

                {!kyc.otpSent ? (
                  <button className="btn-primary" onClick={sendAadhaarOtp} disabled={kyc.loading}>
                    {kyc.loading ? 'Sending OTP...' : 'Send OTP to Aadhaar Mobile'}
                  </button>
                ) : (
                  <>
                    {kyc.mockOtp && (
                      <div className="card" style={{ textAlign: 'center', background: 'rgba(0,255,136,0.05)', border: '1px solid rgba(0,255,136,0.3)' }}>
                        <span style={{ color: '#888', fontSize: 12 }}>Demo OTP: </span>
                        <span style={{ color: '#00FF88', fontWeight: 700, fontSize: 22, letterSpacing: 6 }}>{kyc.mockOtp}</span>
                      </div>
                    )}
                    <div>
                      <label style={{ color: '#888', fontSize: 12, marginBottom: 6, display: 'block' }}>Enter OTP from Aadhaar Mobile</label>
                      <input
                        className="input-field"
                        type="number"
                        placeholder="6-digit OTP"
                        value={kyc.otp}
                        onChange={e => setKyc(k => ({ ...k, otp: e.target.value.slice(0, 6) }))}
                        style={{ fontSize: 22, letterSpacing: 8, textAlign: 'center' }}
                      />
                    </div>
                    <button className="btn-primary" onClick={verifyAadhaarOtp} disabled={kyc.loading}>
                      {kyc.loading ? 'Verifying...' : 'Verify Aadhaar'}
                    </button>
                    <button className="btn-secondary" onClick={() => setKyc(k => ({ ...k, otpSent: false, otp: '', mockOtp: null }))}>
                      Change Aadhaar Number
                    </button>
                  </>
                )}
              </>
            ) : (
              <div className="card" style={{ textAlign: 'center', background: 'rgba(0,255,136,0.08)', border: '1px solid #00FF88' }}>
                <CheckCircle size={36} color="#00FF88" style={{ marginBottom: 10 }} />
                <h3 style={{ color: '#00FF88', marginBottom: 4 }}>Aadhaar Verified!</h3>
                <p style={{ color: '#888', fontSize: 13 }}>Your identity is confirmed. Proceeding to activate your shop...</p>
              </div>
            )}
          </div>
        )}

        {step === 3 && (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
            <div className="card" style={{ textAlign: 'center', padding: 28 }}>
              <div style={{ fontSize: 56, marginBottom: 12 }}>🚀</div>
              <h2 style={{ fontWeight: 800, fontSize: 22, marginBottom: 8 }}>Ready to Go Live!</h2>
              <p style={{ color: '#888', fontSize: 14, lineHeight: 1.7 }}>
                Your shop details are set and Aadhaar is verified.<br />
                Publish your store to start receiving customers.
              </p>
            </div>

            <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
              {[
                { icon: '🏪', label: 'Shop Name', value: form.shop_name },
                { icon: '📍', label: 'City', value: form.city || 'As entered' },
                { icon: '✅', label: 'KYC Status', value: 'Aadhaar Verified' },
              ].map(item => (
                <div key={item.label} style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '12px 16px', background: '#111', borderRadius: 12, border: '1px solid #222' }}>
                  <span style={{ fontSize: 22 }}>{item.icon}</span>
                  <div>
                    <p style={{ fontSize: 12, color: '#666' }}>{item.label}</p>
                    <p style={{ fontWeight: 600, fontSize: 14, color: item.label === 'KYC Status' ? '#00FF88' : '#fff' }}>{item.value}</p>
                  </div>
                </div>
              ))}
            </div>

            <button className="btn-primary" onClick={submit} disabled={loading} style={{ height: 54, fontSize: 17 }}>
              {loading ? 'Publishing...' : '🚀 Publish My Store'}
            </button>
            <p style={{ color: '#555', fontSize: 12, textAlign: 'center' }}>Your shop will be visible to customers near your location</p>
          </div>
        )}

      </div>
    </div>
  );
}
