# 🌳 Parchi Monitor - Sistema di Sorveglianza Parchi Pubblici

Un sistema distribuito di monitoraggio real-time per parchi pubblici che utilizza telecamere su Raspberry Pi, analisi IA locale e un server centrale per la gestione dati.

## 📋 Indice

- [Panoramica](#panoramica)
- [Architettura](#architettura)
- [Prerequisiti](#prerequisiti)
- [Installazione](#installazione)
  - [Setup Raspberry Pi](#setup-raspberry-pi)
  - [Setup Server Centrale](#setup-server-centrale)
  - [Setup Database](#setup-database)
- [Configurazione](#configurazione)
- [Utilizzo](#utilizzo)
- [API Reference](#api-reference)
- [Struttura Database](#struttura-database)
- [Sviluppo](#sviluppo)
- [Licenza](#licenza)

## 🎯 Panoramica

**Parchi Monitor** è una soluzione completa per il monitoraggio automatico di parchi pubblici che:

✅ Scatta foto periodicamente da più Raspberry Pi  
✅ Filtra automaticamente foto con persone (per privacy)  
✅ Analizza le scene con LLM (Ollama locale + modello avanzato server)  
✅ Invia solo foto “pulite” al server centrale  
✅ Salva metadata e immagini su PostgreSQL  
✅ Offre dashboard per visualizzazione dati  
✅ Garantisce compliance GDPR (no riconoscimento facciale)

## 🏗️ Architettura

```
┌─────────────────────────────────────────────────────────────┐
│                    SERVER CENTRALE                          │
│  ┌──────────────┐  ┌──────────────┐  ┌─────────────────┐  │
│  │  FastAPI     │  │  LLM Advanced│  │  PostgreSQL     │  │
│  │  /api/foto   │  │  (Claude)    │  │  parchi_monitor │  │
│  └──────────────┘  └──────────────┘  └─────────────────┘  │
└─────────────────────────────────────────────────────────────┘
           ↑                                      ↑
           │ POST /api/foto/upload               │ Query/Write
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

## 💾 Flusso Dati

```
┌─────────────────────────────────────────────────────────┐
│ 1. RASPBERRY PI - Acquisizione                          │
│    └─ Scatta foto con webcam                            │
│    └─ Analizza con Ollama locale (rapido)              │
│    └─ Se contiene persone → elimina                    │
└─────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────┐
│ 2. TRASFERIMENTO                                        │
│    └─ Se foto "pulita" → invia al server               │
│    └─ POST /api/foto/upload (base64)                   │
│    └─ Elimina dalla memoria locale                     │
└─────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────┐
│ 3. SERVER CENTRALE - Analisi Avanzata                   │
│    └─ Riceve foto                                      │
│    └─ Analizza con LLM avanzato (Claude)               │
│    └─ Estrae metadata (oggetti, contaminazione, ecc)   │
│    └─ Salva foto + metadata su PostgreSQL              │
└─────────────────────────────────────────────────────────┘
```

## 📦 Prerequisiti

### Raspberry Pi

- **Hardware**: Raspberry Pi 4 (min 4GB RAM)
- **OS**: Raspbian/Debian bullseye
- **Webcam**: USB compatibile
- **Connessione**: Ethernet/WiFi stabile
- **Spazio**: 500MB su SD card

### Server Centrale

- **OS**: Linux/macOS/Windows con Docker
- **Python**: 3.9+
- **PostgreSQL**: 12+
- **Docker** (opzionale ma consigliato)

## 🚀 Installazione

### Setup Raspberry Pi

#### 1. Aggiorna il sistema

```bash
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -y python3-pip fswebcam
```

#### 2. Installa Ollama

```bash
curl https://ollama.ai/install.sh | sh
ollama pull llava
ollama pull llava-phi  # Alternativa più leggera
```

#### 3. Clona il repository

```bash
cd /home/pi
git clone https://github.com/tuarepo/parchi-monitor.git
cd parchi-monitor/raspberry
```

#### 4. Installa dipendenze Python

```bash
pip3 install -r requirements.txt
```

#### 5. Configura il Raspberry

```bash
cp config.example.json config.json
nano config.json
```

Modifica i seguenti campi:

```json
{
  "raspberry_id": "rpi_parco_001",
  "location": "Parco Centrale - Nord",
  "server_url": "http://192.168.1.100:5000",
  "webcam_device": "/dev/video0",
  "screenshot_times": ["07:00", "10:00", "13:00", "16:00", "19:00"]
}
```

#### 6. Avvia Ollama

```bash
# Terminal 1
ollama serve
```

#### 7. Avvia l’agent di monitoraggio

```bash
# Terminal 2
python3 agent_monitor.py
```

### Setup Server Centrale

#### 1. Clona il repository

```bash
git clone https://github.com/tuarepo/parchi-monitor.git
cd parchi-monitor/server
```

#### 2. Installa dipendenze

```bash
pip3 install -r requirements.txt
```

#### 3. Configura variabili d’ambiente

```bash
cp .env.example .env
nano .env
```

```env
DATABASE_URL=postgresql://postgres:password@localhost:5432/parchi_monitor
CLAUDE_API_KEY=sk-ant-xxxxx
SECRET_KEY=your-secret-key-here
DEBUG=False
```

#### 4. Inizializza il database

```bash
python3 -c "from app import db; db.create_all()"
```

#### 5. Avvia il server

```bash
python3 app.py
# oppure con Gunicorn in produzione
gunicorn -w 4 -b 0.0.0.0:5000 app:app
```

### Setup Database

#### Con Docker Compose (consigliato)

```bash
cd parchi-monitor
docker-compose up -d
```

#### Manuale con PostgreSQL

```bash
# Crea database
createdb parchi_monitor_db

# Carica schema
psql parchi_monitor_db < db/schema.sql

# Aggiungi dati di test
psql parchi_monitor_db < db/seed_data.sql
```

## ⚙️ Configurazione

### Raspberry Pi (config.json)

```json
{
  "device": {
    "raspberry_id": "rpi_parco_001",
    "location": "Parco Centrale - Nord",
    "latitude": 41.9028,
    "longitude": 12.4964
  },
  "camera": {
    "device": "/dev/video0",
    "resolution": "1920x1080",
    "fps": 30
  },
  "schedule": {
    "screenshot_times": ["07:00", "10:00", "13:00", "16:00", "19:00"],
    "max_retries": 10,
    "retry_interval_minutes": 60
  },
  "ai": {
    "ollama_url": "http://localhost:11434",
    "ollama_model": "llava",
    "min_confidence": 0.7
  },
  "server": {
    "url": "http://192.168.1.100:5000",
    "timeout": 30,
    "retry_failed_uploads": true
  },
  "privacy": {
    "delete_local_after_days": 30,
    "delete_with_people": true
  }
}
```

### Server Centrale (.env)

```env
# Database
DATABASE_URL=postgresql://postgres:secure_password@localhost:5432/parchi_monitor
SQLALCHEMY_TRACK_MODIFICATIONS=False

# API Claude
CLAUDE_API_KEY=sk-ant-xxxxxxxxxxxxx
CLAUDE_MODEL=claude-3-5-sonnet-20241022

# Sicurezza
SECRET_KEY=your-super-secret-key-change-me
JWT_SECRET=your-jwt-secret-key

# Configurazione app
DEBUG=False
ENVIRONMENT=production
LOG_LEVEL=INFO

# Upload immagini
MAX_UPLOAD_SIZE=50  # MB
UPLOAD_FOLDER=/storage/uploads

# CORS
CORS_ORIGINS=["http://localhost:3000", "http://192.168.1.100"]
```

## 📊 Utilizzo

### Avvia il sistema completo

#### Con Docker Compose

```bash
docker-compose up -d

# Visualizza log
docker-compose logs -f

# Ferma il sistema
docker-compose down
```

#### Manuale

```bash
# Terminal 1: Ollama su Raspberry
ollama serve

# Terminal 2: Agent Raspberry
cd raspberry && python3 agent_monitor.py

# Terminal 3: Server Centrale
cd server && python3 app.py
```

### Monitora lo stato

```bash
# Visualizza log Raspberry
tail -f /home/pi/parchi_monitor.log

# Visualizza log Server
docker-compose logs -f parchi-server

# Check connessione database
psql parchi_monitor_db -c "SELECT COUNT(*) FROM foto;"
```

### Dashboard Web

Accedi a: `http://localhost:3000`

- Visualizza foto per parco
- Statistiche in tempo reale
- Grafici temporali
- Esporta report PDF

## 🔌 API Reference

### Upload Foto

```
POST /api/foto/upload
Content-Type: application/json

{
  "raspberry_id": "rpi_parco_001",
  "location": "Parco Centrale - Nord",
  "timestamp": "2025-02-17T10:30:00Z",
  "image_base64": "iVBORw0KGgoAAAANS...",
  "filename": "parco_20250217_103000.jpg",
  "tentativo": 2
}

Response:
{
  "status": "success",
  "foto_id": "f123e456b789",
  "message": "Foto ricevuta e processata"
}
```

### Recupera Foto

```
GET /api/foto?parco=rpi_parco_001&limit=10&offset=0

Response:
{
  "photos": [
    {
      "id": "f123e456b789",
      "raspberry_id": "rpi_parco_001",
      "timestamp": "2025-02-17T10:30:00Z",
      "url": "/storage/uploads/f123e456b789.jpg",
      "analisi": {
        "oggetti": ["panchine", "alberi", "sentiero"],
        "condizioni": "buone",
        "inquinamento": "basso"
      }
    }
  ],
  "total": 150
}
```

### Statistiche

```
GET /api/stats/daily?date=2025-02-17

Response:
{
  "data": [
    {
      "raspberry_id": "rpi_parco_001",
      "location": "Parco Centrale",
      "foto_count": 5,
      "avg_quality": 8.5,
      "issues": []
    }
  ]
}
```

## 🗄️ Struttura Database

### Tabelle Principali

**foto**

```sql
CREATE TABLE foto (
  id UUID PRIMARY KEY,
  raspberry_id VARCHAR(50),
  location VARCHAR(255),
  timestamp TIMESTAMP,
  filename VARCHAR(255),
  file_path VARCHAR(500),
  file_size INTEGER,
  tentativo INTEGER,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**analisi_foto**

```sql
CREATE TABLE analisi_foto (
  id UUID PRIMARY KEY,
  foto_id UUID REFERENCES foto(id),
  modello_ia VARCHAR(50),
  oggetti JSONB,
  condizioni VARCHAR(50),
  inquinamento VARCHAR(50),
  score_qualita FLOAT,
  metadati JSONB,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**raspberry_devices**

```sql
CREATE TABLE raspberry_devices (
  id VARCHAR(50) PRIMARY KEY,
  location VARCHAR(255),
  latitude DECIMAL(10, 8),
  longitude DECIMAL(11, 8),
  status VARCHAR(20),
  last_heartbeat TIMESTAMP,
  version_firmware VARCHAR(20),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**alert**

```sql
CREATE TABLE alert (
  id UUID PRIMARY KEY,
  foto_id UUID REFERENCES foto(id),
  tipo_alert VARCHAR(100),
  severity VARCHAR(20),
  messaggio TEXT,
  resolved BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## 🛠️ Sviluppo

### Stack Tecnologico

**Raspberry Pi**

- Python 3.9+
- Ollama (LLM locale)
- OpenCV (elaborazione immagini)
- Requests (HTTP client)

**Server**

- FastAPI/Flask (Python)
- PostgreSQL (database)
- Claude API (LLM avanzato)
- Pydantic (validazione)

**Frontend** (opzionale)

- React/Vue.js
- Plotly (grafici)
- Axios (API client)

### Struttura Directory

```
parchi-monitor/
├── raspberry/
│   ├── agent_monitor.py      # Main agent
│   ├── config.json            # Configurazione
│   ├── config.example.json
│   ├── requirements.txt
│   └── modules/
│       ├── camera.py
│       ├── ollama_analyzer.py
│       ├── server_client.py
│       └── privacy_manager.py
├── server/
│   ├── app.py                # App principale
│   ├── requirements.txt
│   ├── .env.example
│   ├── models/               # SQLAlchemy models
│   ├── routes/               # API endpoints
│   ├── services/             # Business logic
│   └── config.py
├── db/
│   ├── schema.sql            # Schema database
│   └── seed_data.sql
├── frontend/                 # React/Vue app
├── docker-compose.yml
├── Dockerfile.raspberry
├── Dockerfile.server
└── README.md
```

### Variabili d’Ambiente

```bash
# Raspberry
RASPBERRY_ID=rpi_parco_001
SERVER_URL=http://192.168.1.100:5000
OLLAMA_URL=http://localhost:11434

# Server
DATABASE_URL=postgresql://...
CLAUDE_API_KEY=sk-ant-...
SECRET_KEY=your-secret-key
```

### Testing

```bash
# Testa connessione Ollama
curl http://localhost:11434/api/tags

# Testa API Server
curl -X GET http://localhost:5000/api/health

# Testa database
psql parchi_monitor_db -c "SELECT version();"
```

## 🔐 Sicurezza

✅ **Privacy by Design**

- Filtro locale per persone (niente dati sensibili al server)
- Eliminazione automatica file locali
- Niente riconoscimento facciale

✅ **Autenticazione**

- JWT token per API
- Rate limiting
- HTTPS in produzione

✅ **Compliance**

- GDPR compliant
- Niente tracking personale
- Log di audit

## 📝 Logging

```bash
# Raspberry
tail -f /home/pi/parchi_monitor.log

# Server (Docker)
docker-compose logs -f parchi-server

# Database
docker-compose logs -f postgres
```

## 🐛 Troubleshooting

### Ollama non risponde

```bash
# Check status
curl http://localhost:11434/api/tags

# Riavvia Ollama
pkill -f "ollama serve"
ollama serve
```

### Foto non inviate

```bash
# Check connessione server
curl -v http://server-url:5000/api/health

# Verifica config.json
cat /home/pi/parchi-monitor/config.json

# Check log
tail -n 100 /home/pi/parchi_monitor.log
```

### Errore database

```bash
# Check connessione
psql -h localhost -U postgres -d parchi_monitor_db

# Reset database
docker-compose down
docker volume rm parchi-monitor_postgres_data
docker-compose up -d
```

## 📈 Performance

- **Latenza foto**: ~2-5 sec (scatto + analisi)
- **Throughput**: 5 foto/min per Raspberry
- **Storage**: ~1MB per foto
- **Memoria Raspberry**: ~800MB

## 📄 Licenza

MIT License - vedi LICENSE.md

## 🤝 Contributi

Le pull request sono benvenute! Per cambiamenti significativi, apri prima un issue.

## 📧 Contatti

- Email: support@parchimonitor.it
- Docs: https://docs.parchimonitor.it
- Issues: https://github.com/tuarepo/parchi-monitor/issues

-----

**Ultima modifica**: Febbraio 2025  
**Versione**: 1.0.0  
**Status**: Production Ready ✅