const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:3001';

export async function fetchJson(path: string, options?: RequestInit) {
  const res = await fetch(`${API_URL}/api${path}`, {
    headers: { 'Content-Type': 'application/json' },
    ...options,
  });
  if (!res.ok) {
    const text = await res.text();
    throw new Error(text || res.statusText);
  }
  return res.json();
}
