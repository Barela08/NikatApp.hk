import React from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { Toaster } from 'react-hot-toast';
import { AuthProvider, useAuth } from './context/AuthContext';
import { LocationProvider } from './context/LocationContext';
import { LanguageProvider } from './context/LanguageContext';
import Splash from './pages/Splash';
import LanguageSelect from './pages/LanguageSelect';
import Login from './pages/Login';
import Home from './pages/Home';
import Search from './pages/Search';
import ProviderDetail from './pages/ProviderDetail';
import Profile from './pages/Profile';
import Bookings from './pages/Bookings';
import ProviderDashboard from './pages/ProviderDashboard';
import AddStore from './pages/AddStore';
import AdminPanel from './pages/AdminPanel';
import Subscribe from './pages/Subscribe';
import Favorites from './pages/Favorites';
import Layout from './components/Layout';

function ProtectedRoute({ children, roles }) {
  const { user, loading } = useAuth();
  if (loading) return <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', height: '100vh' }}><div className="skeleton" style={{ width: 48, height: 48, borderRadius: '50%' }} /></div>;
  if (!user) return <Navigate to="/login" replace />;
  if (roles && !roles.includes(user.role)) return <Navigate to="/" replace />;
  return children;
}

export default function App() {
  return (
    <BrowserRouter>
      <LanguageProvider>
        <AuthProvider>
          <LocationProvider>
            <Toaster position="top-center" toastOptions={{ style: { background: '#111', color: '#fff', border: '1px solid #222', borderRadius: '12px' }, success: { iconTheme: { primary: '#00FF88', secondary: '#000' } } }} />
            <Routes>
              <Route path="/splash" element={<Splash />} />
              <Route path="/language" element={<LanguageSelect />} />
              <Route path="/login" element={<Login />} />
              <Route path="/" element={<ProtectedRoute><Layout /></ProtectedRoute>}>
                <Route index element={<Home />} />
                <Route path="search" element={<Search />} />
                <Route path="provider/:id" element={<ProviderDetail />} />
                <Route path="profile" element={<Profile />} />
                <Route path="bookings" element={<Bookings />} />
                <Route path="favorites" element={<Favorites />} />
                <Route path="subscribe" element={<Subscribe />} />
                <Route path="provider-dashboard" element={<ProtectedRoute roles={['provider','admin']}><ProviderDashboard /></ProtectedRoute>} />
                <Route path="add-store" element={<ProtectedRoute roles={['provider','admin']}><AddStore /></ProtectedRoute>} />
                <Route path="admin" element={<ProtectedRoute roles={['admin']}><AdminPanel /></ProtectedRoute>} />
              </Route>
              <Route path="*" element={<Navigate to="/" />} />
            </Routes>
          </LocationProvider>
        </AuthProvider>
      </LanguageProvider>
    </BrowserRouter>
  );
}
