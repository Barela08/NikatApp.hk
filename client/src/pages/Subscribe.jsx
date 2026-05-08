import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { ArrowLeft, Check, Crown, Tag, Zap, Shield, Star, Building2, X, ChevronRight, Sparkles } from 'lucide-react';
import { useAuth } from '../context/AuthContext';
import api from '../utils/api';
import toast from 'react-hot-toast';

const PLAN_META = {
  user_free:       { icon: '🆓', gradient: 'linear-gradient(135deg,#1a1a1a,#222)', badge: null, recommended: false },
  user_monthly:    { icon: '⭐', gradient: 'linear-gradient(135deg,#0a2a1a,#0d3d22)', badge: 'POPULAR', recommended: true },
  user_quarterly:  { icon: '💎', gradient: 'linear-gradient(135deg,#1a0a2a,#2a1040)', badge: 'BEST VALUE', recommended: false },
  user_annual:     { icon: '👑', gradient: 'linear-gradient(135deg,#1a1200,#2d2000)', badge: 'SAVE 32%', recommended: false },
  provider_basic:  { icon: '🏪', gradient: 'linear-gradient(135deg,#1a1a1a,#222)', badge: null, recommended: false },
  provider_monthly:{ icon: '🚀', gradient: 'linear-gradient(135deg,#0a2a1a,#0d3d22)', badge: 'POPULAR', recommended: true },
  provider_quarterly:{ icon: '💼', gradient: 'linear-gradient(135deg,#0a1a2a,#0d2a40)', badge: 'BEST VALUE', recommended: false },
  provider_annual: { icon: '🏆', gradient: 'linear-gradient(135deg,#1a0800,#2d1400)', badge: 'SAVE 30%', recommended: false },
};

const BILLING_LABELS = {
  user_free: 'Free forever',
  user_monthly: '/month',
  user_quarterly: '/3 months',
  user_annual: '/year',
  provider_basic: 'Free forever',
  provider_monthly: '/month',
  provider_quarterly: '/3 months',
  provider_annual: '/year',
};

function PlanCard({ plan, isSelected, onSelect, promoData }) {
  const meta = PLAN_META[plan.type] || {};
  const features = Array.isArray(plan.features) ? plan.features : [];
  const discounted = getDiscount(plan, promoData);
  const isFree = parseFloat(plan.price) === 0;
  const label = BILLING_LABELS[plan.type] || '';

  return (
    <div
      onClick={() => onSelect(plan)}
      style={{
        background: isSelected ? meta.gradient : '#111',
        border: `2px solid ${isSelected ? '#00FF88' : meta.recommended ? 'rgba(0,255,136,0.3)' : '#222'}`,
        borderRadius: 20,
        padding: '20px',
        cursor: 'pointer',
        transition: 'all 200ms',
        position: 'relative',
        overflow: 'hidden',
        boxShadow: isSelected ? '0 0 24px rgba(0,255,136,0.2)' : 'none',
      }}
    >
      {meta.badge && (
        <div style={{
          position: 'absolute', top: 0, right: 0,
          background: meta.recommended ? '#00FF88' : meta.badge.includes('SAVE') ? '#FFD700' : '#7B61FF',
          color: '#000', fontSize: 10, fontWeight: 800,
          padding: '5px 12px', borderRadius: '0 18px 0 10px',
          letterSpacing: 0.8,
        }}>
          {meta.badge}
        </div>
      )}

      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 14 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
          <div style={{ fontSize: 28, lineHeight: 1 }}>{meta.icon}</div>
          <div>
            <h3 style={{ fontWeight: 800, fontSize: 18, letterSpacing: -0.3 }}>{plan.name}</h3>
            <p style={{ color: '#666', fontSize: 12, marginTop: 2 }}>
              {isFree ? 'Always free' : `${plan.duration_days} days access`}
            </p>
          </div>
        </div>
        <div style={{ textAlign: 'right', flexShrink: 0 }}>
          {promoData && discounted < parseFloat(plan.price) && !isFree && (
            <span style={{ color: '#666', fontSize: 13, textDecoration: 'line-through', display: 'block' }}>
              ₹{parseFloat(plan.price).toFixed(0)}
            </span>
          )}
          <span style={{ fontSize: 28, fontWeight: 900, color: isFree ? '#888' : discounted === 0 ? '#00FF88' : '#fff', lineHeight: 1 }}>
            {isFree ? 'Free' : discounted === 0 ? 'FREE' : `₹${parseFloat(discounted).toFixed(0)}`}
          </span>
          {!isFree && (
            <span style={{ color: '#666', fontSize: 11, display: 'block' }}>{label}</span>
          )}
        </div>
      </div>

      <div style={{ display: 'flex', flexDirection: 'column', gap: 7 }}>
        {features.slice(0, isSelected ? features.length : 4).map((f, i) => (
          <div key={i} style={{ display: 'flex', alignItems: 'flex-start', gap: 8 }}>
            <Check size={13} color="#00FF88" style={{ marginTop: 2, flexShrink: 0 }} />
            <span style={{ color: isSelected ? '#ddd' : '#999', fontSize: 13, lineHeight: 1.4 }}>{f}</span>
          </div>
        ))}
        {!isSelected && features.length > 4 && (
          <p style={{ color: '#555', fontSize: 12, marginTop: 2 }}>+{features.length - 4} more features</p>
        )}
      </div>

      {isSelected && (
        <div style={{ marginTop: 14, display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 6, color: '#00FF88', fontSize: 13, fontWeight: 700 }}>
          <Check size={15} /> Selected
        </div>
      )}
    </div>
  );
}

function getDiscount(plan, promoData) {
  const price = parseFloat(plan.price);
  if (!promoData || price === 0) return price;
  if (promoData.discount_type === 'full') return 0;
  if (promoData.discount_type === 'percent' || promoData.discount_type === 'percentage') return price * (1 - promoData.discount_value / 100);
  if (promoData.discount_type === 'fixed') return Math.max(0, price - promoData.discount_value);
  if (promoData.discount_type === 'free_days') return price;
  return price;
}

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
  const [showPaymentModal, setShowPaymentModal] = useState(false);
  const [mySubscription, setMySubscription] = useState(null);

  useEffect(() => {
    api.get('/subscriptions/plans').then(d => {
      setPlans(d.plans || []);
      setLoading(false);
    });
    api.get('/subscriptions/my').then(d => {
      const active = (d.subscriptions || []).find(s => s.status === 'active' && new Date(s.end_date) > new Date());
      setMySubscription(active || null);
    }).catch(() => {});
  }, []);

  const userPlans = plans.filter(p => p.type?.startsWith('user'));
  const providerPlans = plans.filter(p => p.type?.startsWith('provider'));
  const filteredPlans = tab === 'provider' ? providerPlans : userPlans;

  const applyPromo = async () => {
    if (!promoCode.trim()) return toast.error('Enter a promo code');
    setPromoLoading(true);
    try {
      const data = await api.post('/subscriptions/apply-promo', { code: promoCode, plan_id: selectedPlan?.id });
      setPromoData(data.promo);
      toast.success('Promo code applied!');
    } catch (err) {
      toast.error(err.message || 'Invalid promo code');
    } finally { setPromoLoading(false); }
  };

  const handleSubscribe = () => {
    if (!selectedPlan) return toast.error('Please select a plan first');
    if (parseFloat(selectedPlan.price) === 0) { activateSubscription(); return; }
    setShowPaymentModal(true);
  };

  const activateSubscription = async (paymentId = null) => {
    setSubLoading(true);
    setShowPaymentModal(false);
    try {
      await api.post('/subscriptions/subscribe', {
        plan_id: selectedPlan.id,
        promo_code: promoCode || undefined,
        payment_id: paymentId,
      });
      await refreshUser();
      toast.success('🎉 Subscription activated!');
      navigate('/');
    } catch (err) {
      toast.error(err.message || 'Subscription failed');
    } finally { setSubLoading(false); }
  };

  const simulatePayment = () => {
    const fakePaymentId = 'pay_' + Math.random().toString(36).substr(2, 16).toUpperCase();
    setTimeout(() => activateSubscription(fakePaymentId), 1200);
  };

  const discountedPrice = selectedPlan ? getDiscount(selectedPlan, promoData) : 0;
  const isFreeSelected = selectedPlan && parseFloat(selectedPlan.price) === 0;
  const isFreeWithPromo = selectedPlan && discountedPrice === 0 && !isFreeSelected;

  return (
    <div style={{ paddingBottom: 100, maxWidth: 600, margin: '0 auto' }}>
      <div className="topbar" style={{ justifyContent: 'space-between' }}>
        <button onClick={() => navigate(-1)} style={{ background: '#111', border: '1px solid #222', borderRadius: 10, width: 38, height: 38, display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer', flexShrink: 0 }}>
          <ArrowLeft size={18} />
        </button>
        <h2 style={{ fontWeight: 700, fontSize: 18 }}>Membership Plans</h2>
        <button onClick={() => navigate('/billing')} style={{ background: 'none', border: 'none', color: '#00FF88', fontSize: 13, fontWeight: 600, cursor: 'pointer' }}>
          History
        </button>
      </div>

      <div style={{ padding: '20px 16px 0' }}>
        {mySubscription && (
          <div style={{ background: 'linear-gradient(135deg,rgba(0,255,136,0.08),rgba(0,255,136,0.03))', border: '1px solid rgba(0,255,136,0.25)', borderRadius: 16, padding: '14px 16px', marginBottom: 20, display: 'flex', alignItems: 'center', gap: 12 }}>
            <Crown size={22} color="#00FF88" />
            <div style={{ flex: 1 }}>
              <p style={{ fontWeight: 700, fontSize: 14 }}>Active: {mySubscription.plan_name}</p>
              <p style={{ color: '#888', fontSize: 12, marginTop: 2 }}>
                Expires {new Date(mySubscription.end_date).toLocaleDateString('en-IN', { day: 'numeric', month: 'short', year: 'numeric' })}
              </p>
            </div>
            <span style={{ background: '#00FF88', color: '#000', fontSize: 10, fontWeight: 800, padding: '4px 8px', borderRadius: 8 }}>ACTIVE</span>
          </div>
        )}

        <div style={{ textAlign: 'center', marginBottom: 24 }}>
          <div style={{ display: 'inline-flex', alignItems: 'center', justifyContent: 'center', width: 64, height: 64, background: 'radial-gradient(circle,rgba(0,255,136,0.15),rgba(0,255,136,0.03))', borderRadius: '50%', marginBottom: 12, border: '1px solid rgba(0,255,136,0.2)' }}>
            <Crown size={28} color="#00FF88" />
          </div>
          <h2 style={{ fontSize: 24, fontWeight: 900, marginBottom: 6, letterSpacing: -0.5 }}>
            {tab === 'provider' ? 'Grow Your Business' : 'Unlock Full Access'}
          </h2>
          <p style={{ color: '#888', fontSize: 14, lineHeight: 1.5 }}>
            {tab === 'provider' ? 'Get featured, manage orders & grow faster' : 'Connect with unlimited nearby services'}
          </p>
        </div>

        {user?.role !== 'provider' && (
          <div style={{ display: 'flex', gap: 0, marginBottom: 24, background: '#111', borderRadius: 14, padding: 4, border: '1px solid #222' }}>
            {[
              { key: 'user', label: '👤 For Users' },
              { key: 'provider', label: '🏪 For Providers' },
            ].map(t => (
              <button key={t.key} onClick={() => { setTab(t.key); setSelectedPlan(null); setPromoData(null); setPromoCode(''); }} style={{ flex: 1, padding: '10px', borderRadius: 11, background: tab === t.key ? '#00FF88' : 'transparent', color: tab === t.key ? '#000' : '#666', fontWeight: 700, fontSize: 13, cursor: 'pointer', border: 'none', transition: '200ms' }}>
                {t.label}
              </button>
            ))}
          </div>
        )}

        {loading ? (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
            {[1, 2, 3].map(i => <div key={i} className="skeleton" style={{ height: 180, borderRadius: 20 }} />)}
          </div>
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 12, marginBottom: 20 }}>
            {filteredPlans.map(plan => (
              <PlanCard
                key={plan.id}
                plan={plan}
                isSelected={selectedPlan?.id === plan.id}
                onSelect={setSelectedPlan}
                promoData={promoData}
              />
            ))}
          </div>
        )}

        {selectedPlan && parseFloat(selectedPlan.price) > 0 && (
          <div style={{ background: '#111', border: '1px solid #222', borderRadius: 16, padding: 16, marginBottom: 16 }}>
            <label style={{ color: '#888', fontSize: 12, marginBottom: 10, display: 'flex', alignItems: 'center', gap: 6, fontWeight: 600 }}>
              <Tag size={13} /> Promo Code
            </label>
            <div style={{ display: 'flex', gap: 8 }}>
              <input
                className="input-field"
                placeholder="Enter promo code"
                value={promoCode}
                onChange={e => { setPromoCode(e.target.value.toUpperCase()); setPromoData(null); }}
                style={{ flex: 1, textTransform: 'uppercase', letterSpacing: 1 }}
              />
              <button
                onClick={applyPromo}
                disabled={promoLoading || !promoCode}
                style={{ background: promoCode ? '#00FF88' : '#1a1a1a', color: promoCode ? '#000' : '#555', fontWeight: 700, fontSize: 13, padding: '0 16px', borderRadius: 12, border: 'none', cursor: promoCode ? 'pointer' : 'default', flexShrink: 0, transition: '200ms' }}
              >
                {promoLoading ? '...' : 'Apply'}
              </button>
            </div>
            {promoData && (
              <div style={{ marginTop: 10, padding: '10px 12px', background: 'rgba(0,255,136,0.08)', borderRadius: 10, border: '1px solid rgba(0,255,136,0.25)', display: 'flex', alignItems: 'center', gap: 8 }}>
                <Sparkles size={14} color="#00FF88" />
                <span style={{ color: '#00FF88', fontSize: 13, fontWeight: 700 }}>
                  {promoData.discount_type === 'full' ? '🎉 100% OFF — Free!' :
                   promoData.discount_type === 'percent' || promoData.discount_type === 'percentage' ? `🎉 ${promoData.discount_value}% discount applied!` :
                   promoData.discount_type === 'free_days' ? `🎉 +${promoData.discount_value} bonus days!` :
                   `🎉 ₹${promoData.discount_value} OFF applied!`}
                </span>
                <button onClick={() => { setPromoData(null); setPromoCode(''); }} style={{ marginLeft: 'auto', background: 'none', border: 'none', color: '#555', cursor: 'pointer', padding: 2 }}><X size={14} /></button>
              </div>
            )}
            <p style={{ color: '#555', fontSize: 11, marginTop: 8 }}>Try: NIKAT2024 for 100% off</p>
          </div>
        )}

        {selectedPlan && (
          <div style={{ background: '#0a1a0a', border: '1px solid rgba(0,255,136,0.15)', borderRadius: 16, padding: 16, marginBottom: 16 }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 8 }}>
              <span style={{ color: '#888', fontSize: 13 }}>{selectedPlan.name} Plan</span>
              <span style={{ fontSize: 13 }}>₹{parseFloat(selectedPlan.price).toFixed(0)}</span>
            </div>
            {promoData && discountedPrice < parseFloat(selectedPlan.price) && (
              <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 8 }}>
                <span style={{ color: '#00FF88', fontSize: 13 }}>Promo discount</span>
                <span style={{ color: '#00FF88', fontSize: 13 }}>-₹{(parseFloat(selectedPlan.price) - discountedPrice).toFixed(0)}</span>
              </div>
            )}
            <div style={{ height: 1, background: '#1a1a1a', marginBottom: 8 }} />
            <div style={{ display: 'flex', justifyContent: 'space-between' }}>
              <span style={{ fontWeight: 700, fontSize: 15 }}>Total</span>
              <span style={{ fontWeight: 900, fontSize: 18, color: discountedPrice === 0 ? '#00FF88' : '#fff' }}>
                {discountedPrice === 0 ? 'FREE' : `₹${parseFloat(discountedPrice).toFixed(0)}`}
              </span>
            </div>
          </div>
        )}

        <button
          className="btn-primary"
          onClick={handleSubscribe}
          disabled={!selectedPlan || subLoading}
          style={{ height: 56, fontSize: 16, borderRadius: 16, gap: 10, marginBottom: 8 }}
        >
          {subLoading ? (
            <span style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
              <div style={{ width: 18, height: 18, border: '2px solid #000', borderTopColor: 'transparent', borderRadius: '50%', animation: 'spin 0.6s linear infinite' }} />
              Activating...
            </span>
          ) : !selectedPlan ? (
            'Select a Plan to Continue'
          ) : isFreeSelected || isFreeWithPromo ? (
            <><Zap size={18} /> Activate Free Plan</>
          ) : (
            <><Crown size={18} /> Pay ₹{parseFloat(discountedPrice).toFixed(0)} & Subscribe</>
          )}
        </button>

        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 16, marginTop: 12 }}>
          {[{ icon: Shield, text: 'Secure Payment' }, { icon: Star, text: 'Cancel Anytime' }, { icon: Zap, text: 'Instant Activation' }].map(({ icon: Icon, text }) => (
            <div key={text} style={{ display: 'flex', alignItems: 'center', gap: 4, color: '#555', fontSize: 11 }}>
              <Icon size={11} /> {text}
            </div>
          ))}
        </div>

        <div style={{ marginTop: 24, background: '#111', border: '1px solid #1a1a1a', borderRadius: 16, padding: 16 }}>
          <p style={{ fontWeight: 700, fontSize: 11, marginBottom: 12, color: '#888', textTransform: 'uppercase', letterSpacing: 0.5 }}>Payment Methods</p>
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: 8 }}>
            {['💳 Cards', '🏦 UPI', '📱 PhonePe', '🟢 GPay', '💰 Paytm', '🔵 Razorpay'].map(m => (
              <span key={m} style={{ background: '#1a1a1a', border: '1px solid #2a2a2a', borderRadius: 8, padding: '6px 10px', fontSize: 12, color: '#888' }}>{m}</span>
            ))}
          </div>
        </div>
      </div>

      {showPaymentModal && selectedPlan && (
        <div className="modal-overlay" onClick={() => setShowPaymentModal(false)}>
          <div className="modal-sheet" onClick={e => e.stopPropagation()}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 20 }}>
              <h3 style={{ fontWeight: 800, fontSize: 18 }}>Complete Payment</h3>
              <button onClick={() => setShowPaymentModal(false)} style={{ background: '#1a1a1a', border: 'none', borderRadius: 8, width: 32, height: 32, display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer' }}>
                <X size={16} />
              </button>
            </div>

            <div style={{ background: 'linear-gradient(135deg,rgba(0,255,136,0.06),rgba(0,255,136,0.02))', border: '1px solid rgba(0,255,136,0.15)', borderRadius: 14, padding: 16, marginBottom: 20 }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 6 }}>
                <span style={{ color: '#888', fontSize: 14 }}>Plan</span>
                <span style={{ fontWeight: 700 }}>{selectedPlan.name}</span>
              </div>
              <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 6 }}>
                <span style={{ color: '#888', fontSize: 14 }}>Duration</span>
                <span>{selectedPlan.duration_days} days</span>
              </div>
              {promoData && (
                <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 6 }}>
                  <span style={{ color: '#00FF88', fontSize: 14 }}>Promo Discount</span>
                  <span style={{ color: '#00FF88' }}>-₹{(parseFloat(selectedPlan.price) - discountedPrice).toFixed(0)}</span>
                </div>
              )}
              <div style={{ height: 1, background: 'rgba(255,255,255,0.05)', margin: '10px 0' }} />
              <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                <span style={{ fontWeight: 700, fontSize: 15 }}>Amount to Pay</span>
                <span style={{ fontWeight: 900, fontSize: 22, color: '#00FF88' }}>₹{parseFloat(discountedPrice).toFixed(0)}</span>
              </div>
            </div>

            <p style={{ color: '#666', fontSize: 12, textAlign: 'center', marginBottom: 16 }}>
              This is a demo environment. In production, Razorpay / Stripe will open here.
            </p>

            <button
              className="btn-primary"
              onClick={simulatePayment}
              disabled={subLoading}
              style={{ height: 54, fontSize: 16, borderRadius: 14, marginBottom: 10 }}
            >
              {subLoading ? 'Processing...' : `🔒 Pay ₹${parseFloat(discountedPrice).toFixed(0)} via Razorpay`}
            </button>
            <button onClick={() => setShowPaymentModal(false)} className="btn-secondary" style={{ height: 46, borderRadius: 14 }}>
              Cancel
            </button>
          </div>
        </div>
      )}

      <style>{`@keyframes spin { to { transform: rotate(360deg); } }`}</style>
    </div>
  );
}
