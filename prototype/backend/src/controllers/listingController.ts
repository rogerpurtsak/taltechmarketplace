import { Request, Response } from 'express';
import * as listingService from '../services/listingService';
import { validateListingPayload, validateStatusPayload } from '../utils/validation';

export async function listListings(_req: Request, res: Response) {
  try {
    const listings = await listingService.findListingsForDemoSeller();
    res.json(listings);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Andmebaasiviga' });
  }
}

export async function getListing(req: Request, res: Response) {
  try {
    const id = req.params.id;
    const listing = await listingService.findListingByIdForDemoSeller(id);
    if (!listing) return res.status(404).json({ error: 'Kuulutust ei leitud' });
    res.json(listing);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Andmebaasiviga' });
  }
}

export async function createListing(req: Request, res: Response) {
  try {
    const payload = req.body;
    const validation = validateListingPayload(payload, true);
    if (!validation.ok) return res.status(400).json({ error: validation.error });

    const created = await listingService.createListing(payload);
    res.status(201).json(created);
  } catch (err: any) {
    console.error(err);
    res.status(500).json({ error: 'Andmebaasiviga' });
  }
}

export async function updateListing(req: Request, res: Response) {
  try {
    const id = req.params.id;
    const payload = req.body;
    const validation = validateListingPayload(payload, false);
    if (!validation.ok) return res.status(400).json({ error: validation.error });

    const updated = await listingService.updateListing(id, payload);
    if (!updated) return res.status(404).json({ error: 'Kuulutust ei leitud või ei kuulu demo müüjale' });
    res.json(updated);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Andmebaasiviga' });
  }
}

export async function changeListingStatus(req: Request, res: Response) {
  try {
    const id = req.params.id;
    const payload = req.body;
    const validation = validateStatusPayload(payload);
    if (!validation.ok) return res.status(400).json({ error: validation.error });

    const updated = await listingService.changeStatus(id, payload.status);
    if (!updated) return res.status(404).json({ error: 'Kuulutust ei leitud või ei kuulu demo müüjale' });
    res.json(updated);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Andmebaasiviga' });
  }
}
