import { useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import ListingForm from '../components/ListingForm';
import { getListing, updateListing } from '../api/listingsApi';
import LoadingState from '../components/LoadingState';

export default function ListingEditView() {
  const { id } = useParams();
  const nav = useNavigate();
  const [initial, setInitial] = useState<any>(null);

  useEffect(() => {
    if (!id) return;
    getListing(id).then(setInitial).catch(()=>{});
  }, [id]);

  if (!initial) return <LoadingState />;

  async function submit(v: any) {
    try {
      await updateListing(id!, v);
      nav('/');
    } catch (err) { alert('Viga: ' + String(err)); }
  }

  return (
    <div>
      <h2>Muuda kuulutust</h2>
      <ListingForm initial={initial} onSubmit={submit} />
    </div>
  );
}
