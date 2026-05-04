-- ======================================================================
-- 04_views.sql
-- ======================================================================

-- ======================================================================
-- WHAT IS A DATABASE VIEW?
-- A database view is a saved, virtual table that acts as a custom window 
-- into your data by pre-combining information from multiple physical tables. 
-- For example, instead of writing a complex SQL query every time you want 
-- to display an item, you can create a view like v_listing_details that 
-- automatically stitches the raw listing data together with the human-readable 
-- category name and the seller's actual username. Ultimately, views simplify 
-- application development by hiding this complex joining logic and providing 
-- your frontend system with clean, ready-to-use data instantly.
-- ======================================================================

-- 1. Seller's Listings View (v_seller_listings)
-- Purpose: Powers the "My Listings" screen for a seller.
-- It combines the listing data with the human-readable category and condition names, 
-- and counts how many images the listing has.
CREATE OR REPLACE VIEW v_seller_listings AS
SELECT
    l.id AS listing_id,
    l.seller_id,
    l.title,
    l.price,
    l.currency,
    l.is_free,
    l.status,
    c.name AS category_name, 
    lc.label AS condition_label,
    l.created_at,
    l.updated_at,
    (SELECT COUNT(*) FROM listing_images li WHERE li.listing_id = l.id) AS image_count
FROM listings l
JOIN categories c ON l.category_id = c.id
JOIN listing_conditions lc ON l.condition_id = lc.id;

-- 2. Listing Details View (v_listing_details)
-- Purpose: Powers the detailed page when someone clicks on a specific item.
-- It brings in all the details, plus the seller's actual username and full name.
CREATE OR REPLACE VIEW v_listing_details AS
SELECT
    l.id AS listing_id,
    l.title,
    l.description,
    l.price,
    l.currency,
    l.is_free,
    l.status,
    l.location_text,
    l.pickup_only,
    l.size_text,
    c.name AS category_name,
    lc.label AS condition_label,
    p.username AS seller_username,
    p.full_name AS seller_full_name
FROM listings l
JOIN categories c ON l.category_id = c.id
JOIN listing_conditions lc ON l.condition_id = lc.id
JOIN profiles p ON l.seller_id = p.id;

-- 3. Public Active Listings (v_active_listings_public)
-- Purpose: Powers the main public browsing page. 
CREATE OR REPLACE VIEW v_active_listings_public AS
SELECT
    l.id AS listing_id,
    l.title,
    l.price,
    l.currency,
    l.is_free,
    c.name AS category_name,
    lc.label AS condition_label,
    p.username AS seller_username,
    l.created_at
FROM listings l
JOIN categories c ON l.category_id = c.id
JOIN listing_conditions lc ON l.condition_id = lc.id
JOIN profiles p ON l.seller_id = p.id
WHERE l.status = 'active';

-- 4. Conversation Overview (v_conversation_overview)
-- Purpose: Powers the user's Inbox screen.
CREATE OR REPLACE VIEW v_conversation_overview AS
SELECT
    conv.id AS conversation_id,
    l.title AS listing_title,
    buyer.username AS buyer_username,
    seller.username AS seller_username,
    conv.last_message_at,
    (SELECT COUNT(*) FROM messages m WHERE m.conversation_id = conv.id) AS message_count
FROM conversations conv
JOIN listings l ON conv.listing_id = l.id
JOIN profiles buyer ON conv.buyer_id = buyer.id
JOIN profiles seller ON conv.seller_id = seller.id;

-- 5. Order Overview (v_order_overview)
-- Purpose: Powers the "My Purchases / My Sales" transaction history screen.
CREATE OR REPLACE VIEW v_order_overview AS
SELECT
    o.id AS order_id,
    l.title AS listing_title,
    buyer.username AS buyer_username,
    seller.username AS seller_username,
    o.final_price,
    o.currency,
    o.status,
    o.created_at
FROM orders o
JOIN listings l ON o.listing_id = l.id
JOIN profiles buyer ON o.buyer_id = buyer.id
JOIN profiles seller ON o.seller_id = seller.id;