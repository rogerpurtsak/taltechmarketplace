import { useEffect, useState } from 'react';
import { useParams, Link } from 'react-router-dom';
import { getListing } from '../api/listingsApi';
import LoadingState from '../components/LoadingState';

export default function ListingDetailView() {
  const { id } = useParams();
  const [item, setItem] = useState<any>(null);

  useEffect(() => {
    if (!id) return;
    getListing(id).then(setItem).catch(()=>{});
  }, [id]);

  if (!item) return <LoadingState />;

  return (
    <div>
      <h2>{item.title}</h2>
      <p>{item.description}</p>
      <p>Kategooria: {item.categoryName}</p>
      <p>Seisund: {item.conditionLabel}</p>
      <p>Hind: {item.isFree ? 'Tasuta' : item.price + ' ' + item.currency}</p>
      <p>Staatus: {item.status}</p>
      <p>Asukoht: {item.locationText}</p>
      {item.imageUrls && item.imageUrls.map((u:string,i:number)=> <img key={i} src={u} alt="img" style={{maxWidth:300}}/>) }
      <div><Link to="/">Tagasi</Link> | <Link to={`/listings/${id}/edit`}>Muuda</Link></div>
    </div>
  );
}
