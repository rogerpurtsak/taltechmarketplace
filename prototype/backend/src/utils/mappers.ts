export function mapListingRow(row: any) {
  return {
    id: row.id,
    sellerId: row.seller_id,
    title: row.title,
    description: row.description,
    categoryId: row.category_id,
    categoryName: row.category_name || null,
    conditionId: row.condition_id,
    conditionLabel: row.condition_label || null,
    price: row.price ? Number(row.price) : 0,
    currency: row.currency,
    isFree: !!row.is_free,
    status: row.status,
    locationText: row.location_text,
    pickupOnly: !!row.pickup_only,
    sizeText: row.size_text ?? null,
    imageUrls: Array.isArray(row.image_urls) ? row.image_urls.filter(Boolean) : [],
    createdAt: row.created_at ? new Date(row.created_at).toISOString() : null,
    updatedAt: row.updated_at ? new Date(row.updated_at).toISOString() : null,
    publishedAt: row.published_at ? new Date(row.published_at).toISOString() : null,
  };
}
