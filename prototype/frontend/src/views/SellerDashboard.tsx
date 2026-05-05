import { useEffect, useState } from 'react';
import { getListings } from '../api/listingsApi';
import { Listing } from '../types/marketplace';
import ListingCard from '../components/ListingCard';
import LoadingState from '../components/LoadingState';
import EmptyState from '../components/EmptyState';

export default function SellerDashboard() {
  const [listings, setListings] = useState<Listing[] | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    getListings().then(setListings).catch(err => setError(String(err)));
  }, []);

  if (error) return <div className="error">{error}</div>;
  if (!listings) return <LoadingState />;
  if (listings.length === 0) return <EmptyState text="Sul ei ole veel kuulutusi." />;

  return (
    <div className="dashboard">
      <h2>Minu kuulutused</h2>
      <div className="listings-grid">
        {listings.map(l=> <ListingCard key={l.id} l={l} />)}
      </div>
    </div>
  );
}
