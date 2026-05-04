-- ======================================================================
-- 08_invalid_data_tests.sql
-- ======================================================================
-- This file intentionally violates the database rules to prove that our 
-- constraints, domains, unique indexes, and triggers are working perfectly.
-- Every test should throw an ERROR.
-- ======================================================================

-- Test 1: Duplicate email (Should fail: UNIQUE constraint)
BEGIN;
INSERT INTO profiles (email, full_name, username) VALUES ('duplicate@taltech.ee', 'First User', 'user_one');
INSERT INTO profiles (email, full_name, username) VALUES ('duplicate@taltech.ee', 'Second User', 'user_two'); 
ROLLBACK;

-- Test 2: Empty username (Should fail: non_empty_text Domain rule)
BEGIN;
INSERT INTO profiles (email, full_name, username) VALUES ('new@taltech.ee', 'New Guy', '   '); 
ROLLBACK;

-- Test 3: Duplicate category slug (Should fail: UNIQUE constraint)
BEGIN;
INSERT INTO categories (name, slug, sort_order) VALUES ('Books', 'books-slug', 10);
INSERT INTO categories (name, slug, sort_order) VALUES ('Different Books', 'books-slug', 20);
ROLLBACK;

-- Test 4: Negative sort order (Should fail: CHECK sort_order >= 0)
BEGIN;
INSERT INTO categories (name, slug, sort_order) VALUES ('Invalid Category', 'invalid-cat', -5);
ROLLBACK;

-- Test 5: Duplicate listing condition code (Should fail: UNIQUE constraint)
BEGIN;
INSERT INTO listing_conditions (label, code_label, sort_order) VALUES ('Brand New', 'new', 10);
INSERT INTO listing_conditions (label, code_label, sort_order) VALUES ('Just New', 'new', 20);
ROLLBACK;

-- Test 6: Negative price (Should fail: price_amount Domain rule)
BEGIN;
INSERT INTO listings (seller_id, category_id, condition_id, title, description, price, location_text)
VALUES (
    '11111111-1111-1111-1111-111111111111', (SELECT id FROM categories LIMIT 1), (SELECT id FROM listing_conditions LIMIT 1), 
    'Test Item', 'Desc', -10.00, 'Tallinn'
);
ROLLBACK;

-- Test 7: Free item but price is greater than 0 (Should fail: Free Item CHECK rule)
BEGIN;
INSERT INTO listings (seller_id, category_id, condition_id, title, description, price, is_free, location_text)
VALUES (
    '11111111-1111-1111-1111-111111111111', (SELECT id FROM categories LIMIT 1), (SELECT id FROM listing_conditions LIMIT 1), 
    'Test Item', 'Desc', 15.00, true, 'Tallinn'
);
ROLLBACK;

-- Test 8: Invalid Listing Status (Should fail: Status CHECK rule)
BEGIN;
INSERT INTO listings (seller_id, category_id, condition_id, title, description, price, status, location_text)
VALUES (
    '11111111-1111-1111-1111-111111111111', (SELECT id FROM categories LIMIT 1), (SELECT id FROM listing_conditions LIMIT 1), 
    'Test Item', 'Desc', 15.00, 'magical_status', 'Tallinn'
);
ROLLBACK;

-- Test 9: Fake seller ID (Should fail: Foreign Key constraint)
BEGIN;
INSERT INTO listings (seller_id, category_id, condition_id, title, description, price, location_text)
VALUES (
    '99999999-9999-9999-9999-999999999999', (SELECT id FROM categories LIMIT 1), (SELECT id FROM listing_conditions LIMIT 1), 
    'Test Item', 'Desc', 15.00, 'Tallinn'
);
ROLLBACK;

-- Test 10: Duplicate Favorite (Should fail: Primary Key constraint on profile_id + listing_id)
BEGIN;
-- This exact combo was already inserted in 07_test_data.sql
INSERT INTO favorites (profile_id, listing_id)
VALUES ('22222222-2222-2222-2222-222222222222', '33333333-3333-3333-3333-333333333333');
ROLLBACK;

-- Test 11: Buyer and Seller are the same person in a chat (Should fail: CHECK buyer_id <> seller_id)
BEGIN;
INSERT INTO conversations (id, listing_id, buyer_id, seller_id)
VALUES (gen_random_uuid(), '33333333-3333-3333-3333-333333333333', '11111111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111');
ROLLBACK;

-- Test 12: Empty message content (Should fail: non_empty_text Domain rule)
BEGIN;
INSERT INTO messages (conversation_id, sender_id, content)
VALUES ('44444444-4444-4444-4444-444444444444', '22222222-2222-2222-2222-222222222222', '   ');
ROLLBACK;

-- Test 13: Sender is not part of the conversation (Should fail: Trigger rule from 05_triggers.sql)
BEGIN;
-- We create a random 3rd person who is not the buyer or seller
INSERT INTO profiles (id, email, full_name, username) VALUES ('66666666-6666-6666-6666-666666666666', 'stranger@taltech.ee', 'Stranger', 'stranger');
-- The stranger tries to send a message into Malle and Oskar's chat
INSERT INTO messages (conversation_id, sender_id, content)
VALUES ('44444444-4444-4444-4444-444444444444', '66666666-6666-6666-6666-666666666666', 'I am hacking your chat!');
ROLLBACK;

-- Test 14: Invalid Offer Status (Should fail: Status CHECK rule)
BEGIN;
INSERT INTO offers (listing_id, conversation_id, buyer_id, offered_price, status)
VALUES ('33333333-3333-3333-3333-333333333333', '44444444-4444-4444-4444-444444444444', '22222222-2222-2222-2222-222222222222', 10.00, 'super_accepted');
ROLLBACK;

-- Test 15: Buyer and Seller are the same in an Order (Should fail: CHECK buyer_id <> seller_id)
BEGIN;
INSERT INTO orders (listing_id, buyer_id, seller_id, final_price, delivery_method, payment_method)
VALUES ('33333333-3333-3333-3333-333333333333', '11111111-1111-1111-1111-111111111111', '11111111-1111-1111-1111-111111111111', 10.00, 'pickup', 'cash');
ROLLBACK;

-- Test 16: Invalid Order Status (Should fail: Status CHECK rule)
BEGIN;
INSERT INTO orders (listing_id, buyer_id, seller_id, final_price, delivery_method, payment_method, status)
VALUES ('33333333-3333-3333-3333-333333333333', '22222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', 10.00, 'pickup', 'cash', 'lost_in_transit');
ROLLBACK;

-- Test 17: Double Active Order for the same Listing (Should fail: Partial Unique Index from 03_indexes.sql)
BEGIN;
-- In 07_test_data, we already created a 'completed' order for listing 33333333...
-- Trying to create another active ('pending') order for the exact same item should be blocked!
INSERT INTO orders (listing_id, buyer_id, seller_id, final_price, delivery_method, payment_method, status)
VALUES ('33333333-3333-3333-3333-333333333333', '22222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', 10.00, 'pickup', 'cash', 'pending');
ROLLBACK;