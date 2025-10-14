# 🏛️ Magliano-Smart

**Magliano-Smart** è la piattaforma digitale del Comune di Magliano in Toscana che integra tutti i servizi tecnici e amministrativi in un unico sistema. Permette di gestire workflow, documenti, dati territoriali e urbanistici, automazioni degli edifici e flussi di comunicazione, migliorando efficienza, sicurezza e coordinamento tra uffici e sedi.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Docker](https://img.shields.io/badge/docker-required-blue.svg)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16+-blue.svg)
![AI](https://img.shields.io/badge/AI-Ollama-green.svg)

-----

## 📋 **Indice**

- [Servizi e Container](#-servizi-e-container-principali)
- [Architettura Database](#-architettura-database-avanzata)
- [Requisiti Hardware](#-requisiti-hardware)
- [Installazione Rapida](#-installazione-rapida)
- [Struttura Repository](#-struttura-del-repository)
- [Backup e Ripristino](#-backup-e-ripristino)
- [Modelli AI](#-modelli-ai-consigliati)
- [Accesso Remoto](#-accesso-remoto-sicuro)
- [Manutenzione](#-manutenzione)

-----

## 🐳 **Servizi e Container Principali**

|Servizio / Container                  |Funzione                                                              |Porta     |
|--------------------------------------|----------------------------------------------------------------------|----------|
|**n8n**                               |Workflow e automazioni interne                                        |-         |
|**PostgreSQL 16 + pgvector + PostGIS**|Database centrale: relazionale, vettoriale (AI/RAG), dati GIS spaziali|-         |
|**Redis**                             |Cache e code per workflow e AI                                        |-         |
|**Ollama**                            |AI locale (LLM: GPT4OSS 20B, Qwen2.5 7B)                              |11434     |
|**MinIO**                             |Storage S3-compatible per file e documenti                            |9000, 9001|
|**FileBrowser**                       |Interfaccia web per gestione file                                     |8081      |
|**Home Assistant**                    |Gestione automazioni IoT e edifici pubblici                           |8123      |
|**QGIS Server**                       |Servizi WMS/WFS per shapefile e dati GIS                              |8082      |
|**Adminer**                           |Gestione database via web                                             |8080      |
|**ZeroTier**                          |VPN sicura multi-edificio                                             |-         |
|**Cloudflare Tunnel**                 |Accesso remoto sicuro senza aprire porte                              |-         |
|**Watchtower**                        |Aggiornamento automatico container                                    |-         |

-----

## 🗄️ **Architettura Database Avanzata**

### **PostgreSQL 16 - Tripla Funzionalità**

Il database PostgreSQL integra **tre sistemi in uno**:

#### 1️⃣ **Database Relazionale (Classico)**

- Dati strutturati N8N
- Workflow e credenziali
- Anagrafica cittadini, pratiche

#### 2️⃣ **Database Vettoriale (pgvector)**

- Embeddings per AI/RAG
- Ricerca semantica documenti
- Similarity search per pratiche simili

```sql
-- Esempio: trova documenti simili
SELECT nome, 1 - (embedding <=> $1::vector) as similarity 
FROM documenti 
ORDER BY embedding <=> $1::vector 
LIMIT 10;
```

#### 3️⃣ **Database Spaziale (PostGIS)**

- Coordinate GPS edifici comunali
- Confini catastali e particelle
- Analisi territoriali e GIS

```sql
-- Esempio: trova edifici entro 500m dal municipio
SELECT nome, ST_Distance(posizione::geography, $punto_municipio::geography) 
FROM edifici 
WHERE ST_DWithin(posizione::geography, $punto_municipio::geography, 500);
```

### **Estensioni Installate**

- ✅ `vector` - Embeddings AI
- ✅ `postgis` - Geometrie e coordinate
- ✅ `postgis_topology` - Reti e topologia
- ✅ `postgis_raster` - Dati raster satellitari
- ✅ `uuid-ossp` - Generazione UUID
- ✅ `hstore` - Key-value store
- ✅ `pg_trgm` - Ricerca fuzzy

-----

## 💻 **Requisiti Hardware**

### **Minimo (Setup Base)**

- CPU: 4 core
- RAM: 16GB
- Storage: 100GB SSD
- GPU: Opzionale (CPU inference lento)

### **Consigliato (Setup Production)**

- CPU: 8+ core
- RAM: 32GB+
- Storage: 500GB+ SSD NVMe
- GPU: NVIDIA con 8GB+ VRAM (RTX 3060+)

### **Ottimale (Setup Enterprise)**

- CPU: 16+ core
- RAM: 64-256GB
- Storage: 1TB+ SSD NVMe
- GPU: NVIDIA RTX 4090 / 5090 (32GB VRAM)

-----

## 🚀 **Installazione Rapida**

### **Prerequisiti**

```bash
# Docker + Docker Compose
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER

# NVIDIA Docker (se hai GPU)
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
sudo apt-get update && sudo apt-get install -y nvidia-docker2
sudo systemctl restart docker
```

### **Setup Automatico**

```bash
# 1. Clona repository
git clone https://github.com/leobartoli/Magliano-Smart.git
cd Magliano-Smart

# 2. Esegui setup
chmod +x setup.sh
./setup.sh

# 3. Configura password
nano .env
# Cambia tutte le password con CAMBIAMI_

# 4. Avvia servizi
docker compose up -d

# 5. Verifica
docker compose ps
docker compose logs -f

# 6. Scarica modelli AI
docker exec -it ollama ollama pull gpt4o:20b
docker exec -it ollama ollama pull qwen2.5:7b

# 7. Verifica database
docker exec -it postgres psql -U n8n -d n8n -c "\dx"
```

-----

## 📁 **Struttura del Repository**

```
Magliano-Smart/
├── docker-compose.yml           # Configurazione container
├── .env                         # Variabili ambiente (NON committare)
├── .env.example                 # Template configurazione
├── .gitignore                   # Protezione file sensibili
├── setup.sh                     # Script setup automatico
├── backup-to-onedrive.sh        # Backup automatico su OneDrive
│
├── init-db/                     # Init database
│   └── 01-init-extensions.sql   # Setup pgvector + PostGIS
│
├── backups/                     # Backup locali (NON committare)
│   ├── postgres/                # Dump database
│   ├── n8n/                     # Backup workflow
│   ├── minio/                   # Backup storage
│   └── homeassistant/           # Backup domotica
│
├── shared/                      # File condivisi (NON committare)
│   ├── documents/               # Documenti comunali
│   ├── shapefiles/              # Dati GIS
│   └── uploads/                 # File caricati
│
├── workflows/                   # Workflow N8N esportati
│   ├── protocollo-entrata.json
│   ├── gestione-pratiche.json
│   └── ai-document-analysis.json
│
├── docs/                        # Documentazione
│   ├── backup-restore.md        # Guida backup
│   ├── database-schema.md       # Schema database
│   ├── ai-models.md             # Guida modelli AI
│   └── gis-integration.md       # Integrazione GIS
│
└── README.md                    # Questo file
```

-----

## 💾 **Backup e Ripristino**

### **Backup Automatico su OneDrive Aziendale**

#### **Setup Rclone**

```bash
# 1. Installa rclone
curl https://rclone.org/install.sh | sudo bash

# 2. Configura OneDrive
rclone config
# Segui wizard e autentica con account aziendale

# 3. Test connessione
rclone lsd onedrive:
```

#### **Backup Manuale**

```bash
# Esegui backup completo
./backup-to-onedrive.sh

# Verifica su OneDrive
rclone ls onedrive:/Magliano-Smart-Backup
```

#### **Backup Automatico (Cron)**

```bash
# Apri crontab
crontab -e

# Backup giornaliero alle 3:00 AM
0 3 * * * cd /path/to/Magliano-Smart && ./backup-to-onedrive.sh >> logs/backup.log 2>&1
```

### **Restore da Backup**

#### **PostgreSQL**

```bash
# Scarica backup
rclone copy onedrive:/Magliano-Smart-Backup/postgres/db_latest.dump.gz ./restore/

# Ripristina
gunzip < ./restore/db_latest.dump.gz | docker exec -i postgres pg_restore -U n8n -d n8n --clean
```

#### **N8N Workflows**

```bash
# Scarica backup
rclone copy onedrive:/Magliano-Smart-Backup/n8n/n8n_latest.tar.gz ./restore/

# Ripristina volume
docker run --rm -v n8n_data:/data -v ./restore:/backup alpine tar xzf /backup/n8n_latest.tar.gz -C /
```

### **Backup su OneDrive**

```
OneDrive/Magliano-Smart-Backup/
├── postgres/
│   ├── db_20250114_030000.dump.gz
│   └── db_20250113_030000.dump.gz
├── n8n/
│   ├── n8n_20250114_030000.tar.gz
│   └── n8n_20250113_030000.tar.gz
└── minio/
    └── files_20250114_030000.tar.gz
```

**Retention**: 30 giorni di backup

-----

## 🤖 **Modelli AI Consigliati**

### **Hardware: RTX 5090 (32GB VRAM)**

|Modello             |Dimensione|VRAM|Uso                      |Comando                          |
|--------------------|----------|----|-------------------------|---------------------------------|
|**GPT4OSS 20B**     |~11GB     |11GB|Chat, codice, generale   |`ollama pull gpt4o:20b`          |
|**Qwen2.5 7B**      |~4.7GB    |5GB |Multilingua, ragionamento|`ollama pull qwen2.5:7b`         |
|**Mistral 7B**      |~4GB      |4GB |Veloce, efficiente       |`ollama pull mistral:7b`         |
|**Llama 3.2 Vision**|~7GB      |7GB |Analisi immagini         |`ollama pull llama3.2-vision:11b`|

**Totale caricato contemporaneamente**: ~16GB / 32GB (spazio per altro)

### **Uso nei Workflow N8N**

```javascript
// HTTP Request Node a Ollama
URL: http://ollama:11434/api/generate
Method: POST
Body:
{
  "model": "gpt4o:20b",
  "prompt": "Analizza questo documento e estrai i dati anagrafici",
  "stream": false
}
```

### **Esempi Pratici**

- **Protocollo automatico**: GPT4OSS estrae mittente, oggetto, data
- **RAG su pratiche**: pgvector cerca pratiche simili semanticamente
- **Analisi planimetrie**: Llama Vision legge file PDF/immagini
- **Chatbot cittadini**: Qwen2.5 risponde in italiano

-----

## 🌐 **Accesso Remoto Sicuro**

### **Opzione 1: ZeroTier (VPN)**

- Connessione diretta tra edifici comunali
- Nessuna porta aperta su internet
- Network ID configurato in `.env`

### **Opzione 2: Cloudflare Tunnel**

- Accesso HTTPS senza aprire porte
- Dominio personalizzato (n8n.leonardobartoli.org)
- Token configurato in `.env`

### **Accesso ai Servizi**

|Servizio      |URL Locale           |URL Remoto (Cloudflare)        |
|--------------|---------------------|-------------------------------|
|N8N           |-                    |https://n8n.leonardobartoli.org|
|MinIO Console |http://localhost:9001|-                              |
|FileBrowser   |http://localhost:8081|-                              |
|Home Assistant|http://localhost:8123|-                              |
|Adminer       |http://localhost:8080|-                              |
|QGIS Server   |http://localhost:8082|-                              |

-----

## 🔧 **Manutenzione**

### **Aggiornamento Container**

```bash
# Watchtower aggiorna automaticamente ogni giorno
# Oppure manualmente:
docker compose pull
docker compose up -d
```

### **Pulizia Sistema**

```bash
# Rimuovi immagini vecchie
docker system prune -a

# Rimuovi volumi inutilizzati
docker volume prune
```

### **Monitoraggio**

```bash
# Status servizi
docker compose ps

# Log in tempo reale
docker compose logs -f

# Log singolo servizio
docker compose logs -f postgres

# Utilizzo risorse
docker stats

# GPU (se NVIDIA)
watch -n 1 nvidia-smi
```

### **Verifica Database**

```bash
# Connetti a PostgreSQL
docker exec -it postgres psql -U n8n -d n8n

# Verifica estensioni
\dx

# Verifica tabelle
\dt

# Test pgvector
SELECT '[1,2,3]'::vector <-> '[4,5,6]'::vector;

# Test PostGIS
SELECT ST_AsText(ST_MakePoint(11.1576, 42.5950)) as municipio;
```

-----

## 📚 **Documentazione Aggiuntiva**

- **Workflow N8N**: <workflows/README.md>
- **Setup Database**: <docs/database-schema.md>
- **Modelli AI**: <docs/ai-models.md>
- **Integrazione GIS**: <docs/gis-integration.md>
- **Backup/Restore**: <docs/backup-restore.md>

-----

## 🤝 **Supporto**

Per problemi o domande:

- **Issues**: [GitHub Issues](https://github.com/leobartoli/Magliano-Smart/issues)
- **Email**: leonardo.bartoli@comune.maglianointoscana.gr.it

-----

## 📝 **License**

MIT License - Vedi <LICENSE> per dettagli

-----

## 🎯 **Roadmap**

- [ ] Dashboard unificata citizen-facing
- [ ] App mobile per segnalazioni cittadini
- [ ] Integrazione SPID/CIE
- [ ] OCR automatico su documenti scansionati
- [ ] Chatbot AI per assistenza cittadini
- [ ] Integrazione PagoPA per pagamenti online

-----

**Made with ❤️ for Comune di Magliano in Toscana**