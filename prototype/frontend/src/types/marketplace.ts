export type ListingStatus = 'draft' | 'active' | 'reserved' | 'sold' | 'archived';

export interface Category {
  id: string;
  name: string;
  slug?: string;
}

export interface ListingCondition {
  id: string;
  label: string;
  codeLabel?: string;
}

export interface Listing {
  id: string;
  sellerId: string;
  title: string;
  description: string;
  categoryId: string;
  categoryName?: string | null;
  conditionId: string;
  conditionLabel?: string | null;
  price: number;
  currency: string;
  isFree: boolean;
  status: ListingStatus;
  locationText: string;
  pickupOnly: boolean;
  sizeText?: string | null;
  imageUrls: string[];
  createdAt: string | null;
  updatedAt: string | null;
  publishedAt?: string | null;
}
