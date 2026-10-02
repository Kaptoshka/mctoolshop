CREATE TABLE IF NOT EXISTS users (
    id         serial PRIMARY KEY,
    name       text NOT NULL,
    email      text NOT NULL UNIQUE,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS items (
    id       serial PRIMARY KEY,
    name     text NOT NULL,
    category text NOT NULL,
    price    int NOT NULL CHECK (price > 0)
);

CREATE TABLE IF NOT EXISTS orders (
    id         serial PRIMARY KEY,
    user_id    int NOT NULL REFERENCES users(id),
    status     text NOT NULL CHECK (status IN ('new', 'paid', 'shipped', 'cancelled')),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS order_items (
    order_id   int NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    item_id    int NOT NULL REFERENCES items(id),
    quantity   int NOT NULL CHECK (quantity > 0),
    unit_price int NOT NULL CHECK (unit_price > 0),
    PRIMARY KEY (order_id, item_id)
);
