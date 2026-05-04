-- ======================================================================
-- 07_test_data.sql
-- ======================================================================

-- 1. Create our two users (One Seller, One Buyer)
INSERT INTO profiles (id, email, full_name, username, is_verified_student)
VALUES 
('11111111-1111-1111-1111-111111111111', 'seller@taltech.ee', 'Malle Müüja', 'mallem', true),
('22222222-2222-2222-2222-222222222222', 'buyer@taltech.ee', 'Oskar Ostja', 'oskaro', true);

-- 2. Malle creates a Listing
-- We use a subquery (SELECT id...) to automatically grab whatever category and condition you created in step 06.
INSERT INTO listings (id, seller_id, category_id, condition_id, title, description, price, is_free, status, location_text, pickup_only)
VALUES (
    '33333333-3333-3333-3333-333333333333', 
    '11111111-1111-1111-1111-111111111111', -- Links to Malle
    (SELECT id FROM categories LIMIT 1),    
    (SELECT id FROM listing_conditions LIMIT 1), 
    'Calculus Textbook', 
    'Barely used math book for ITI0102', 
    15.00, 
    false, 
    'active', 
    'TalTech Library', 
    true
);

-- 3. Malle uploads an image for the textbook
INSERT INTO listing_images (listing_id, storage_path, sort_order)
VALUES ('33333333-3333-3333-3333-333333333333', '/images/calculus_book.jpg', 1);

-- 4. Oskar likes the book and adds it to his favorites
INSERT INTO favorites (profile_id, listing_id)
VALUES ('22222222-2222-2222-2222-222222222222', '33333333-3333-3333-3333-333333333333');

-- 5. Oskar opens a Conversation with Malle
INSERT INTO conversations (id, listing_id, buyer_id, seller_id)
VALUES (
    '44444444-4444-4444-4444-444444444444', 
    '33333333-3333-3333-3333-333333333333', -- Links to the book
    '22222222-2222-2222-2222-222222222222', -- Links to Oskar
    '11111111-1111-1111-1111-111111111111'  -- Links to Malle
);

-- 6. Oskar sends the first Message
INSERT INTO messages (conversation_id, sender_id, content)
VALUES ('44444444-4444-4444-4444-444444444444', '22222222-2222-2222-2222-222222222222', 'Hi! Is this book still available?');

-- 7. Oskar makes a formal Price Offer and Malle accepts it
INSERT INTO offers (
    id,
    listing_id,
    conversation_id,
    buyer_id,
    offered_price,
    status,
    responded_at
)
VALUES (
    '55555555-5555-5555-5555-555555555555',
    '33333333-3333-3333-3333-333333333333',
    '44444444-4444-4444-4444-444444444444',
    '22222222-2222-2222-2222-222222222222',
    12.00,
    'accepted',
    now()
);

-- 8. The offer is accepted, creating the final Order
INSERT INTO orders (
    listing_id,
    offer_id,
    buyer_id,
    seller_id,
    final_price,
    delivery_method,
    payment_method,
    status,
    confirmed_at,
    completed_at
)
VALUES (
    '33333333-3333-3333-3333-333333333333',
    '55555555-5555-5555-5555-555555555555',
    '22222222-2222-2222-2222-222222222222',
    '11111111-1111-1111-1111-111111111111',
    12.00,
    'pickup',
    'cash',
    'completed',
    now(),
    now()
);