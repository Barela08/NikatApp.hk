import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { ArrowLeft, Check, Crown, Tag } from 'lucide-react';
import { useAuth } from '../context/AuthContext';
import api from '../utils/api';
import toast from 'react-hot-toast';

export default function Subscribe() {
  const { user, refreshUser } = useAuth();
  const navigate = useNavigate();
  const [plans, setPlans] = useState([]);
  const [loading, setLoading] = useState(true);
  const [selectedPlan, setSelectedPlan] = useState(null);
  const [promoCode, setPromoCode] = useState('');
  const [promoData, setPromoData] = useState(null);
  const [promoLoading, setPromoLoading] = useState(false);
  const [subLoading, setSubLoading] = useState(false);
  const [tab, setTab] = useState(user?.role === 'provider' ? 'provider' : 'user');

  useEffect(() => { api.get('/subscriptions/plans').then(d => { setPlans(d.plans || []); setLoading(false); }); }, []);

  const filteredPlans = plans.filter(p => p.type === tab);

  const applyPromo = async () => {
    if (!promoCode) return;
    setPromoLoading(true);
    try {
      const data = await api.post('/subscriptions/apply-promo', { code: promoCode, plan_id: selectedPlan?.id });
      setPromoData(data.promo);
      toast.success('Promo code applied!');
    } catch (err) { toast.error(err.message || 'Invalid promo code'); } finally { setPromoLoading(false); }
  };

  const subscribe = async () => {
    if (!selectedPlan) return toast.error('Select a plan');
    setSubLoading(true);
    try {
      await api.post('/subscriptions/subscribe', { plan_id: selectedPlan.id, promo_code: promoCode || undefined });
      await refreshUser();
      toast.success('Subscription activated!');
      navigate('/');
    } catch (err) { toast.error(err.message); } finally { setSubLoading(false); }
  };

  const getDiscountedPrice = (plan) => {
    if (!promoData) return plan.price;
    if (promoData.discount_type === 'full') return 0;
    if (promoData.discount_type === 'percent') return plan.price * (1 - promoData.discount_value / 100);
    if (promoData.discount_type === 'fixed') return Math.max(0, plan.price - promoData.discount_value);
    return plan.price;
  };

  return (
    <div style={{ paddingBottom: 80 }}>
      <div className="topbar">
        <button onClick={() => navigate(-1)} style={{ background: '#111', border: '1px solid #222', borderRadius: 10, width: 38, height: 38, display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer' }}>
          <ArrowLeft size={18} />
        </button>
        <h2 style={{ fontWeight: 700, fontSize: 18 }}>Choose a Plan</h2>
      </div>
      <div style={{ padding: 16 }}>
        <div style={{ textAlign: 'center', marginBottom: 24 }}>
          <Crown size={40} color="#00FF88" style={{ marginBottom: 10 }} />
          <h2 style={{ fontSize: 22, fontWeight: 800, marginBottom: 6 }}>Unlock Full Access</h2>
          <p style={{ color: '#888', fontSize: 14 }}>Connect with unlimited service providers near you</p>
        </div>

        {user?.role !== 'provider' && (
          <div style={{ display: 'flex', gap: 8, marginBottom: 20, background: '#111', borderRadius: 12, padding: 4 }}>
            {['user','provider'].map(t => (
              <button key={t} onClick={() => setTab(t)} style={{ flex: 1, padding: '9px', borderRadius: 10, background: tab === t ? '#00FF88' : 'transparent', color: tab === t ? '#000' : '#888', fontWeight: 700, fontSize: 13, cursor: 'pointer', border: 'none', textTransform: 'capitalize', transition: '150ms' }}>
                {t === 'user' ? '👤 User' : '🏪 Provider'}
              </button>
            ))}
          </div>
        )}

        {loading ? (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
            {[1,2].map(i => <div key={i} className="skeleton" style={{ height: 160, borderRadius: 16 }} />)}
          </div>
        ) : filteredPlans.length === 0 ? (
          <div style={{ textAlign: 'center', padding: 40, color: '#888' }}>No plans available</div>
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 12, marginBottom: 20 }}>
            {filteredPlans.map(plan => {
              const discounted = getDiscountedPrice(plan);
              const isSelected = selectedPlan?.id === plan.id;
              return (
                <div key={plan.id} onClick={() => setSelectedPlan(plan)} className="card" style={{ cursor: 'pointer', border: `2px solid ${isSelected ? '#00FF88' : '#222'}`, background: isSelected ? 'rgba(0,255,136,0.05)' : '#111', transition: '150ms' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 12 }}>
                    <div>
                      <h3 style={{ fontWeight: 700, fontSize: 17 }}>{plan.name}</h3>
                      <p style={{ color: '#888', fontSize: 13 }}>{plan.duration_days} days</p>
                    </div>
                    <div style={{ textAlign: 'right' }}>
                      {promoData && discounted < plan.price && <span style={{ color: '#888', fontSize: 13, textDecoration: 'line-through', display: 'block' }}>₹{parseFloat(plan.price).toFixed(0)}</span>}
                      <span style={{ color: discounted === 0 ? '#00FF88' : '#fff', fontSize: 24, fontWeight: 800 }}>{discounted === 0 ? 'FREE' : `₹${parseFloat(discounted).toFixed(0)}`}</span>
                    </div>
                  </div>
                  {Array.isArray(plan.features) && plan.features.length > 0 && (
                    <div style={{ display: 'flex', flexDirection: 'column', gap: 5 }}>
                      {plan.features.map((f, i) => (
                        <div key={i} style={{ display: 'flex', alignItems: 'center', gap: 7 }}>
                          <Check size={13} color="#00FF88" />
                          <span style={{ color: '#ccc', fontSize: 13 }}>{f}</span>
                        </div>
                      ))}
                    </div>
                  )}
                  {isSelected && <div style={{ marginTop: 10, textAlign: 'center', color: '#00FF88', fontSize: 13, fontWeight: 600 }}>✓ Selected</div>}
                </div>
              );
            })}
          </div>
        )}

        <div className="card" style={{ marginBottom: 16 }}>
          <label style={{ color: '#888', fontSize: 12, marginBottom: 8, display: 'flex', alignItems: 'center', gap: 6 }}><Tag size={13} /> Promo Code</label>
          <div style={{ display: 'flex', gap: 8 }}>
            <input className="input-field" placeholder="Enter promo code" value={promoCode} onChange={e => setPromoCode(e.target.value.toUpperCase())} style={{ flex: 1 }} />
            <button className="btn-secondary btn-sm" onClick={applyPromo} disabled={promoLoading} style={{ flexShrink: 0 }}>{promoLoading ? '...' : 'Apply'}</button>
          </div>
          {promoData && (
            <div style={{ marginTop: 8, padding: '8px 12px', background: 'rgba(0,255,136,0.1)', borderRadius: 8, border: '1px solid rgba(0,255,136,0.3)' }}>
              <span style={{ color: '#00FF88', fontSize: 13, fontWeight: 600 }}>
                {promoData.discount_type === 'full' ? '🎉 100% OFF - Free!' : promoData.discount_type === 'percent' ? `🎉 ${promoData.discount_value}% OFF applied!` : promoData.discount_type === 'free_days' ? `🎉 +${promoData.discount_value} bonus days!` : `🎉 ₹${promoData.discount_value} OFF applied!`}
              </span>
            </div>
          )}
        </div>

        <button className="btn-primary" onClick={subscribe} disabled={!selectedPlan || subLoading}>{subLoading ? 'Activating...' : selectedPlan ? `Subscribe - ${getDiscountedPrice(selectedPlan) === 0 ? 'FREE' : `₹${parseFloat(getDiscountedPrice(selectedPlan)).toFixed(0)}`}` : 'Select a Plan'}</button>
        <p style={{ color: '#555', fontSize: 11, textAlign: 'center', marginTop: 10 }}>Secure payment • Cancel anytime</p>
      </div>
    </div>
  );
}
