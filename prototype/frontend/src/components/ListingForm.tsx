import { useEffect, useState } from 'react';
import { getCategories, getListingConditions } from '../api/listingsApi';
import { Category, ListingCondition } from '../types/marketplace';

export default function ListingForm({ initial, onSubmit }: { initial?: any; onSubmit: (v: any) => void; }) {
  const [title, setTitle] = useState(initial?.title || '');
  const [description, setDescription] = useState(initial?.description || '');
  const [categoryId, setCategoryId] = useState(initial?.categoryId || '');
  const [conditionId, setConditionId] = useState(initial?.conditionId || '');
  const [isFree, setIsFree] = useState(initial?.isFree || false);
  const [price, setPrice] = useState(initial?.price ?? 0);
  const [currency, setCurrency] = useState(initial?.currency || 'EUR');
  const [locationText, setLocationText] = useState(initial?.locationText || '');
  const [pickupOnly, setPickupOnly] = useState(initial?.pickupOnly || false);
  const [sizeText, setSizeText] = useState(initial?.sizeText || '');
  const [imageUrl, setImageUrl] = useState(initial?.imageUrls?.[0] || '');

  const [categories, setCategories] = useState<Category[]>([]);
  const [conditions, setConditions] = useState<ListingCondition[]>([]);

  useEffect(() => {
    getCategories().then(setCategories).catch(()=>{});
    getListingConditions().then(setConditions).catch(()=>{});
  }, []);

  function submit(e: any) {
    e.preventDefault();
    onSubmit({ title, description, categoryId, conditionId, isFree, price: Number(price), currency, locationText, pickupOnly, sizeText, imageUrl });
  }

  return (
    <form onSubmit={submit} className="listing-form">
      <label>Pealkiri*<input value={title} onChange={e=>setTitle(e.target.value)} required /></label>
      <label>Kirjeldus*<textarea value={description} onChange={e=>setDescription(e.target.value)} required /></label>
      <label>Kategooria*<select value={categoryId} onChange={e=>setCategoryId(e.target.value)} required>
        <option value="">— vali —</option>
        {categories.map(c=> <option key={c.id} value={c.id}>{c.name}</option>)}
      </select></label>
      <label>Seisund*<select value={conditionId} onChange={e=>setConditionId(e.target.value)} required>
        <option value="">— vali —</option>
        {conditions.map(c=> <option key={c.id} value={c.id}>{c.label}</option>)}
      </select></label>
      <label><input type="checkbox" checked={isFree} onChange={e=>setIsFree(e.target.checked)} /> Tasuta</label>
      <label>Hind*<input type="number" value={price} onChange={e=>setPrice(e.target.value)} min={0} disabled={isFree} required={!isFree} /></label>
      <label>Valuuta<input value={currency} onChange={e=>setCurrency(e.target.value)} /></label>
      <label>Asukoht*<input value={locationText} onChange={e=>setLocationText(e.target.value)} required /></label>
      <label><input type="checkbox" checked={pickupOnly} onChange={e=>setPickupOnly(e.target.checked)} /> Ainult järeletulemine</label>
      <label>Suurus / mõõt<input value={sizeText} onChange={e=>setSizeText(e.target.value)} /></label>
      <label>Pildi URL<input value={imageUrl} onChange={e=>setImageUrl(e.target.value)} /></label>
      <div className="form-actions"><button type="submit">Salvesta</button></div>
    </form>
  );
}
