CREATE TABLE automobili (
    id SERIAL PRIMARY KEY,
    marka VARCHAR(50) NOT NULL,
    model VARCHAR(100) NOT NULL,
    cena INT
);

INSERT INTO automobili (marka, model, cena) VALUES
    ('Audi', 'A4 2.0 TDI', 4500),
    ('BMW', '320d', 5000),
    ('Volkswagen', 'Golf 8', 19800),
    ('Skoda', 'Octavia', 16200);

SELECT * FROM automobili;


INSERT INTO automobili (marka, model, cena) VALUES ('Porsche', '911 Carrera', 95000);

INSERT INTO automobili (marka, model, cena) VALUES ('Peugeot', '307sw', 1000);

SELECT inet_server_addr();