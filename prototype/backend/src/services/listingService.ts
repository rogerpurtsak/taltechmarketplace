import { pool } from '../db';
import { config } from '../config';
import { v4 as uuidv4 } from 'uuid';
import { mapListingRow } from '../utils/mappers';

const DEMO = config.demoSellerId;

if (!DEMO) {
  console.warn('DEMO_SELLER_ID is not set in config; listings endpoints will error until set.');
}

export async function findListingsForDemoSeller() {
  if (!DEMO) throw new Error('DEMO_SELLER_ID not configured');

  const q = `
    SELECT l.*, c.name AS category_name, lc.label AS condition_label,
      COALESCE(json_agg(li.public_url ORDER BY li.sort_order) FILTER (WHERE li.public_url IS NOT NULL), '[]') AS image_urls
    FROM listings l
    LEFT JOIN categories c ON l.category_id = c.id
    LEFT JOIN listing_conditions lc ON l.condition_id = lc.id
    LEFT JOIN listing_images li ON li.listing_id = l.id
    WHERE l.seller_id = $1
    GROUP BY l.id, c.name, lc.label
    ORDER BY l.updated_at DESC
  `;

  const result = await pool.query(q, [DEMO]);
  return result.rows.map(mapListingRow);
}

export async function findListingByIdForDemoSeller(id: string) {
  if (!DEMO) throw new Error('DEMO_SELLER_ID not configured');

  const q = `
    SELECT l.*, c.name AS category_name, lc.label AS condition_label,
      COALESCE(json_agg(li.public_url ORDER BY li.sort_order) FILTER (WHERE li.public_url IS NOT NULL), '[]') AS image_urls
    FROM listings l
    LEFT JOIN categories c ON l.category_id = c.id
    LEFT JOIN listing_conditions lc ON l.condition_id = lc.id
    LEFT JOIN listing_images li ON li.listing_id = l.id
    WHERE l.id = $1 AND l.seller_id = $2
    GROUP BY l.id, c.name, lc.label
  `;

  const result = await pool.query(q, [id, DEMO]);
  if (result.rowCount === 0) return null;
  return mapListingRow(result.rows[0]);
}

export async function createListing(payload: any) {
  if (!DEMO) throw new Error('DEMO_SELLER_ID not configured');

  const id = uuidv4();
  const {
    title,
    description,
    categoryId,
    conditionId,
    price,
    currency,
    isFree,
    locationText,
    pickupOnly,
    sizeText,
    imageUrl,
  } = payload;

  const finalPrice = isFree ? 0 : price;

  const q = `
    INSERT INTO listings (id, seller_id, category_id, condition_id, title, description, price, currency, is_free, status, location_text, pickup_only, size_text, created_at, updated_at)
    VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,'draft',$10,$11,$12,now(),now())
  `;

  await pool.query(q, [id, DEMO, categoryId, conditionId, title, description, finalPrice, currency, isFree, locationText, pickupOnly, sizeText]);

  if (imageUrl) {
    const qImg = `INSERT INTO listing_images (listing_id, storage_path, public_url, sort_order, created_at) VALUES ($1,$2,$3,0,now())`;
    await pool.query(qImg, [id, 'prototype/manual-url', imageUrl]);
  }

  return findListingByIdForDemoSeller(id);
}

export async function updateListing(id: string, payload: any) {
  if (!DEMO) throw new Error('DEMO_SELLER_ID not configured');

  // Ensure ownership
  const verify = await pool.query('SELECT id FROM listings WHERE id = $1 AND seller_id = $2', [id, DEMO]);
  if (verify.rowCount === 0) return null;

  const fields: string[] = [];
  const values: any[] = [];
  let idx = 1;

  const updatable = ['title','description','categoryId','conditionId','price','currency','isFree','locationText','pickupOnly','sizeText'];
  for (const key of updatable) {
    if (payload[key] !== undefined) {
      let col = key;
      switch (key) {
        case 'categoryId': col = 'category_id'; break;
        case 'conditionId': col = 'condition_id'; break;
        case 'locationText': col = 'location_text'; break;
        case 'pickupOnly': col = 'pickup_only'; break;
        case 'sizeText': col = 'size_text'; break;
        case 'isFree': col = 'is_free'; break;
        case 'currency': col = 'currency'; break;
        case 'price': col = 'price'; break;
      }
      fields.push(`${col} = $${idx}`);
      values.push(payload[key]);
      idx++;
    }
  }

  // price handling: if isFree true then set price = 0
  if (payload.isFree === true) {
    fields.push(`price = $${idx}`);
    values.push(0);
    idx++;
  }

  if (fields.length > 0) {
    fields.push(`updated_at = now()`);
    const q = `UPDATE listings SET ${fields.join(', ')} WHERE id = $${idx} AND seller_id = $${idx + 1}`;
    values.push(id, DEMO);
    await pool.query(q, values);
  }

  if (payload.imageUrl !== undefined) {
    // replace images simply
    await pool.query('DELETE FROM listing_images WHERE listing_id = $1', [id]);
    if (payload.imageUrl) {
      await pool.query('INSERT INTO listing_images (listing_id, storage_path, public_url, sort_order, created_at) VALUES ($1,$2,$3,0,now())', [id, 'prototype/manual-url', payload.imageUrl]);
    }
  }

  return findListingByIdForDemoSeller(id);
}

const ALLOWED_STATUSES = ['draft','active','reserved','sold','archived'];

export async function changeStatus(id: string, status: string) {
  if (!DEMO) throw new Error('DEMO_SELLER_ID not configured');
  if (!ALLOWED_STATUSES.includes(status)) throw new Error('Invalid status');

  const verify = await pool.query('SELECT id, published_at FROM listings WHERE id = $1 AND seller_id = $2', [id, DEMO]);
  if (verify.rowCount === 0) return null;
  const publishedAt = verify.rows[0].published_at;

  if (status === 'active' && !publishedAt) {
    await pool.query('UPDATE listings SET status = $1, published_at = now(), updated_at = now() WHERE id = $2 AND seller_id = $3', [status, id, DEMO]);
  } else {
    await pool.query('UPDATE listings SET status = $1, updated_at = now() WHERE id = $2 AND seller_id = $3', [status, id, DEMO]);
  }

  return findListingByIdForDemoSeller(id);
}
