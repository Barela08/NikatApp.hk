import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { ArrowLeft, Crown, Clock, CheckCircle, XCircle, Zap, Download } from 'lucide-react';
import api from '../utils/api';

const STATUS_CONFIG = {
  active:  { color: '#00FF88', bg: 'rgba(0,255,136,0.1)', label: 'Active',   icon: CheckCircle },
  trial:   { color: '#7B61FF', bg: 'rgba(123,97,255,0.1)', label: 'Trial',   icon: Zap },
  expired: { color: '#888',    bg: '#1a1a1a',              label: 'Expired', icon: Clock },
  cancelled:{ color: '#FF4444',bg: 'rgba(255,68,68,0.1)', label: 'Cancelled',icon: XCircle },
};

const PLAN_TYPE_ICONS = {
  user_free: '🆓', user_monthly: '⭐', user_quarterly: '💎', user_annual: '👑',
  provider_basic: '🏪', provider_monthly: '🚀', provider_quarterly: '💼', provider_annual: '🏆',
};

export default function BillingHistory() {
  const navigate = useNavigate();
  const [subscriptions, setSubscriptions] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    api.get('/subscriptions/my')
      .then(d => { setSubscriptions(d.subscriptions || []); setLoading(false); })
      .catch(() => setLoading(false));
  }, []);

  const activeCount = subscriptions.filter(s => s.status === 'active' && new Date(s.end_date) > new Date()).length;
  const totalSpent = subscriptions.filter(s => s.amount_paid).reduce((a, b) => a + parseFloat(b.amount_paid || 0), 0);

  return (
    <div style={{ paddingBottom: 80, maxWidth: 600, margin: '0 auto' }}>
      <div className="topbar">
        <button onClick={() => navigate(-1)} style={{ background: '#111', border: '1px solid #222', borderRadius: 10, width: 38, height: 38, display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer' }}>
          <ArrowLeft size={18} />
        </button>
        <h2 style={{ fontWeight: 700, fontSize: 18 }}>Billing History</h2>
      </div>

      <div style={{ padding: '16px' }}>
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12, marginBottom: 20 }}>
          <div style={{ background: 'linear-gradient(135deg,rgba(0,255,136,0.08),rgba(0,255,136,0.02))', border: '1px solid rgba(0,255,136,0.2)', borderRadius: 16, padding: 16 }}>
            <Crown size={20} color="#00FF88" style={{ marginBottom: 8 }} />
            <p style={{ fontSize: 24, fontWeight: 900, color: '#00FF88' }}>{activeCount}</p>
            <p style={{ color: '#888', fontSize: 12, marginTop: 2 }}>Active Plan{activeCount !== 1 ? 's' : ''}</p>
          </div>
          <div style={{ background: '#111', border: '1px solid #222', borderRadius: 16, padding: 16 }}>
            <p style={{ color: '#888', fontSize: 12, marginBottom: 8 }}>Total Spent</p>
            <p style={{ fontSize: 22, fontWeight: 900 }}>₹{totalSpent.toFixed(0)}</p>
            <p style={{ color: '#888', fontSize: 12, marginTop: 2 }}>{subscriptions.length} transaction{subscriptions.length !== 1 ? 's' : ''}</p>
          </div>
        </div>

        {loading ? (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
            {[1, 2, 3].map(i => <div key={i} className="skeleton" style={{ height: 110, borderRadius: 16 }} />)}
          </div>
        ) : subscriptions.length === 0 ? (
          <div style={{ textAlign: 'center', padding: '60px 24px' }}>
            <Crown size={48} color="#333" style={{ marginBottom: 16 }} />
            <p style={{ fontWeight: 700, fontSize: 16, marginBottom: 6 }}>No subscriptions yet</p>
            <p style={{ color: '#888', fontSize: 14, marginBottom: 24 }}>Choose a plan to unlock full access</p>
            <button className="btn-primary" onClick={() => navigate('/subscribe')} style={{ width: 'auto', padding: '0 28px' }}>
              View Plans
            </button>
          </div>
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
            {subscriptions.map(sub => {
              const isExpiredTime = new Date(sub.end_date) < new Date();
              const status = (sub.status === 'active' && isExpiredTime) ? 'expired' : sub.status;
              const cfg = STATUS_CONFIG[status] || STATUS_CONFIG.expired;
              const StatusIcon = cfg.icon;
              const planEmoji = PLAN_TYPE_ICONS[sub.plan_type] || '📋';
              const start = new Date(sub.start_date);
              const end = new Date(sub.end_date);
              const daysLeft = Math.max(0, Math.ceil((end - new Date()) / 86400000));

              return (
                <div key={sub.id} style={{ background: '#111', border: '1px solid #1e1e1e', borderRadius: 18, padding: 16, transition: '150ms' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 12 }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                      <div style={{ width: 44, height: 44, borderRadius: 12, background: '#1a1a1a', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 22 }}>
                        {planEmoji}
                      </div>
                      <div>
                        <p style={{ fontWeight: 700, fontSize: 15 }}>{sub.plan_name || 'Plan'}</p>
                        <p style={{ color: '#888', fontSize: 12, marginTop: 2, textTransform: 'capitalize' }}>
                          {sub.plan_type?.replace(/_/g, ' ')}
                        </p>
                      </div>
                    </div>
                    <div style={{ display: 'flex', alignItems: 'center', gap: 6, background: cfg.bg, border: `1px solid ${cfg.color}33`, borderRadius: 8, padding: '4px 10px' }}>
                      <StatusIcon size={12} color={cfg.color} />
                      <span style={{ color: cfg.color, fontSize: 11, fontWeight: 700 }}>{cfg.label}</span>
                    </div>
                  </div>

                  <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 8, background: '#0d0d0d', borderRadius: 12, padding: 12 }}>
                    <div>
                      <p style={{ color: '#666', fontSize: 11, marginBottom: 2 }}>Started</p>
                      <p style={{ fontSize: 13, fontWeight: 600 }}>{start.toLocaleDateString('en-IN', { day: 'numeric', month: 'short', year: 'numeric' })}</p>
                    </div>
                    <div>
                      <p style={{ color: '#666', fontSize: 11, marginBottom: 2 }}>Expires</p>
                      <p style={{ fontSize: 13, fontWeight: 600 }}>{end.toLocaleDateString('en-IN', { day: 'numeric', month: 'short', year: 'numeric' })}</p>
                    </div>
                    {sub.amount_paid && (
                      <div>
                        <p style={{ color: '#666', fontSize: 11, marginBottom: 2 }}>Amount Paid</p>
                        <p style={{ fontSize: 13, fontWeight: 600 }}>
                          {parseFloat(sub.amount_paid) === 0 ? <span style={{ color: '#00FF88' }}>FREE</span> : `₹${parseFloat(sub.amount_paid).toFixed(0)}`}
                        </p>
                      </div>
                    )}
                    {sub.promo_code && (
                      <div>
                        <p style={{ color: '#666', fontSize: 11, marginBottom: 2 }}>Promo Used</p>
                        <p style={{ fontSize: 13, fontWeight: 600, color: '#00FF88' }}>{sub.promo_code}</p>
                      </div>
                    )}
                  </div>

                  {status === 'active' && daysLeft > 0 && daysLeft <= 365 * 10 && (
                    <div style={{ marginTop: 10 }}>
                      <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 6 }}>
                        <span style={{ color: '#888', fontSize: 11 }}>Validity</span>
                        <span style={{ color: daysLeft < 7 ? '#FF4444' : '#00FF88', fontSize: 11, fontWeight: 700 }}>
                          {daysLeft} day{daysLeft !== 1 ? 's' : ''} left
                        </span>
                      </div>
                      <div style={{ height: 4, background: '#1a1a1a', borderRadius: 4, overflow: 'hidden' }}>
                        <div style={{
                          height: '100%',
                          width: `${Math.min(100, (daysLeft / 365) * 100)}%`,
                          background: daysLeft < 7 ? '#FF4444' : '#00FF88',
                          borderRadius: 4,
                          transition: 'width 500ms',
                        }} />
                      </div>
                    </div>
                  )}

                  {status === 'expired' && (
                    <button onClick={() => navigate('/subscribe')} style={{ marginTop: 12, width: '100%', padding: '10px', background: 'rgba(0,255,136,0.08)', border: '1px solid rgba(0,255,136,0.2)', borderRadius: 10, color: '#00FF88', fontSize: 13, fontWeight: 700, cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 6 }}>
                      <Crown size={14} /> Renew Plan
                    </button>
                  )}
                </div>
              );
            })}
          </div>
        )}

        {subscriptions.length > 0 && (
          <div style={{ marginTop: 20, padding: 16, background: '#0a0a0a', borderRadius: 16, border: '1px solid #1a1a1a', textAlign: 'center' }}>
            <p style={{ color: '#666', fontSize: 12, marginBottom: 4 }}>Need help with billing?</p>
            <p style={{ color: '#888', fontSize: 13 }}>Contact <span style={{ color: '#00FF88' }}>support@nikat.in</span></p>
          </div>
        )}
      </div>
    </div>
  );
}
