import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import { VitePWA } from 'vite-plugin-pwa';

export default defineConfig({
  plugins: [
    react(),
    VitePWA({
      registerType: 'autoUpdate',
      includeAssets: ['nikatlogo.png', 'favicon.ico'],
      manifest: {
        name: 'NIKAT – Nearest Services',
        short_name: 'NIKAT',
        description: 'Har Dukaan, Har Service – Ek Jagah',
        theme_color: '#000000',
        background_color: '#000000',
        display: 'standalone',
        orientation: 'portrait',
        scope: '/',
        start_url: '/',
        icons: [
          { src: 'nikatlogo.png', sizes: '192x192', type: 'image/png', purpose: 'any maskable' },
          { src: 'nikatlogo.png', sizes: '512x512', type: 'image/png', purpose: 'any maskable' }
        ],
        categories: ['utilities', 'lifestyle'],
        lang: 'en'
      },
      workbox: {
        globPatterns: ['**/*.{js,css,html,ico,png,svg,woff2}'],
        runtimeCaching: [
          {
            urlPattern: /^\/api\//,
            handler: 'NetworkFirst',
            options: {
              cacheName: 'api-cache',
              expiration: { maxEntries: 50, maxAgeSeconds: 300 },
              networkTimeoutSeconds: 5
            }
          },
          {
            urlPattern: /^https:\/\/fonts\.googleapis\.com\//,
            handler: 'StaleWhileRevalidate',
            options: { cacheName: 'google-fonts-cache' }
          }
        ]
      },
      devOptions: { enabled: true }
    })
  ],
  server: {
    host: '0.0.0.0',
    port: 5000,
    allowedHosts: true,
    proxy: {
      '/api': {
        target: 'http://localhost:3001',
        changeOrigin: true
      }
    }
  }
});
