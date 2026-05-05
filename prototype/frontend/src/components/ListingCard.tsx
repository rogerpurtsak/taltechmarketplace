import { Listing } from '../types/marketplace';
import { Link } from 'react-router-dom';
import StatusBadge from './StatusBadge';

export default function ListingCard({ l }: { l: Listing }) {
  const priceLabel = l.isFree ? 'Tasuta' : `${l.price} ${l.currency}`;
  const img = l.imageUrls && l.imageUrls[0];
  return (
    <div className="listing-card">
      {img && <img src={img} alt="pilt" className="listing-thumb" />}
      <div className="listing-body">
        <h3>{l.title}</h3>
        <p className="meta">{l.categoryName} • {l.conditionLabel}</p>
        <p className="price">{priceLabel}</p>
        <p className="location">{l.locationText}</p>
        <p className="updated">Uuendatud: {new Date(l.updatedAt || '').toLocaleString()}</p>
        <div className="actions">
          <Link to={`/listings/${l.id}`}>Vaata</Link>
          <Link to={`/listings/${l.id}/edit`}>Muuda</Link>
          <Link to={`/listings/${l.id}/status`}>Muuda staatust</Link>
        </div>
      </div>
      <div className="listing-badge">
        <StatusBadge status={l.status} />
      </div>
    </div>
  );
}
