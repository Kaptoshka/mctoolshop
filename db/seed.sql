BEGIN;

TRUNCATE order_items, orders, items, users RESTART IDENTITY;

-- users: x1000, registered last year
INSERT INTO users (name, email, created_at, updated_at)
SELECT 'Player ' || g, 'player' || g || '@example.com', ts, ts
FROM (
    SELECT g, now() - random() * interval '365 days' AS ts
    FROM generate_series(1, 1000) AS g
) AS s;

-- items: materials x tools
INSERT INTO items (name, category, price)
SELECT m.material || ' ' || t.tool,
       t.tool,
       m.base * t.mult
FROM (VALUES ('Wooden', 10), ('Stone', 20), ('Iron', 50),
             ('Golden', 40), ('Diamond', 200), ('Netherite', 400)) AS m(material, base)
CROSS JOIN (VALUES ('Axe', 3), ('Pickaxe', 3), ('Spear', 2), 
                   ('Shovel', 1), ('Sword', 2), ('Hoe', 1)) AS t(tool, mult);

-- orders: x20000, date between user registration date and now()
INSERT INTO orders (user_id, status, created_at, updated_at)
SELECT user_id, status, ts, ts
FROM (
    SELECT u.id AS user_id,
           (ARRAY['new', 'paid', 'shipped', 'cancelled'])[1 + floor(random() * 4)::int] AS status,
           u.created_at + random() * (now() - u.created_at) AS ts
    FROM (
        SELECT 1 + floor(random() * 1000)::int AS uid
        FROM generate_series(1, 20000)
    ) AS r
    INNER JOIN users u ON u.id = r.uid
) AS s;

-- order_items: 1--4 items per order
INSERT INTO order_items (order_id, item_id, quantity, unit_price)
SELECT o.id, i.id, 1 + floor(random() * 5)::int, i.price
FROM orders o
CROSS JOIN LATERAL (
    SELECT id, price
    FROM items
    ORDER BY random()
    LIMIT 1 + (o.id % 4)
) AS i;

COMMIT;

ANALYZE;
