export function validateListingPayload(payload: any, isCreate: boolean) {
  if (!payload) return { ok: false, error: 'Payload puudub' };
  const required = ['title','description','categoryId','conditionId','locationText'];
  for (const f of required) {
    if (isCreate && !payload[f]) return { ok: false, error: `${f} on kohustuslik` };
  }

  if (payload.isFree === undefined && isCreate) return { ok: false, error: 'isFree on kohustuslik' };

  if (payload.isFree === true) {
    // price should be 0 or ignored
  } else {
    if (isCreate && (payload.price === undefined || Number(payload.price) <= 0)) return { ok: false, error: 'Hind peab olema suurem kui 0 kui ei ole tasuta' };
  }

  return { ok: true };
}

export function validateStatusPayload(payload: any) {
  if (!payload || !payload.status) return { ok: false, error: 'status on kohustuslik' };
  const allowed = ['draft','active','reserved','sold','archived'];
  if (!allowed.includes(payload.status)) return { ok: false, error: 'Keelatud staatuse väärtus' };
  return { ok: true };
}
