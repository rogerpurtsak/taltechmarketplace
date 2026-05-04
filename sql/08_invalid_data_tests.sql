-- ======================================================================
-- 08_invalid_data_tests.sql
-- TalTech Marketplace invalid data tests
--
-- This file is safe to run with Alt + X in DBeaver.
-- Every test intentionally tries to violate one database rule.
-- If the database rejects the invalid data, the test prints NOTICE.
-- If invalid data is unexpectedly accepted, the test raises an ERROR.
-- ======================================================================


-- Test 1: Duplicate email must fail because profiles.email is UNIQUE.
DO $$
BEGIN
    BEGIN
        INSERT INTO profiles (email, full_name, username)
        SELECT
            email,
            'Duplicate Email User',
            'duplicate_email_user_' || substr(replace(gen_random_uuid()::text, '-', ''), 1, 8)
        FROM profiles
        LIMIT 1;

        RAISE EXCEPTION 'TEST 1 FAILED: duplicate email was accepted.';
    EXCEPTION
        WHEN unique_violation THEN
            RAISE NOTICE 'TEST 1 PASSED: duplicate email was rejected.';
    END;
END;
$$;


-- Test 2: Empty username must fail because non_empty_text does not allow empty or blank text.
DO $$
BEGIN
    BEGIN
        INSERT INTO profiles (email, full_name, username)
        VALUES (
            'empty_username_' || substr(replace(gen_random_uuid()::text, '-', ''), 1, 8) || '@taltech.ee',
            'Empty Username User',
            '   '
        );

        RAISE EXCEPTION 'TEST 2 FAILED: empty username was accepted.';
    EXCEPTION
        WHEN check_violation THEN
            RAISE NOTICE 'TEST 2 PASSED: empty username was rejected.';
    END;
END;
$$;


-- Test 3: Duplicate category slug must fail because categories.slug is UNIQUE.
DO $$
BEGIN
    BEGIN
        INSERT INTO categories (name, slug, sort_order)
        SELECT
            'Duplicate Slug Category ' || substr(replace(gen_random_uuid()::text, '-', ''), 1, 8),
            slug,
            999
        FROM categories
        LIMIT 1;

        RAISE EXCEPTION 'TEST 3 FAILED: duplicate category slug was accepted.';
    EXCEPTION
        WHEN unique_violation THEN
            RAISE NOTICE 'TEST 3 PASSED: duplicate category slug was rejected.';
    END;
END;
$$;


-- Test 4: Negative category sort_order must fail because sort_order >= 0.
DO $$
BEGIN
    BEGIN
        INSERT INTO categories (name, slug, sort_order)
        VALUES (
            'Invalid Category ' || substr(replace(gen_random_uuid()::text, '-', ''), 1, 8),
            'invalid-category-' || substr(replace(gen_random_uuid()::text, '-', ''), 1, 8),
            -5
        );

        RAISE EXCEPTION 'TEST 4 FAILED: negative category sort_order was accepted.';
    EXCEPTION
        WHEN check_violation THEN
            RAISE NOTICE 'TEST 4 PASSED: negative category sort_order was rejected.';
    END;
END;
$$;


-- Test 5: Duplicate listing condition code_label must fail because listing_conditions.code_label is UNIQUE.
DO $$
BEGIN
    BEGIN
        INSERT INTO listing_conditions (label, code_label, sort_order)
        SELECT
            'Duplicate Condition ' || substr(replace(gen_random_uuid()::text, '-', ''), 1, 8),
            code_label,
            999
        FROM listing_conditions
        LIMIT 1;

        RAISE EXCEPTION 'TEST 5 FAILED: duplicate listing condition code_label was accepted.';
    EXCEPTION
        WHEN unique_violation THEN
            RAISE NOTICE 'TEST 5 PASSED: duplicate listing condition code_label was rejected.';
    END;
END;
$$;


-- Test 6: Negative listing price must fail because price_amount requires VALUE >= 0.
DO $$
BEGIN
    BEGIN
        INSERT INTO listings (
            seller_id,
            category_id,
            condition_id,
            title,
            description,
            price,
            is_free,
            status,
            location_text,
            pickup_only
        )
        SELECT
            p.id,
            c.id,
            lc.id,
            'Invalid Negative Price Listing',
            'This listing should not be saved.',
            -10.00,
            false,
            'draft',
            'TalTech',
            true
        FROM profiles p
        CROSS JOIN categories c
        CROSS JOIN listing_conditions lc
        WHERE p.username = 'mallem'
        LIMIT 1;

        RAISE EXCEPTION 'TEST 6 FAILED: negative listing price was accepted.';
    EXCEPTION
        WHEN check_violation THEN
            RAISE NOTICE 'TEST 6 PASSED: negative listing price was rejected.';
    END;
END;
$$;


-- Test 7: Free item with price greater than 0 must fail.
DO $$
BEGIN
    BEGIN
        INSERT INTO listings (
            seller_id,
            category_id,
            condition_id,
            title,
            description,
            price,
            is_free,
            status,
            location_text,
            pickup_only
        )
        SELECT
            p.id,
            c.id,
            lc.id,
            'Invalid Free Listing',
            'This listing should not be saved.',
            15.00,
            true,
            'draft',
            'TalTech',
            true
        FROM profiles p
        CROSS JOIN categories c
        CROSS JOIN listing_conditions lc
        WHERE p.username = 'mallem'
        LIMIT 1;

        RAISE EXCEPTION 'TEST 7 FAILED: free item with price greater than 0 was accepted.';
    EXCEPTION
        WHEN check_violation THEN
            RAISE NOTICE 'TEST 7 PASSED: free item with price greater than 0 was rejected.';
    END;
END;
$$;


-- Test 8: Invalid listing status must fail.
DO $$
BEGIN
    BEGIN
        INSERT INTO listings (
            seller_id,
            category_id,
            condition_id,
            title,
            description,
            price,
            is_free,
            status,
            location_text,
            pickup_only
        )
        SELECT
            p.id,
            c.id,
            lc.id,
            'Invalid Status Listing',
            'This listing should not be saved.',
            15.00,
            false,
            'magical_status',
            'TalTech',
            true
        FROM profiles p
        CROSS JOIN categories c
        CROSS JOIN listing_conditions lc
        WHERE p.username = 'mallem'
        LIMIT 1;

        RAISE EXCEPTION 'TEST 8 FAILED: invalid listing status was accepted.';
    EXCEPTION
        WHEN check_violation THEN
            RAISE NOTICE 'TEST 8 PASSED: invalid listing status was rejected.';
    END;
END;
$$;


-- Test 9: Fake seller_id must fail because listings.seller_id has a foreign key.
DO $$
BEGIN
    BEGIN
        INSERT INTO listings (
            seller_id,
            category_id,
            condition_id,
            title,
            description,
            price,
            is_free,
            status,
            location_text,
            pickup_only
        )
        SELECT
            '99999999-9999-9999-9999-999999999999',
            c.id,
            lc.id,
            'Invalid Seller Listing',
            'This listing should not be saved.',
            15.00,
            false,
            'draft',
            'TalTech',
            true
        FROM categories c
        CROSS JOIN listing_conditions lc
        LIMIT 1;

        RAISE EXCEPTION 'TEST 9 FAILED: fake seller_id was accepted.';
    EXCEPTION
        WHEN foreign_key_violation THEN
            RAISE NOTICE 'TEST 9 PASSED: fake seller_id was rejected.';
    END;
END;
$$;


-- Test 10: Duplicate favorite must fail because favorites has PRIMARY KEY (profile_id, listing_id).
DO $$
BEGIN
    BEGIN
        INSERT INTO favorites (profile_id, listing_id)
        VALUES (
            '22222222-2222-2222-2222-222222222222',
            '33333333-3333-3333-3333-333333333333'
        );

        RAISE EXCEPTION 'TEST 10 FAILED: duplicate favorite was accepted.';
    EXCEPTION
        WHEN unique_violation THEN
            RAISE NOTICE 'TEST 10 PASSED: duplicate favorite was rejected.';
    END;
END;
$$;


-- Test 11: Buyer and seller cannot be the same person in conversations.
DO $$
BEGIN
    BEGIN
        INSERT INTO conversations (
            id,
            listing_id,
            buyer_id,
            seller_id
        )
        VALUES (
            gen_random_uuid(),
            '33333333-3333-3333-3333-333333333333',
            '11111111-1111-1111-1111-111111111111',
            '11111111-1111-1111-1111-111111111111'
        );

        RAISE EXCEPTION 'TEST 11 FAILED: conversation with same buyer and seller was accepted.';
    EXCEPTION
        WHEN check_violation THEN
            RAISE NOTICE 'TEST 11 PASSED: conversation with same buyer and seller was rejected.';
    END;
END;
$$;


-- Test 12: Empty message content must fail because content uses non_empty_text.
DO $$
BEGIN
    BEGIN
        INSERT INTO messages (
            conversation_id,
            sender_id,
            content
        )
        VALUES (
            '44444444-4444-4444-4444-444444444444',
            '22222222-2222-2222-2222-222222222222',
            '   '
        );

        RAISE EXCEPTION 'TEST 12 FAILED: empty message content was accepted.';
    EXCEPTION
        WHEN check_violation THEN
            RAISE NOTICE 'TEST 12 PASSED: empty message content was rejected.';
    END;
END;
$$;


-- Test 13: Message with is_read = false and read_at filled must fail.
DO $$
BEGIN
    BEGIN
        INSERT INTO messages (
            conversation_id,
            sender_id,
            content,
            is_read,
            read_at
        )
        VALUES (
            '44444444-4444-4444-4444-444444444444',
            '22222222-2222-2222-2222-222222222222',
            'This invalid message should not be saved.',
            false,
            now()
        );

        RAISE EXCEPTION 'TEST 13 FAILED: unread message with read_at was accepted.';
    EXCEPTION
        WHEN check_violation THEN
            RAISE NOTICE 'TEST 13 PASSED: unread message with read_at was rejected.';
    END;
END;
$$;


-- Test 14: Invalid offer status must fail.
DO $$
BEGIN
    BEGIN
        INSERT INTO offers (
            listing_id,
            conversation_id,
            buyer_id,
            offered_price,
            status
        )
        VALUES (
            '33333333-3333-3333-3333-333333333333',
            '44444444-4444-4444-4444-444444444444',
            '22222222-2222-2222-2222-222222222222',
            10.00,
            'super_accepted'
        );

        RAISE EXCEPTION 'TEST 14 FAILED: invalid offer status was accepted.';
    EXCEPTION
        WHEN check_violation THEN
            RAISE NOTICE 'TEST 14 PASSED: invalid offer status was rejected.';
    END;
END;
$$;


-- Test 15: Accepted offer without responded_at must fail.
DO $$
BEGIN
    BEGIN
        INSERT INTO offers (
            listing_id,
            conversation_id,
            buyer_id,
            offered_price,
            status
        )
        VALUES (
            '33333333-3333-3333-3333-333333333333',
            '44444444-4444-4444-4444-444444444444',
            '22222222-2222-2222-2222-222222222222',
            10.00,
            'accepted'
        );

        RAISE EXCEPTION 'TEST 15 FAILED: accepted offer without responded_at was accepted.';
    EXCEPTION
        WHEN check_violation THEN
            RAISE NOTICE 'TEST 15 PASSED: accepted offer without responded_at was rejected.';
    END;
END;
$$;


-- Test 16: Buyer and seller cannot be the same person in orders.
DO $$
BEGIN
    BEGIN
        INSERT INTO orders (
            listing_id,
            buyer_id,
            seller_id,
            final_price,
            delivery_method,
            payment_method,
            status
        )
        VALUES (
            '33333333-3333-3333-3333-333333333333',
            '11111111-1111-1111-1111-111111111111',
            '11111111-1111-1111-1111-111111111111',
            10.00,
            'pickup',
            'cash',
            'pending'
        );

        RAISE EXCEPTION 'TEST 16 FAILED: order with same buyer and seller was accepted.';
    EXCEPTION
        WHEN check_violation THEN
            RAISE NOTICE 'TEST 16 PASSED: order with same buyer and seller was rejected.';
    END;
END;
$$;


-- Test 17: Invalid order status must fail.
DO $$
BEGIN
    BEGIN
        INSERT INTO orders (
            listing_id,
            buyer_id,
            seller_id,
            final_price,
            delivery_method,
            payment_method,
            status
        )
        VALUES (
            '33333333-3333-3333-3333-333333333333',
            '22222222-2222-2222-2222-222222222222',
            '11111111-1111-1111-1111-111111111111',
            10.00,
            'pickup',
            'cash',
            'lost_in_transit'
        );

        RAISE EXCEPTION 'TEST 17 FAILED: invalid order status was accepted.';
    EXCEPTION
        WHEN check_violation THEN
            RAISE NOTICE 'TEST 17 PASSED: invalid order status was rejected.';
    END;
END;
$$;


-- Test 18: Completed order without confirmed_at and completed_at must fail.
DO $$
BEGIN
    BEGIN
        INSERT INTO orders (
            listing_id,
            buyer_id,
            seller_id,
            final_price,
            delivery_method,
            payment_method,
            status
        )
        VALUES (
            '33333333-3333-3333-3333-333333333333',
            '22222222-2222-2222-2222-222222222222',
            '11111111-1111-1111-1111-111111111111',
            10.00,
            'pickup',
            'cash',
            'completed'
        );

        RAISE EXCEPTION 'TEST 18 FAILED: completed order without timestamps was accepted.';
    EXCEPTION
        WHEN check_violation THEN
            RAISE NOTICE 'TEST 18 PASSED: completed order without timestamps was rejected.';
    END;
END;
$$;


-- Test 19: Listing image with duplicate sort_order for the same listing must fail.
DO $$
BEGIN
    BEGIN
        INSERT INTO listing_images (
            listing_id,
            storage_path,
            sort_order
        )
        VALUES (
            '33333333-3333-3333-3333-333333333333',
            '/images/duplicate_sort_order.jpg',
            1
        );

        RAISE EXCEPTION 'TEST 19 FAILED: duplicate listing image sort_order was accepted.';
    EXCEPTION
        WHEN unique_violation THEN
            RAISE NOTICE 'TEST 19 PASSED: duplicate listing image sort_order was rejected.';
    END;
END;
$$;


-- ======================================================================
-- End of invalid data tests.
-- If all tests print PASSED notices, the database constraints work.
-- ======================================================================