import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { StrictMode } from 'react';

import './index.css';
import { createRoot } from 'react-dom/client';

import App from './App.tsx';

const rootElement = document.getElementById('root');
if (!rootElement) throw new Error('#root が見つかりません');

const queryClient = new QueryClient();

createRoot(rootElement).render(
  <StrictMode>
    <QueryClientProvider client={queryClient}>
      <App />
    </QueryClientProvider>
  </StrictMode>,
);
