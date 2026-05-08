import React, { useState, useEffect } from 'react';
import { Users, Crown, Tag, Store, TrendingUp, Shield, Plus, X, Check } from 'lucide-react';
import api from '../utils/api';
import toast from 'react-hot-toast';

const TABS = [
  { key: 'stats', label: 'Overview', icon: TrendingUp },
  { key: 'users', label: 'Users', icon: Users },
  { key: 'providers', label: 'Stores', icon: Store },
  { key: 'subscriptions', label: 'Subs', icon: Crown },
  { key: 'promos', label: 'Promos', icon: Tag },
  { key: 'plans', label: 'Plans', icon: Shield },
];

export default function AdminPanel() {
  const [tab, setTab] = useState('stats');
  const [stats, setStats] = useState(null);
  const [users, setUsers] = useState([]);
  const [providers, setProviders] = useState([]);
  const [subscriptions, setSubscriptions] = useState([]);
  const [promos, setPromos] = useState([]);
  const [plans, setPlans] = useState([]);
  const [loading, setLoading] = useState(false);
  const [showModal, setShowModal] = useState(null);
  const [modalData, setModalData] = useState({});
  const [selectedUser, setSelectedUser] = useState(null);

  useEffect(() => { loadTab(); }, [tab]);

  const loadTab = async () => {
    setLoading(true);
    try {
      if (tab === 'stats') { const d = await api.get('/admin/stats'); setStats(d.stats); }
      if (tab === 'users') { const d = await api.get('/admin/users?limit=50'); setUsers(d.users || []); }
      if (tab === 'providers') { const d = await api.get('/admin/providers?limit=50'); setProviders(d.providers || []); }
      if (tab === 'subscriptions') { const d = await api.get('/admin/subscriptions'); setSubscriptions(d.subscriptions || []); }
      if (tab === 'promos') { const d = await api.get('/admin/promo-codes'); setPromos(d.promo_codes || []); }
      if (tab === 'plans') { const d = await api.get('/subscriptions/plans'); setPlans(d.plans || []); }
    } catch (err) { toast.error(err.message); } finally { setLoading(false); }
  };

  const grantSubscription = async () => {
    if (!selectedUser || !modalData.plan_id || !modalData.days) return toast.error('Fill all fields');
    try {
      await api.post('/admin/grant-subscription', { user_id: selectedUser.id, plan_id: parseInt(modalData.plan_id), days: parseInt(modalData.days), is_trial: modalData.is_trial });
      toast.success(modalData.is_trial ? 'Trial granted!' : 'Subscription granted!');
      setShowModal(null); setSelectedUser(null); setModalData({});
    } catch (err) { toast.error(err.message); }
  };

  const createPromo = async () => {
    if (!modalData.code || !modalData.discount_type || !modalData.discount_value) return toast.error('Fill required fields');
    try {
      await api.post('/admin/promo-codes', modalData);
      toast.success('Promo code created!');
      setShowModal(null); setModalData({});
      loadTab();
    } catch (err) { toast.error(err.message); }
  };

  const createPlan = async () => {
    if (!modalData.name || !modalData.type || !modalData.price || !modalData.duration_days) return toast.error('Fill all fields');
    try {
      const features = modalData.features ? modalData.features.split('\n').filter(Boolean) : [];
      await api.post('/admin/plans', { ...modalData, features });
      toast.success('Plan created!');
      setShowModal(null); setModalData({});
      loadTab();
    } catch (err) { toast.error(err.message); }
  };

  const updateProvider = async (id, updates) => {
    try {
      await api.put(`/admin/providers/${id}/status`, updates);
      toast.success('Updated!');
      loadTab();
    } catch (err) { toast.error(err.message); }
  };

  const togglePromo = async (id, is_active) => {
    try {
      await api.put(`/admin/promo-codes/${id}`, { is_active });
      toast.success(is_active ? 'Activated' : 'Deactivated');
      loadTab();
    } catch (err) { toast.error(err.message); }
  };

  return (
    <div style={{ paddingBottom: 80 }}>
      <div className="topbar">
        <Shield size={20} color="#FF6B6B" />
        <h2 style={{ fontWeight: 700, fontSize: 18 }}>Admin Panel</h2>
      </div>

      <div style={{ display: 'flex', gap: 0, overflowX: 'auto', borderBottom: '1px solid #222', scrollbarWidth: 'none' }}>
        {TABS.map(({ key, label, icon: Icon }) => (
          <button key={key} onClick={() => setTab(key)} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 3, padding: '10px 16px', background: 'none', border: 'none', borderBottom: `2px solid ${tab === key ? '#00FF88' : 'transparent'}`, color: tab === key ? '#00FF88' : '#888', cursor: 'pointer', fontSize: 11, fontWeight: 600, flexShrink: 0 }}>
            <Icon size={16} />
            {label}
          </button>
        ))}
      </div>

      <div style={{ padding: 16 }}>
        {loading ? (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>{[1,2,3,4].map(i => <div key={i} className="skeleton" style={{ height: 70, borderRadius: 12 }} />)}</div>
        ) : (
          <>
            {tab === 'stats' && stats && (
              <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
                  {[
                    { label: 'Total Users', value: stats.users?.total, sub: `${stats.users?.customers} customers`, color: '#00BBFF' },
                    { label: 'Providers', value: stats.providers?.total, sub: `${stats.providers?.verified} verified`, color: '#00FF88' },
                    { label: 'Subscriptions', value: stats.subscriptions?.total, sub: `${stats.subscriptions?.active} active`, color: '#FF8800' },
                    { label: 'Bookings', value: stats.bookings?.total, sub: `${stats.bookings?.completed} completed`, color: '#FF6B6B' },
                  ].map(({ label, value, sub, color }) => (
                    <div key={label} className="card">
                      <p style={{ color: '#888', fontSize: 12, marginBottom: 4 }}>{label}</p>
                      <p style={{ fontWeight: 800, fontSize: 26, color }}>{value || 0}</p>
                      <p style={{ color: '#555', fontSize: 11 }}>{sub}</p>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {tab === 'users' && (
              <div>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 14 }}>
                  <p style={{ color: '#888', fontSize: 13 }}>{users.length} users total</p>
                </div>
                <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
                  {users.map(u => (
                    <div key={u.id} className="card">
                      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 8 }}>
                        <div>
                          <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
                            <p style={{ fontWeight: 600, fontSize: 14 }}>{u.name}</p>
                            <span style={{ fontSize: 10, padding: '2px 6px', borderRadius: 6, background: u.role === 'admin' ? '#FF6B6B22' : u.role === 'provider' ? 'rgba(0,255,136,0.1)' : '#1a1a1a', color: u.role === 'admin' ? '#FF6B6B' : u.role === 'provider' ? '#00FF88' : '#888', fontWeight: 600 }}>{u.role}</span>
                            {u.has_subscription && <span style={{ fontSize: 10, color: '#FFD700' }}>⭐</span>}
                          </div>
                          <p style={{ color: '#888', fontSize: 12 }}>{u.phone}</p>
                        </div>
                        <button onClick={() => { setSelectedUser(u); setShowModal('grant'); }} style={{ fontSize: 12, color: '#00FF88', background: 'rgba(0,255,136,0.1)', border: '1px solid rgba(0,255,136,0.2)', borderRadius: 8, padding: '4px 10px', cursor: 'pointer' }}>Grant Sub</button>
                      </div>
                      <div style={{ display: 'flex', gap: 10, fontSize: 11, color: '#555' }}>
                        <span>Views: {u.free_views_used}/{u.free_views_limit}</span>
                        <span>{new Date(u.created_at).toLocaleDateString()}</span>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {tab === 'providers' && (
              <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
                {providers.map(p => (
                  <div key={p.id} className="card">
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 8 }}>
                      <div>
                        <div style={{ display: 'flex', gap: 6, alignItems: 'center' }}>
                          <p style={{ fontWeight: 600, fontSize: 14 }}>{p.shop_name}</p>
                          {p.is_premium && <span className="badge-premium">PRO</span>}
                          {p.is_verified && <span style={{ color: '#00FF88', fontSize: 12 }}>✓</span>}
                        </div>
                        <p style={{ color: '#888', fontSize: 12 }}>{p.owner_name} • {p.category_name}</p>
                        <p style={{ color: '#555', fontSize: 11 }}>{p.city}</p>
                      </div>
                      <span style={{ fontSize: 11, color: p.status === 'active' ? '#00FF88' : '#FF4444', background: p.status === 'active' ? 'rgba(0,255,136,0.1)' : 'rgba(255,68,68,0.1)', padding: '3px 8px', borderRadius: 6, fontWeight: 600 }}>{p.status}</span>
                    </div>
                    <div style={{ display: 'flex', gap: 6, flexWrap: 'wrap' }}>
                      {!p.is_verified && <button onClick={() => updateProvider(p.id, { is_verified: true })} style={{ fontSize: 11, color: '#00FF88', background: 'rgba(0,255,136,0.1)', border: '1px solid rgba(0,255,136,0.2)', borderRadius: 6, padding: '4px 8px', cursor: 'pointer' }}>✓ Verify</button>}
                      {!p.is_premium && <button onClick={() => updateProvider(p.id, { is_premium: true })} style={{ fontSize: 11, color: '#FFD700', background: 'rgba(255,215,0,0.1)', border: '1px solid rgba(255,215,0,0.2)', borderRadius: 6, padding: '4px 8px', cursor: 'pointer' }}>⭐ Premium</button>}
                      {p.status === 'active' ? <button onClick={() => updateProvider(p.id, { status: 'suspended' })} style={{ fontSize: 11, color: '#FF4444', background: 'rgba(255,68,68,0.1)', border: '1px solid rgba(255,68,68,0.2)', borderRadius: 6, padding: '4px 8px', cursor: 'pointer' }}>Suspend</button>
                        : <button onClick={() => updateProvider(p.id, { status: 'active' })} style={{ fontSize: 11, color: '#00FF88', background: 'rgba(0,255,136,0.1)', border: '1px solid rgba(0,255,136,0.2)', borderRadius: 6, padding: '4px 8px', cursor: 'pointer' }}>Activate</button>}
                    </div>
                  </div>
                ))}
              </div>
            )}

            {tab === 'subscriptions' && (
              <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
                {subscriptions.map(s => (
                  <div key={s.id} className="card">
                    <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 4 }}>
                      <div>
                        <p style={{ fontWeight: 600, fontSize: 14 }}>{s.user_name}</p>
                        <p style={{ color: '#888', fontSize: 12 }}>{s.user_phone} • {s.user_role}</p>
                      </div>
                      <span style={{ color: s.status === 'active' ? '#00FF88' : s.status === 'trial' ? '#FFD700' : '#888', fontSize: 12, fontWeight: 600 }}>{s.status?.toUpperCase()}</span>
                    </div>
                    <div style={{ display: 'flex', gap: 12, fontSize: 12, color: '#555' }}>
                      <span>{s.plan_name || 'Custom'}</span>
                      {s.is_free && <span style={{ color: '#00FF88' }}>FREE</span>}
                      {s.promo_code && <span style={{ color: '#FFD700' }}>🏷 {s.promo_code}</span>}
                      <span style={{ marginLeft: 'auto' }}>Until {new Date(s.end_date).toLocaleDateString()}</span>
                    </div>
                  </div>
                ))}
              </div>
            )}

            {tab === 'promos' && (
              <div>
                <button onClick={() => setShowModal('promo')} className="btn-primary" style={{ marginBottom: 14 }}><Plus size={16} /> Create Promo Code</button>
                <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
                  {promos.map(p => (
                    <div key={p.id} className="card">
                      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 6 }}>
                        <div>
                          <div style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
                            <p style={{ fontWeight: 700, fontSize: 16, color: '#00FF88', letterSpacing: 1 }}>{p.code}</p>
                            <span style={{ fontSize: 11, color: p.is_active ? '#00FF88' : '#888', background: p.is_active ? 'rgba(0,255,136,0.1)' : '#1a1a1a', padding: '2px 6px', borderRadius: 4 }}>{p.is_active ? 'Active' : 'Inactive'}</span>
                          </div>
                          <p style={{ color: '#888', fontSize: 12, marginTop: 3 }}>
                            {p.discount_type === 'full' ? '100% OFF (Free)' : p.discount_type === 'percent' ? `${p.discount_value}% OFF` : p.discount_type === 'free_days' ? `+${p.discount_value} days free` : `₹${p.discount_value} OFF`}
                            {p.plan_type && ` • ${p.plan_type} plan`}
                          </p>
                        </div>
                        <button onClick={() => togglePromo(p.id, !p.is_active)} style={{ fontSize: 12, color: p.is_active ? '#FF4444' : '#00FF88', background: p.is_active ? 'rgba(255,68,68,0.1)' : 'rgba(0,255,136,0.1)', border: `1px solid ${p.is_active ? 'rgba(255,68,68,0.2)' : 'rgba(0,255,136,0.2)'}`, borderRadius: 6, padding: '4px 10px', cursor: 'pointer' }}>
                          {p.is_active ? 'Disable' : 'Enable'}
                        </button>
                      </div>
                      <div style={{ fontSize: 11, color: '#555' }}>
                        Used: {p.used_count}{p.max_uses ? `/${p.max_uses}` : ''} times
                        {p.valid_till && ` • Expires ${new Date(p.valid_till).toLocaleDateString()}`}
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {tab === 'plans' && (
              <div>
                <button onClick={() => setShowModal('plan')} className="btn-primary" style={{ marginBottom: 14 }}><Plus size={16} /> Create Plan</button>
                <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
                  {plans.map(p => (
                    <div key={p.id} className="card">
                      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
                        <div>
                          <p style={{ fontWeight: 700, fontSize: 16 }}>{p.name}</p>
                          <p style={{ color: '#888', fontSize: 12 }}>{p.type} plan • {p.duration_days} days</p>
                        </div>
                        <p style={{ color: '#00FF88', fontWeight: 800, fontSize: 20 }}>₹{parseFloat(p.price).toFixed(0)}</p>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            )}
          </>
        )}
      </div>

      {showModal === 'grant' && selectedUser && (
        <div className="modal-overlay" onClick={e => e.target === e.currentTarget && setShowModal(null)}>
          <div className="modal-sheet">
            <h3 style={{ fontWeight: 700, fontSize: 18, marginBottom: 4 }}>Grant Subscription</h3>
            <p style={{ color: '#888', fontSize: 14, marginBottom: 16 }}>To: {selectedUser.name} ({selectedUser.phone})</p>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
              <select className="input-field" value={modalData.plan_id || ''} onChange={e => setModalData(d => ({ ...d, plan_id: e.target.value }))}>
                <option value="">Select Plan</option>
                {plans.map(p => <option key={p.id} value={p.id}>{p.name} ({p.type})</option>)}
              </select>
              <input className="input-field" type="number" placeholder="Duration (days)" value={modalData.days || ''} onChange={e => setModalData(d => ({ ...d, days: e.target.value }))} />
              <label style={{ display: 'flex', alignItems: 'center', gap: 8, cursor: 'pointer' }}>
                <input type="checkbox" checked={!!modalData.is_trial} onChange={e => setModalData(d => ({ ...d, is_trial: e.target.checked }))} style={{ accentColor: '#00FF88' }} />
                <span style={{ color: '#888', fontSize: 14 }}>Mark as Trial</span>
              </label>
              <button className="btn-primary" onClick={grantSubscription}>Grant Access</button>
              <button className="btn-secondary" onClick={() => setShowModal(null)}>Cancel</button>
            </div>
          </div>
        </div>
      )}

      {showModal === 'promo' && (
        <div className="modal-overlay" onClick={e => e.target === e.currentTarget && setShowModal(null)}>
          <div className="modal-sheet">
            <h3 style={{ fontWeight: 700, fontSize: 18, marginBottom: 16 }}>Create Promo Code</h3>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
              <input className="input-field" placeholder="Code (e.g. NIKAT50)" value={modalData.code || ''} onChange={e => setModalData(d => ({ ...d, code: e.target.value.toUpperCase() }))} style={{ textTransform: 'uppercase', letterSpacing: 2, fontWeight: 700 }} />
              <select className="input-field" value={modalData.discount_type || ''} onChange={e => setModalData(d => ({ ...d, discount_type: e.target.value }))}>
                <option value="">Discount Type</option>
                <option value="percent">Percentage Off</option>
                <option value="fixed">Fixed Amount Off</option>
                <option value="free_days">Free Extra Days</option>
                <option value="full">100% Free (Full)</option>
              </select>
              <input className="input-field" type="number" placeholder="Discount Value" value={modalData.discount_value || ''} onChange={e => setModalData(d => ({ ...d, discount_value: e.target.value }))} />
              <select className="input-field" value={modalData.plan_type || ''} onChange={e => setModalData(d => ({ ...d, plan_type: e.target.value }))}>
                <option value="">For (All Plans)</option>
                <option value="user">User Plans Only</option>
                <option value="provider">Provider Plans Only</option>
                <option value="both">Both</option>
              </select>
              <input className="input-field" type="number" placeholder="Max Uses (leave empty = unlimited)" value={modalData.max_uses || ''} onChange={e => setModalData(d => ({ ...d, max_uses: e.target.value }))} />
              <input className="input-field" type="datetime-local" placeholder="Expiry (optional)" value={modalData.valid_till || ''} onChange={e => setModalData(d => ({ ...d, valid_till: e.target.value }))} style={{ colorScheme: 'dark' }} />
              <button className="btn-primary" onClick={createPromo}>Create Code</button>
              <button className="btn-secondary" onClick={() => setShowModal(null)}>Cancel</button>
            </div>
          </div>
        </div>
      )}

      {showModal === 'plan' && (
        <div className="modal-overlay" onClick={e => e.target === e.currentTarget && setShowModal(null)}>
          <div className="modal-sheet">
            <h3 style={{ fontWeight: 700, fontSize: 18, marginBottom: 16 }}>Create Plan</h3>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
              <input className="input-field" placeholder="Plan Name" value={modalData.name || ''} onChange={e => setModalData(d => ({ ...d, name: e.target.value }))} />
              <select className="input-field" value={modalData.type || ''} onChange={e => setModalData(d => ({ ...d, type: e.target.value }))}>
                <option value="">For</option>
                <option value="user">User (Customer)</option>
                <option value="provider">Provider (Store)</option>
              </select>
              <input className="input-field" type="number" placeholder="Price (₹)" value={modalData.price || ''} onChange={e => setModalData(d => ({ ...d, price: e.target.value }))} />
              <input className="input-field" type="number" placeholder="Duration (days)" value={modalData.duration_days || ''} onChange={e => setModalData(d => ({ ...d, duration_days: e.target.value }))} />
              <textarea className="input-field" placeholder="Features (one per line)" value={modalData.features || ''} onChange={e => setModalData(d => ({ ...d, features: e.target.value }))} rows={4} style={{ resize: 'none' }} />
              <button className="btn-primary" onClick={createPlan}>Create Plan</button>
              <button className="btn-secondary" onClick={() => setShowModal(null)}>Cancel</button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
