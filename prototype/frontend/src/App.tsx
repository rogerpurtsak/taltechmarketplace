import './App.css';
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import Header from './components/Header';
import SellerDashboard from './views/SellerDashboard';
import ListingCreateView from './views/ListingCreateView';
import ListingEditView from './views/ListingEditView';
import ListingDetailView from './views/ListingDetailView';
import StatusChangeView from './views/StatusChangeView';

export default function App(){
  return (
    <BrowserRouter>
      <div className="app">
        <Header />
        <main className="app-main">
          <Routes>
            <Route path="/" element={<SellerDashboard />} />
            <Route path="/create" element={<ListingCreateView />} />
            <Route path="/listings/:id" element={<ListingDetailView />} />
            <Route path="/listings/:id/edit" element={<ListingEditView />} />
            <Route path="/listings/:id/status" element={<StatusChangeView />} />
          </Routes>
        </main>
      </div>
    </BrowserRouter>
  );
}
