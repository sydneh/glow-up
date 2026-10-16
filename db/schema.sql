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
-- Routines (v2: not created in the local database yet)
CREATE TYPE media_type AS ENUM ('photo', 'video');

CREATE TABLE routines (
    id uuid PRIMARY KEY DEFAULT uuidv7(),
    user_id uuid NOT NULL REFERENCES users(id),
    title text NOT NULL,
    description text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX routines_user_id_idx ON routines (user_id);

-- Steps always need text instructions, for accessibility
CREATE TABLE routine_steps (
    id uuid PRIMARY KEY DEFAULT uuidv7(),
    routine_id uuid NOT NULL REFERENCES routines(id) ON DELETE CASCADE,
    position smallint NOT NULL,
    instructions text NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (routine_id, position)
);

-- Photos and videos, with alt text and captions for accessibility
CREATE TABLE routine_media (
    id uuid PRIMARY KEY DEFAULT uuidv7(),
    routine_id uuid NOT NULL REFERENCES routines(id) ON DELETE CASCADE,
    step_id uuid REFERENCES routine_steps(id) ON DELETE SET NULL,
    media_type media_type NOT NULL,
    url text NOT NULL,
    position smallint NOT NULL,
    alt_text text,
    captions text,
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX routine_media_routine_id_idx ON routine_media (routine_id);

-- Products used in a routine (many-to-many)
CREATE TABLE routine_products (
    routine_id uuid NOT NULL REFERENCES routines(id) ON DELETE CASCADE,
    product_id uuid NOT NULL REFERENCES products(id),
    PRIMARY KEY (routine_id, product_id)
);

CREATE INDEX routine_products_product_id_idx ON routine_products (product_id);

-- Tags for searching (many-to-many)
CREATE TABLE tags (
    id uuid PRIMARY KEY DEFAULT uuidv7(),
    name text NOT NULL UNIQUE,
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE routine_tags (
    routine_id uuid NOT NULL REFERENCES routines(id) ON DELETE CASCADE,
    tag_id uuid NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
    PRIMARY KEY (routine_id, tag_id)
);

CREATE INDEX routine_tags_tag_id_idx ON routine_tags (tag_id);

-- Who follows whom (users linked to users)
CREATE TABLE follows (
    follower_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    followed_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (follower_id, followed_id),
    CHECK (follower_id <> followed_id)
);

CREATE INDEX follows_followed_id_idx ON follows (followed_id);
