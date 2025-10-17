Integro il progetto **Parchi Monitor** con l'infrastruttura **Magliano-Smart** per garantire coerenza, sfruttare il database centrale avanzato (PostgreSQL con PostGIS/pgvector) e l'AI locale (Ollama).

Ecco il file `raspberry.md` aggiornato.

-----

# 🌳 Parchi Monitor - Sistema di Sorveglianza Parchi Pubblici

Un sistema distribuito di monitoraggio real-time per parchi pubblici che utilizza telecamere su Raspberry Pi, analisi IA locale e il **Server Centrale Magliano-Smart** per la gestione dati e l'integrazione GIS.

## 📋 Indice

  - [Panoramica](https://www.google.com/search?q=%23panoramica)
  - [Architettura](https://www.google.com/search?q=%23architettura)
  - [Prerequisiti](https://www.google.com/search?q=%23prerequisiti)
  - [Installazione](https://www.google.com/search?q=%23installazione)
      - [Setup Raspberry Pi](https://www.google.com/search?q=%23setup-raspberry-pi)
      - [Setup Server Centrale](https://www.google.com/search?q=%23setup-server-centrale)
      - [Integrazione Database](https://www.google.com/search?q=%23integrazione-database)
  - [Configurazione](https://www.google.com/search?q=%23configurazione)
  - [Utilizzo](https://www.google.com/search?q=%23utilizzo)
  - [API Reference](https://www.google.com/search?q=%23api-reference)
  - [Struttura Database](https://www.google.com/search?q=%23struttura-database)
  - [Sviluppo](https://www.google.com/search?q=%23sviluppo)
  - [Licenza](https://www.google.com/search?q=%23licenza)

-----

## 🎯 Panoramica

**Parchi Monitor** è una soluzione per il monitoraggio automatico dei parchi, integrata con la piattaforma **Magliano-Smart** per:

✅ Scattare foto periodicamente da più Raspberry Pi
✅ Filtrare automaticamente foto con persone (per privacy **GDPR**)
✅ Analizzare le scene con LLM locale (**Ollama**) e avanzato (API Claude)
✅ Inviare solo foto "pulite" al Server Centrale Magliano-Smart
✅ Salvare metadata e immagini nel database **PostgreSQL/PostGIS** centrale
✅ Sfruttare **PostGIS** per analisi territoriali sulla posizione dei dispositivi.
✅ Sfruttare **pgvector** per la ricerca semantica tra le analisi IA delle foto.

-----

## 🏗️ Architettura

L'agente Raspberry Pi comunica direttamente con i servizi integrati nel Server Centrale Magliano-Smart (API FastAPI/Flask e Database PostgreSQL).

```
┌───────────────────────────────────────────────────────────────────┐
│                    SERVER CENTRALE MAGLIANO-SMART                 │
│  ┌──────────────┐  ┌──────────────┐  ┌───────────────────────┐  │
│  │  FastAPI/    │  │  LLM Advanced│  │  PostgreSQL 16        │  │
│  │  Flask API   │  │  (Claude)    │  │  (PostGIS + pgvector) │  │
│  └──────────────┘  └──────────────┘  └───────────────────────┘  │
└───────────────────────────────────────────────────────────────────┘
           ↑                                      ↑
           │ POST /api/foto/upload (JWT Auth)    │ Query/Write
           │                                      │
┌──────────────────┐  ┌──────────────────┐  ┌──────────────────┐
│ Raspberry Pi 1   │  │ Raspberry Pi 2   │  │ Raspberry Pi N   │
│ Parco Centro     │  │ Parco Nord       │  │ Parco Sud        │
│                  │  │                  │  │                  │
│ ┌──────────────┐ │  │ ┌──────────────┐ │  │ ┌──────────────┐ │
│ │  Webcam      │ │  │ │  Webcam      │ │  │ │  Webcam      │ │
│ └──────────────┘ │  │ └──────────────┘ │  │ └──────────────┘ │
│        ↓         │  │        ↓         │  │        ↓         │
│ ┌──────────────┐ │  │ ┌──────────────┐ │  │ ┌──────────────┐ │
│ │  Ollama      │ │  │ │  Ollama      │ │  │ │  Ollama      │ │
│ │  (LLaVA)     │ │  │ │  (LLaVA)     │ │  │ │  (LLaVA)     │ │
│ └──────────────┘ │  │ └──────────────┘ │  │ └──────────────┘ │
│        ↓         │  │        ↓         │  │        ↓         │
│ ┌──────────────┐ │  │ ┌──────────────┐ │  │ ┌──────────────┐ │
│ │  Agent Python│ │  │ │  Agent Python│ │  │ │  Agent Python│ │
│ │  (Monitor)   │ │  │ │  (Monitor)   │  │  │ │  (Monitor)   │ │
│ └──────────────┘ │  │ └──────────────┘ │  │ └──────────────┘ │
└──────────────────┘  └──────────────────┘  └──────────────────┘
```

-----

## 💾 Flusso Dati

1.  **RASPBERRY PI - Acquisizione/Pre-Analisi**: Scatta foto, analizza con **Ollama** locale (LLaVA), elimina le foto con persone.
2.  **TRASFERIMENTO SICURO**: Invia foto "pulita" via `POST /api/foto/upload` al Server Magliano-Smart con **JWT Token** (HTTPS/Cloudflare Tunnel in produzione).
3.  **SERVER CENTRALE MAGLIANO-SMART - Analisi Avanzata/Storage**: Riceve la foto, esegue l'analisi avanzata (Claude), estrae metadata (**oggetti, contaminazione**), salva la foto nel **MinIO** storage, e i metadata nel database **PostgreSQL (con PostGIS/pgvector)**.

-----

## 📦 Prerequisiti

### Raspberry Pi

  - **Hardware**: Raspberry Pi 4 (min 4GB RAM)
  - **OS**: Raspbian/Debian bullseye
  - **Webcam**: USB compatibile
  - **Connessione**: Ethernet/WiFi stabile
  - **Ollama**: installato e con modello `llava` o `llava-phi`

### Server Centrale

  - **Infrastruttura Magliano-Smart**:
      - **PostgreSQL 16** con estensioni `vector` e `postgis` installate.
      - **Ollama** (opzionale, per test LLM avanzato)
      - **MinIO** (per storage S3 compatibile dei file immagine).
      - **FastAPI/Flask** per l'endpoint `/api/foto/upload`.

-----

## 🚀 Installazione

### Setup Raspberry Pi

#### 1\. Aggiorna e installa dipendenze

```bash
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -y python3-pip fswebcam
```

#### 2\. Installa Ollama e pull modello di visione

```bash
curl https://ollama.ai/install.sh | sh
ollama pull llava
# Alternativa: ollama pull llama3.2-vision:11b (se disponibile e più leggero)
```

#### 3\. Clona e configura Parchi Monitor

```bash
cd /home/pi
git clone https://github.com/tuarepo/parchi-monitor.git
cd parchi-monitor/raspberry
pip3 install -r requirements.txt
```

#### 4\. Configura il Raspberry (`config.json`)

Modifica i seguenti campi, assicurandoti che l'`ollama_model` sia lo stesso scaricato (es. `llava`). L'URL del server deve puntare all'endpoint dell'API Magliano-Smart.

```bash
cp config.example.json config.json
nano config.json
```

```json
{
  "raspberry_id": "rpi_parco_001",
  "location": "Parco Centrale - Nord",
  "server_url": "http://IP_SERVER_MAGLIANO:5000",
  "webcam_device": "/dev/video0",
  "screenshot_times": ["07:00", "10:00", "13:00", "16:00", "19:00"]
}
```

#### 5\. Avvia il sistema

```bash
# Terminale 1: Ollama (necessario per l'analisi locale)
ollama serve

# Terminale 2: Agent di monitoraggio
python3 agent_monitor.py
```

### Setup Server Centrale

L'installazione del Server Centrale è gestita dal progetto **Magliano-Smart** tramite `docker-compose up -d`.

#### **Integrazione Database**

È necessario aggiungere le tabelle `foto`, `analisi_foto`, `raspberry_devices` e `alert` allo schema del database **PostgreSQL** già in uso per Magliano-Smart.

```bash
# Connetti al database Magliano-Smart
docker exec -it postgres psql -U n8n -d n8n

# Esegui lo schema SQL per aggiungere le tabelle del monitoraggio
\i /path/to/parchi-monitor/db/schema.sql
```

-----

## ⚙️ Configurazione

### Raspberry Pi (`config.json`)

Assicurarsi che i campi `latitude` e `longitude` siano presenti e corretti. Verranno utilizzati per sfruttare le funzionalità **PostGIS** del database centrale.

```json
{
  "device": {
    "raspberry_id": "rpi_parco_001",
    "location": "Parco Centrale - Nord",
    "latitude": 42.5950,  // Esempio fittizio per Magliano
    "longitude": 11.1576
  },
  "camera": {
    "device": "/dev/video0",
    "resolution": "1920x1080"
  },
  "ai": {
    "ollama_url": "http://localhost:11434",
    "ollama_model": "llava",
    "min_confidence": 0.7
  },
  "server": {
    "url": "http://IP_SERVER_MAGLIANO:5000",
    "timeout": 30,
    "jwt_token": "TOKEN_SEGRETO_JWT" // Aggiunta per Autenticazione JWT
  }
}
```

### Server Centrale (`.env` di Magliano-Smart)

Queste variabili sono gestite dal file `.env` di Magliano-Smart:

```env
# Database Magliano-Smart
DATABASE_URL=postgresql://postgres:secure_password@localhost:5432/parchi_monitor # Rinominato per coerenza
# ...
# API Claude
CLAUDE_API_KEY=sk-ant-xxxxxxxxxxxxx
CLAUDE_MODEL=claude-3-5-sonnet-20241022
# ...
# Sicurezza Magliano-Smart (utilizzato per autenticare l'upload)
SECRET_KEY=your-super-secret-key-change-me
JWT_SECRET=your-jwt-secret-key
# ...
# Upload immagini in MinIO
UPLOAD_FOLDER=/storage/uploads # Assicurarsi che questo volume sia mappato a MinIO
```

-----

## 🗄️ Struttura Database

Le tabelle del Parchi Monitor sono integrate nel database centrale **PostgreSQL 16** di Magliano-Smart, sfruttando le sue estensioni avanzate.

### Tabelle Principali

**foto**

```sql
CREATE TABLE foto (
  id UUID PRIMARY KEY,
  raspberry_id VARCHAR(50),
  location VARCHAR(255),
  -- Aggiunta la colonna di tipo GEOGRAPHY per PostGIS
  posizione GEOGRAPHY(Point, 4326), 
  timestamp TIMESTAMP,
  filename VARCHAR(255),
  file_path VARCHAR(500), -- Path in MinIO
  ...
);
```

**analisi\_foto**

```sql
CREATE TABLE analisi_foto (
  id UUID PRIMARY KEY,
  foto_id UUID REFERENCES foto(id),
  modello_ia VARCHAR(50),
  oggetti JSONB,
  -- Aggiunta la colonna di tipo VECTOR per pgvector
  embedding_ia VECTOR(1536), 
  condizioni VARCHAR(50),
  inquinamento VARCHAR(50),
  score_qualita FLOAT,
  ...
);
```

**raspberry\_devices**

```sql
CREATE TABLE raspberry_devices (
  id VARCHAR(50) PRIMARY KEY,
  location VARCHAR(255),
  -- Aggiunta la colonna di tipo GEOGRAPHY
  posizione GEOGRAPHY(Point, 4326), 
  status VARCHAR(20),
  last_heartbeat TIMESTAMP,
  ...
);
```

-----

## 🔌 API Reference

### Upload Foto (Aggiornato con JWT)

```
POST /api/foto/upload
Content-Type: application/json
Authorization: Bearer <TOKEN_SEGRETO_JWT>

{
  "raspberry_id": "rpi_parco_001",
  "location": "Parco Centrale - Nord",
  "timestamp": "2025-02-17T10:30:00Z",
  "image_base64": "iVBORw0KGgoAAAorw...",
  "filename": "parco_20250217_103000.jpg"
}
```

-----

## 🛠️ Sviluppo

### Stack Tecnologico (Parchi Monitor + Magliano-Smart)

|Componente |Tecnologia Parchi Monitor |Integrazione Magliano-Smart |
|---|---|---|
|**Database**|PostgreSQL |**PostgreSQL 16, PostGIS, pgvector**|
|**AI Locale**|Ollama (LLaVA) |**Ollama (GPT4OSS 20B, Qwen2.5 7B, Llama Vision)**|
|**Backend API**|FastAPI/Flask |**FastAPI/Flask, JWT Auth**|
|**Storage File**|Filesystem locale |**MinIO (S3-compatible)**|
|**Automazioni**|Agent Python |**N8N (per allertamento e reportistica automatica)**|
|**GIS**|Lat/Lon |**QGIS Server, PostGIS**|

### Sviluppo e Testing

L'API del Server Centrale può essere testata come parte della suite di test di Magliano-Smart:

```bash
# Testa API Server Magliano-Smart
curl -X GET http://localhost:5000/api/health
```

-----

## 🔐 Sicurezza

Il progetto Parchi Monitor eredita le policy di sicurezza di Magliano-Smart:

✅ **Privacy by Design**: Filtro locale per persone.
✅ **Autenticazione**: **JWT token** per l'upload su `/api/foto/upload`.
✅ **Accesso Remoto**: Utilizzo di **Cloudflare Tunnel/ZeroTier** per l'accesso sicuro agli endpoint API, come da architettura Magliano-Smart.

-----

**Ultima modifica**: Ottobre 2025 (Aggiornamento per Magliano-Smart)
**Versione**: 1.1.0 (Integrazione)
**Status**: Production Ready ✅