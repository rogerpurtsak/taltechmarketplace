-- seed_demo_data.sql
-- Prototüübi demoandmed — turvaline kordusjooksmine (ON CONFLICT DO NOTHING)
-- Demo müüja UUID: aaaaaaaa-aaaa-4aaa-aaaa-aaaaaaaaaaaa

-- 1. Demo müüja profiil
INSERT INTO profiles (id, email, full_name, username, taltech_email, is_verified_student, is_admin)
VALUES (
  'aaaaaaaa-aaaa-4aaa-aaaa-aaaaaaaaaaaa',
  'demo.seller@taltech.ee',
  'Roger Purtsak',
  'rogerpurtsak',
  'rogerpurtsak@taltech.ee',
  true,
  false
) ON CONFLICT DO NOTHING;

-- 2. Puuduvad seisundid (olemasolevad: new=10, very_good=20, used=30, worn=40)
INSERT INTO listing_conditions (label, code_label, sort_order)
VALUES
  ('Hea',             'good',         25),
  ('Vajab parandust', 'needs_repair', 45)
ON CONFLICT DO NOTHING;

-- 3. Demo kuulutused

-- MacBook Air M1 — Elektroonika, Väga hea, aktiivne
INSERT INTO listings (id, seller_id, category_id, condition_id, title, description, price, currency, is_free, status, location_text, pickup_only, published_at)
SELECT
  'dddddddd-dddd-4ddd-dddd-dddddddddd01'::uuid,
  'aaaaaaaa-aaaa-4aaa-aaaa-aaaaaaaaaaaa'::uuid,
  (SELECT id FROM categories WHERE slug = 'elektroonika'),
  (SELECT id FROM listing_conditions WHERE code_label = 'very_good'),
  'MacBook Air M1',
  'Heas korras sülearvuti, kasutatud 1 aasta. Komplektis laadija ja originaalkarp. Aku mahutavus 90%.',
  550.00, 'EUR', false, 'active', 'TalTech peamaja', true, now()
ON CONFLICT (id) DO NOTHING;

-- Programmeerimise õpik — Õppematerjalid, Hea, aktiivne
INSERT INTO listings (id, seller_id, category_id, condition_id, title, description, price, currency, is_free, status, location_text, pickup_only, published_at)
SELECT
  'dddddddd-dddd-4ddd-dddd-dddddddddd02'::uuid,
  'aaaaaaaa-aaaa-4aaa-aaaa-aaaaaaaaaaaa'::uuid,
  (SELECT id FROM categories WHERE slug = 'oppematerjalid'),
  (SELECT id FROM listing_conditions WHERE code_label = 'good'),
  'Programmeerimise õpik',
  'Clean Code — Robert C. Martin. Eestikeelsed märkmed sees. Sobib ITI0215 kursusele.',
  8.00, 'EUR', false, 'active', 'IT kolledž', true, now()
ON CONFLICT (id) DO NOTHING;

-- Laud — Mööbel, Kasutatud, mustand
INSERT INTO listings (id, seller_id, category_id, condition_id, title, description, price, currency, is_free, status, location_text, pickup_only)
SELECT
  'dddddddd-dddd-4ddd-dddd-dddddddddd03'::uuid,
  'aaaaaaaa-aaaa-4aaa-aaaa-aaaaaaaaaaaa'::uuid,
  (SELECT id FROM categories WHERE slug = 'moobel'),
  (SELECT id FROM listing_conditions WHERE code_label = 'used'),
  'Laud',
  'Valge kirjutuslaud, 120x60 cm. Mõned kriimustused, aga töötab hästi.',
  35.00, 'EUR', false, 'draft', 'Mustamäe', true
ON CONFLICT (id) DO NOTHING;

-- Jalgratas — Muu, Hea, reserveeritud
INSERT INTO listings (id, seller_id, category_id, condition_id, title, description, price, currency, is_free, status, location_text, pickup_only, published_at)
SELECT
  'dddddddd-dddd-4ddd-dddd-dddddddddd04'::uuid,
  'aaaaaaaa-aaaa-4aaa-aaaa-aaaaaaaaaaaa'::uuid,
  (SELECT id FROM categories WHERE slug = 'muu'),
  (SELECT id FROM listing_conditions WHERE code_label = 'good'),
  'Jalgratas',
  'Linnajalgratas, 28 tolli. Heas korras, regulaarselt hooldatud. Uued pidurid 2024.',
  120.00, 'EUR', false, 'reserved', 'TalTech spordikeskus', false, now()
ON CONFLICT (id) DO NOTHING;

-- Tasuta monitor — Elektroonika, Kasutatud, aktiivne, tasuta
INSERT INTO listings (id, seller_id, category_id, condition_id, title, description, price, currency, is_free, status, location_text, pickup_only, published_at)
SELECT
  'dddddddd-dddd-4ddd-dddd-dddddddddd05'::uuid,
  'aaaaaaaa-aaaa-4aaa-aaaa-aaaaaaaaaaaa'::uuid,
  (SELECT id FROM categories WHERE slug = 'elektroonika'),
  (SELECT id FROM listing_conditions WHERE code_label = 'used'),
  'Tasuta monitor',
  'Dell 24-tolline Full HD monitor. Töötab hästi, aga mul on uus. Järeltulek ise.',
  0.00, 'EUR', true, 'active', 'TalTech raamatukogu', false, now()
ON CONFLICT (id) DO NOTHING;

-- 4. Pildid MacBook'ile ja monitorile
INSERT INTO listing_images (listing_id, storage_path, public_url, sort_order)
VALUES (
  'dddddddd-dddd-4ddd-dddd-dddddddddd01',
  'prototype/manual-url',
  'https://images.unsplash.com/photo-1611186871348-b1ce696e52c9?w=800',
  0
) ON CONFLICT DO NOTHING;

INSERT INTO listing_images (listing_id, storage_path, public_url, sort_order)
VALUES (
  'dddddddd-dddd-4ddd-dddd-dddddddddd05',
  'prototype/manual-url',
  'https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?w=800',
  0
) ON CONFLICT DO NOTHING;
