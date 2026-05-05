import { ListingStatus } from '../types/marketplace';

const labels: Record<ListingStatus, string> = {
  draft: 'Mustand',
  active: 'Aktiivne',
  reserved: 'Reserveeritud',
  sold: 'Müüdud',
  archived: 'Arhiveeritud',
};

export default function StatusBadge({ status }: { status: ListingStatus }) {
  return <span className={`status-badge status-${status}`}>{labels[status]}</span>;
}
