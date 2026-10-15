-- Enums
CREATE TYPE price_tier AS ENUM ('$', '$$', '$$$');
CREATE TYPE product_type AS ENUM ('body', 'skincare', 'haircare', 'makeup', 'other');
CREATE TYPE skin_type AS ENUM ('oily', 'dry', 'combination', 'sensitive', 'normal');
CREATE TYPE user_role AS ENUM ('admin', 'user');
CREATE TYPE usage_duration AS ENUM ('under_1_week', '1_to_4_weeks', '1_to_6_months', '6_plus_months');

-- Users
CREATE TABLE users (
    id uuid PRIMARY KEY DEFAULT uuidv7(),
    username text NOT NULL UNIQUE,
    email text NOT NULL UNIQUE,
    password_hash text NOT NULL,
    birth_date date NOT NULL,
    skin_type skin_type NOT NULL,
    role user_role NOT NULL DEFAULT 'user',
    profile_image_url text,
    last_login_at timestamptz,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

-- Brands
CREATE TABLE brands (
    id uuid PRIMARY KEY DEFAULT uuidv7(),
    name text NOT NULL UNIQUE,
    created_at timestamptz NOT NULL DEFAULT now()
);

-- Products (needs brands)
CREATE TABLE products (
    id uuid PRIMARY KEY DEFAULT uuidv7(),
    brand_id uuid NOT NULL REFERENCES brands(id),
    name text NOT NULL,
    type product_type NOT NULL,
    price_tier price_tier NOT NULL,
    is_clean boolean NOT NULL DEFAULT false,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (brand_id, name)
);

-- Reviews
CREATE TABLE reviews (
    id uuid PRIMARY KEY DEFAULT uuidv7(),
    user_id uuid NOT NULL REFERENCES users(id),
    product_id uuid NOT NULL REFERENCES products(id),
    rating smallint NOT NULL CHECK (rating BETWEEN 1 AND 5),
    text text,
    purchased_multiple_times boolean NOT NULL DEFAULT false,
    returned boolean NOT NULL DEFAULT false,
    usage_duration usage_duration,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (user_id, product_id)
);

CREATE INDEX reviews_product_id_idx ON reviews (product_id);