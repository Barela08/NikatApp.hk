import React, { createContext, useContext, useState, useEffect } from 'react';
import api from '../utils/api';

const LocationContext = createContext(null);

export function LocationProvider({ children }) {
  const [location, setLocation] = useState(() => {
    const saved = localStorage.getItem('nikat_location');
    return saved ? JSON.parse(saved) : null;
  });
  const [locationLoading, setLocationLoading] = useState(false);
  const [locationError, setLocationError] = useState(null);

  const detectLocation = () => {
    if (!navigator.geolocation) {
      setLocationError('Geolocation not supported');
      return;
    }
    setLocationLoading(true);
    setLocationError(null);
    navigator.geolocation.getCurrentPosition(
      async (pos) => {
        const { latitude, longitude } = pos.coords;
        let address = '', city = '';
        try {
          const res = await fetch(`https://nominatim.openstreetmap.org/reverse?lat=${latitude}&lon=${longitude}&format=json`);
          const data = await res.json();
          address = data.display_name || '';
          city = data.address?.city || data.address?.town || data.address?.village || data.address?.county || '';
        } catch {}
        const loc = { latitude, longitude, address, city };
        setLocation(loc);
        localStorage.setItem('nikat_location', JSON.stringify(loc));
        try { await api.put('/auth/location', loc); } catch {}
        setLocationLoading(false);
      },
      (err) => {
        setLocationError('Location permission denied. Please enable location access.');
        setLocationLoading(false);
        const fallback = { latitude: 28.6139, longitude: 77.2090, address: 'New Delhi, India', city: 'New Delhi' };
        setLocation(fallback);
        localStorage.setItem('nikat_location', JSON.stringify(fallback));
      },
      { timeout: 10000, enableHighAccuracy: true }
    );
  };

  useEffect(() => {
    if (!location) detectLocation();
  }, []);

  return (
    <LocationContext.Provider value={{ location, locationLoading, locationError, detectLocation }}>
      {children}
    </LocationContext.Provider>
  );
}

export const useLocation = () => useContext(LocationContext);
