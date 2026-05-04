-- 06_seed_classifiers.sql
-- classifier values for TalTech Marketplace

INSERT INTO categories (name, slug, sort_order)
VALUES
    ('Õppematerjalid', 'oppematerjalid', 10),
    ('Elektroonika', 'elektroonika', 20),
    ('Riided', 'riided', 30),
    ('Mööbel', 'moobel', 40),
    ('Muu', 'muu', 50);

INSERT INTO listing_conditions (label, code_label, sort_order)
VALUES
    ('Uus', 'new', 10),
    ('Väga hea', 'very_good', 20),
    ('Kasutatud', 'used', 30),
    ('Kulunud', 'worn', 40);