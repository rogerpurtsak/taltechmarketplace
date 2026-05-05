import { fetchJson } from './client';
import { Listing, ListingStatus } from '../types/marketplace';

export async function getListings(): Promise<Listing[]> {
  return fetchJson('/listings');
}

export async function getListing(id: string): Promise<Listing> {
  return fetchJson(`/listings/${id}`);
}

export async function createListing(payload: any): Promise<Listing> {
  return fetchJson('/listings', { method: 'POST', body: JSON.stringify(payload) });
}

export async function updateListing(id: string, payload: any): Promise<Listing> {
  return fetchJson(`/listings/${id}`, { method: 'PUT', body: JSON.stringify(payload) });
}

export async function changeListingStatus(id: string, status: ListingStatus): Promise<Listing> {
  return fetchJson(`/listings/${id}/status`, { method: 'PATCH', body: JSON.stringify({ status }) });
}

export async function getCategories() {
  return fetchJson('/categories');
}

export async function getListingConditions() {
  return fetchJson('/listing-conditions');
}
