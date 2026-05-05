import { useNavigate } from 'react-router-dom';
import ListingForm from '../components/ListingForm';
import { createListing } from '../api/listingsApi';

export default function ListingCreateView() {
  const nav = useNavigate();

  async function submit(v: any) {
    try {
      await createListing(v);
      nav('/');
    } catch (err) {
      alert('Salvestus ebaõnnestus: ' + String(err));
    }
  }

  return (
    <div>
      <h2>Lisa uus kuulutus</h2>
      <ListingForm onSubmit={submit} />
    </div>
  );
}
