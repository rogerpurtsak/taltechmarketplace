import { useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { getListing, changeListingStatus } from '../api/listingsApi';
import LoadingState from '../components/LoadingState';

const STATUS_LABELS: Record<string,string> = {
  draft: 'Mustand', active: 'Aktiivne', reserved: 'Reserveeritud', sold: 'Müüdud', archived: 'Arhiveeritud'
};

export default function StatusChangeView(){
  const { id } = useParams();
  const nav = useNavigate();
  const [item, setItem] = useState<any>(null);
  const [status, setStatus] = useState<string>('draft');

  useEffect(()=>{ if(id) getListing(id).then(i=>{ setItem(i); setStatus(i.status); }).catch(()=>{}); },[id]);
  if(!item) return <LoadingState />;

  async function save(){
    try{ await changeListingStatus(id!, status as any); nav('/'); }catch(e){ alert('Viga: '+String(e)); }
  }

  return (
    <div>
      <h2>Muuda staatust — {item.title}</h2>
      <div>
        <select value={status} onChange={e=>setStatus(e.target.value)}>
          {Object.keys(STATUS_LABELS).map(s=> <option key={s} value={s}>{STATUS_LABELS[s]}</option>)}
        </select>
      </div>
      <div style={{marginTop:10}}>
        <button onClick={save}>Salvesta</button>
      </div>
    </div>
  );
}
