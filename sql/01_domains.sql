CREATE EXTENSION IF NOT EXISTS pgcrypto; /* For generating UUIDs */

CREATE DOMAIN non_empty_text AS text
CHECK (length(trim(VALUE)) > 0);

CREATE DOMAIN price_amount AS numeric(10, 2)
CHECK (VALUE >= 0);

CREATE DOMAIN currency_code AS text
CHECK (VALUE = 'EUR');