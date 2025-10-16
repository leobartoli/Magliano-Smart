-- ====================================
-- Magliano-Smart Database Initialization
-- ====================================

-- Abilita estensioni
CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS uuid-ossp;

-- ====================================
-- 1. TABELLE GEOGRAFICHE
-- ====================================

CREATE TABLE IF NOT EXISTS comuni (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL UNIQUE,
    provincia VARCHAR(255),
    regione VARCHAR(255),
    codice_istat VARCHAR(6),
    geometry GEOMETRY(Point, 4326),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS zone_amministrative (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(255) NOT NULL,
    comune_id INTEGER REFERENCES comuni(id) ON DELETE CASCADE,
    tipo VARCHAR(50),
    geometry GEOMETRY(Polygon, 4326),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ====================================
-- 2. TABELLE DOCUMENTI
-- ====================================

CREATE TABLE IF NOT EXISTS documenti (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    titolo VARCHAR(255) NOT NULL,
    descrizione TEXT,
    tipo VARCHAR(50),
    contenuto TEXT,
    file_path VARCHAR(500),
    data_creazione TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_modifica TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    autore VARCHAR(255),
    versione INTEGER DEFAULT 1,
    attivo BOOLEAN DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS categorie_documento (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL UNIQUE,
    descrizione TEXT,
    colore VARCHAR(7)
);

CREATE TABLE IF NOT EXISTS documento_categoria (
    documento_id UUID REFERENCES documenti(id) ON DELETE CASCADE,
    categoria_id INTEGER REFERENCES categorie_documento(id) ON DELETE CASCADE,
    PRIMARY KEY (documento_id, categoria_id)
);

-- ====================================
-- 3. TABELLE WORKFLOW
-- ====================================

CREATE TABLE IF NOT EXISTS workflow (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nome VARCHAR(255) NOT NULL,
    descrizione TEXT,
    stato VARCHAR(50) DEFAULT 'draft',
    versione INTEGER DEFAULT 1,
    n8n_workflow_id VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS workflow_step (
    id SERIAL PRIMARY KEY,
    workflow_id UUID REFERENCES workflow(id) ON DELETE CASCADE,
    numero_step INTEGER NOT NULL,
    nome VARCHAR(255),
    descrizione TEXT,
    tipo VARCHAR(100),
    configurazione JSONB,
    ordine INTEGER
);

CREATE TABLE IF NOT EXISTS workflow_execution (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    workflow_id UUID REFERENCES workflow(id),
    stato VARCHAR(50) DEFAULT 'in_progress',
    data_inizio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    data_fine TIMESTAMP,
    risultato JSONB,
    errore TEXT
);

-- ====================================
-- 4. TABELLE UTENTI E PERMESSI
-- ====================================

CREATE TABLE IF NOT EXISTS utenti (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username VARCHAR(100) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255),
    nome VARCHAR(255),
    cognome VARCHAR(255),
    ruolo VARCHAR(50) DEFAULT 'user',
    attivo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP
);

CREATE TABLE IF NOT EXISTS ruoli (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(50) NOT NULL UNIQUE,
    descrizione TEXT,
    permessi JSONB
);

CREATE TABLE IF NOT EXISTS utente_ruolo (
    utente_id UUID REFERENCES utenti(id) ON DELETE CASCADE,
    ruolo_id INTEGER REFERENCES ruoli(id) ON DELETE CASCADE,
    PRIMARY KEY (utente_id, ruolo_id)
);

-- ====================================
-- 5. TABELLE AUTOMAZIONI
-- ====================================

CREATE TABLE IF NOT EXISTS automazioni (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nome VARCHAR(255) NOT NULL,
    descrizione TEXT,
    trigger_tipo VARCHAR(100),
    trigger_config JSONB,
    azioni JSONB,
    attiva BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS log_automazioni (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    automazione_id UUID REFERENCES automazioni(id),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    stato VARCHAR(50),
    dettagli JSONB
);

-- ====================================
-- 6. TABELLE AUDIT
-- ====================================

CREATE TABLE IF NOT EXISTS audit_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    utente_id UUID REFERENCES utenti(id),
    tabella VARCHAR(100),
    operazione VARCHAR(50),
    record_id VARCHAR(255),
    dati_vecchi JSONB,
    dati_nuovi JSONB,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ====================================
-- INDICI
-- ====================================

CREATE INDEX idx_comuni_geometria ON comuni USING GIST(geometry);
CREATE INDEX idx_zone_amministrative_geometria ON zone_amministrative USING GIST(geometry);
CREATE INDEX idx_documenti_titolo ON documenti USING GIN(titolo gin_trgm_ops);
CREATE INDEX idx_documenti_data ON documenti(data_creazione DESC);
CREATE INDEX idx_workflow_stato ON workflow(stato);
CREATE INDEX idx_utenti_email ON utenti(email);
CREATE INDEX idx_audit_timestamp ON audit_log(timestamp DESC);

-- ====================================
-- DATI DI ESEMPIO
-- ====================================

INSERT INTO comuni (nome, provincia, regione, codice_istat, geometry) VALUES
('Magliano in Toscana', 'GR', 'Toscana', '053009', ST_GeomFromText('POINT(11.5069 42.8084)', 4326)),
('Grosseto', 'GR', 'Toscana', '053008', ST_GeomFromText('POINT(11.1152 42.7614)', 4326))
ON CONFLICT (nome) DO NOTHING;

INSERT INTO categorie_documento (nome, descrizione, colore) VALUES
('Delibere', 'Delibere del consiglio comunale', '#FF6B6B'),
('Ordinanze', 'Ordinanze sindacali', '#4ECDC4'),
('Regolamenti', 'Regolamenti comunali', '#45B7D1'),
('Avvisi', 'Avvisi pubblici', '#FFA07A'),
('Amministrativo', 'Documenti amministrativi', '#98D8C8')
ON CONFLICT (nome) DO NOTHING;

INSERT INTO ruoli (nome, descrizione, permessi) VALUES
('admin', 'Amministratore di sistema', '{"read": true, "write": true, "delete": true, "admin": true}'),
('operatore', 'Operatore comunale', '{"read": true, "write": true, "delete": false, "admin": false}'),
('cittadino', 'Utente cittadino', '{"read": true, "write": false, "delete": false, "admin": false}')
ON CONFLICT (nome) DO NOTHING;

-- ====================================
-- FINE INIZIALIZZAZIONE
-- ====================================