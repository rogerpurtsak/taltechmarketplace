CREATE TABLE profiles (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    email non_empty_text UNIQUE NOT NULL,
    full_name non_empty_text NOT NULL,
    username non_empty_text UNIQUE NOT NULL,
    taltech_email text UNIQUE,

    is_verified_student boolean NOT NULL DEFAULT false,
    avatar_url text,
    bio text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()

    CONSTRAINT chk_profiles_taltech_email_domain
        CHECK (
            taltech_email IS NULL
            OR lower(taltech_email) LIKE '%@taltech.ee'
        )
)

CREATE TABLE categories (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    parent_id uuid,
    name non_empty_text UNIQUE NOT NULL,
    slug non_empty_text UNIQUE NOT NULL,
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
)

CREATE TABLE listing_conditions (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    label non_empty_text UNIQUE NOT NULL,
    code_label non_empty_text UNIQUE NOT NULL,
    sort_order integer NOT NULL DEFAULT 0,

    CONSTRAINT chk_listing_conditions_sort_order
        CHECK (sort_order >= 0)
)

CREATE TABLE listings (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),

    seller_id uuid NOT NULL,
    category_id uuid NOT NULL,
    condition_id uuid NOT NULL,

    title non_empty_text NOT NULL,
    description non_empty_text NOT NULL,
    price price_amount NOT NULL,
    currency currency_code NOT NULL,
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
        ON DELETE RESTRICT

    CONSTRAINT chk_listings_status
        CHECK (status IN ('draft', 'published', 'archived')
)