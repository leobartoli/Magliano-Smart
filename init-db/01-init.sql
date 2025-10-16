-- Estensioni
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS vector;

-- Tabelle principali
CREATE TABLE IF NOT EXISTS comuni (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    provincia VARCHAR(255),
    geometry GEOMETRY(Point, 4326)
);

CREATE TABLE IF NOT EXISTS documenti (
    id SERIAL PRIMARY KEY,
    titolo VARCHAR(255) NOT NULL,
    contenuto TEXT,
    data_creazione TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS workflow (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    descrizione TEXT,
    stato VARCHAR(50)
);