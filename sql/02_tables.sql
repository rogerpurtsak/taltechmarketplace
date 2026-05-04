-- 02_tables.sql
-- taltech marketplace create tables
-- run after 01_domains.sql

CREATE TABLE profiles (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    email non_empty_text NOT NULL UNIQUE,
    full_name non_empty_text NOT NULL,
    username non_empty_text NOT NULL UNIQUE,
    taltech_email text UNIQUE,

    is_verified_student boolean NOT NULL DEFAULT false,
    avatar_url text,
    bio text,
    is_admin boolean NOT NULL DEFAULT false,

    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT chk_profiles_taltech_email_domain
        CHECK (
            taltech_email IS NULL
            OR lower(taltech_email) LIKE '%@taltech.ee'
        )
);

CREATE TABLE categories (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    parent_id uuid,
    name non_empty_text NOT NULL UNIQUE,
    slug non_empty_text NOT NULL UNIQUE,
    sort_order integer NOT NULL DEFAULT 0,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT fk_categories_parent
        FOREIGN KEY (parent_id)
        REFERENCES categories (id)
        ON DELETE SET NULL,

    CONSTRAINT chk_categories_sort_order
        CHECK (sort_order >= 0),

    CONSTRAINT chk_categories_not_own_parent
        CHECK (parent_id IS NULL OR parent_id <> id)
);

CREATE TABLE listing_conditions (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    label non_empty_text NOT NULL UNIQUE,
    code_label non_empty_text NOT NULL UNIQUE,
    sort_order integer NOT NULL DEFAULT 0,

    CONSTRAINT chk_listing_conditions_sort_order
        CHECK (sort_order >= 0)
);

CREATE TABLE listings (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    seller_id uuid NOT NULL,
    category_id uuid NOT NULL,
    condition_id uuid NOT NULL,

    title non_empty_text NOT NULL,
    description non_empty_text NOT NULL,
    price price_amount NOT NULL,
    currency currency_code NOT NULL DEFAULT 'EUR',
    is_free boolean NOT NULL DEFAULT false,
    status text NOT NULL DEFAULT 'draft',

    location_text non_empty_text NOT NULL,
    pickup_only boolean NOT NULL DEFAULT true,
    size_text text,

    published_at timestamptz,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT fk_listings_seller
        FOREIGN KEY (seller_id)
        REFERENCES profiles (id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_listings_category
        FOREIGN KEY (category_id)
        REFERENCES categories (id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_listings_condition
        FOREIGN KEY (condition_id)
        REFERENCES listing_conditions (id)
        ON DELETE RESTRICT,

    CONSTRAINT chk_listings_status
        CHECK (status IN ('draft', 'active', 'reserved', 'sold', 'archived')),

    CONSTRAINT chk_listings_free_price
        CHECK (
            (is_free = true AND price = 0)
            OR
            (is_free = false AND price > 0)
        )
);

CREATE TABLE listing_images (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    listing_id uuid NOT NULL,
    storage_path non_empty_text NOT NULL,
    public_url text,
    sort_order integer NOT NULL DEFAULT 0,
    created_at timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT fk_listing_images_listing
        FOREIGN KEY (listing_id)
        REFERENCES listings (id)
        ON DELETE CASCADE,

    CONSTRAINT chk_listing_images_sort_order
        CHECK (sort_order >= 0),

    -- so the pictures wont have the same sort order number in the same listing
    CONSTRAINT uq_listing_images_listing_sort_order
        UNIQUE (listing_id, sort_order)
);

CREATE TABLE favorites (
    profile_id uuid NOT NULL,
    listing_id uuid NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),

    CONSTRAINT pk_favorites
        PRIMARY KEY (profile_id, listing_id),

    CONSTRAINT fk_favorites_profile
        FOREIGN KEY (profile_id)
        REFERENCES profiles (id)
        ON DELETE CASCADE,

    CONSTRAINT fk_favorites_listing
        FOREIGN KEY (listing_id)
        REFERENCES listings (id)
        ON DELETE CASCADE
);

CREATE TABLE conversations (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    listing_id uuid NOT NULL,
    buyer_id uuid NOT NULL,
    seller_id uuid NOT NULL,

    created_at timestamptz NOT NULL DEFAULT now(),
    last_message_at timestamptz,

    CONSTRAINT fk_conversations_listing
        FOREIGN KEY (listing_id)
        REFERENCES listings (id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_conversations_buyer
        FOREIGN KEY (buyer_id)
        REFERENCES profiles (id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_conversations_seller
        FOREIGN KEY (seller_id)
        REFERENCES profiles (id)
        ON DELETE RESTRICT,

    CONSTRAINT chk_conversations_buyer_not_seller
        CHECK (buyer_id <> seller_id),

    CONSTRAINT uq_conversations_listing_buyer
        UNIQUE (listing_id, buyer_id)
);

CREATE TABLE messages (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    conversation_id uuid NOT NULL,
    sender_id uuid NOT NULL,

    content non_empty_text NOT NULL,
    is_read boolean NOT NULL DEFAULT false,
    sent_at timestamptz NOT NULL DEFAULT now(),
    read_at timestamptz,

    CONSTRAINT fk_messages_conversation
        FOREIGN KEY (conversation_id)
        REFERENCES conversations (id)
        ON DELETE CASCADE,

    CONSTRAINT fk_messages_sender
        FOREIGN KEY (sender_id)
        REFERENCES profiles (id)
        ON DELETE RESTRICT,

    CONSTRAINT chk_messages_read_at
        CHECK (
            (is_read = false AND read_at IS NULL)
            OR
            (is_read = true)
        )
);

CREATE TABLE offers (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    listing_id uuid NOT NULL,
    conversation_id uuid NOT NULL,
    buyer_id uuid NOT NULL,

    offered_price price_amount NOT NULL,
    status text NOT NULL DEFAULT 'pending',

    created_at timestamptz NOT NULL DEFAULT now(),
    responded_at timestamptz,

    CONSTRAINT fk_offers_listing
        FOREIGN KEY (listing_id)
        REFERENCES listings (id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_offers_conversation
        FOREIGN KEY (conversation_id)
        REFERENCES conversations (id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_offers_buyer
        FOREIGN KEY (buyer_id)
        REFERENCES profiles (id)
        ON DELETE RESTRICT,

    CONSTRAINT chk_offers_status
        CHECK (status IN ('pending', 'accepted', 'rejected', 'cancelled')),

    CONSTRAINT chk_offers_price_positive
        CHECK (offered_price > 0),

    CONSTRAINT chk_offers_responded_at
        CHECK (
            (status = 'pending' AND responded_at IS NULL)
            OR
            (status <> 'pending' AND responded_at IS NOT NULL)
        )
);

CREATE TABLE orders (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    offer_id uuid,
    listing_id uuid NOT NULL,
    buyer_id uuid NOT NULL,
    seller_id uuid NOT NULL,

    final_price price_amount NOT NULL,
    currency currency_code NOT NULL DEFAULT 'EUR',
    delivery_method non_empty_text NOT NULL,
    payment_method non_empty_text NOT NULL,
    status text NOT NULL DEFAULT 'pending',

    notes text,

    created_at timestamptz NOT NULL DEFAULT now(),
    confirmed_at timestamptz,
    completed_at timestamptz,
    cancelled_at timestamptz,

    CONSTRAINT fk_orders_offer
        FOREIGN KEY (offer_id)
        REFERENCES offers (id)
        ON DELETE SET NULL,

    CONSTRAINT fk_orders_listing
        FOREIGN KEY (listing_id)
        REFERENCES listings (id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_orders_buyer
        FOREIGN KEY (buyer_id)
        REFERENCES profiles (id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_orders_seller
        FOREIGN KEY (seller_id)
        REFERENCES profiles (id)
        ON DELETE RESTRICT,

    CONSTRAINT chk_orders_status
        CHECK (status IN ('pending', 'confirmed', 'completed', 'cancelled')),

    CONSTRAINT chk_orders_buyer_not_seller
        CHECK (buyer_id <> seller_id),

    CONSTRAINT chk_orders_final_price_positive
        CHECK (final_price > 0),

    CONSTRAINT chk_orders_confirmed_at
        CHECK (
            (status IN ('pending', 'cancelled') AND confirmed_at IS NULL)
            OR
            (status IN ('confirmed', 'completed') AND confirmed_at IS NOT NULL)
        ),

    CONSTRAINT chk_orders_completed_at
        CHECK (
            (status <> 'completed' AND completed_at IS NULL)
            OR
            (status = 'completed' AND completed_at IS NOT NULL)
        ),

    CONSTRAINT chk_orders_cancelled_at
        CHECK (
            (status <> 'cancelled' AND cancelled_at IS NULL)
            OR
            (status = 'cancelled' AND cancelled_at IS NOT NULL)
        )
);