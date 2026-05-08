import React from 'react';
import { Outlet, useLocation, useNavigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';
import { Home, Search, BookOpen, User, LayoutDashboard, ShieldCheck } from 'lucide-react';

export default function Layout() {
  const { pathname } = useLocation();
  const navigate = useNavigate();
  const { user } = useAuth();

  const navItems = [
    { icon: Home, label: 'Home', path: '/' },
    { icon: Search, label: 'Search', path: '/search' },
    { icon: BookOpen, label: 'Bookings', path: '/bookings' },
    ...(user?.role === 'provider' || user?.role === 'admin' ? [{ icon: LayoutDashboard, label: 'Store', path: '/provider-dashboard' }] : []),
    ...(user?.role === 'admin' ? [{ icon: ShieldCheck, label: 'Admin', path: '/admin' }] : []),
    { icon: User, label: 'Profile', path: '/profile' },
  ];

  return (
    <div style={{ maxWidth: 600, margin: '0 auto', position: 'relative', minHeight: '100vh' }}>
      <Outlet />
      <nav className="navbar">
        {navItems.map(({ icon: Icon, label, path }) => (
          <button key={path} className={`navbar-item${pathname === path ? ' active' : ''}`} onClick={() => navigate(path)}>
            <Icon strokeWidth={pathname === path ? 2.5 : 1.8} />
            <span>{label}</span>
          </button>
        ))}
      </nav>
    </div>
  );
}
