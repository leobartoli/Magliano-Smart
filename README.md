
# Magliano-Smart

**Magliano-Smart** è la piattaforma digitale del Comune di Magliano in Toscana che integra tutti i servizi tecnici e amministrativi in un unico sistema. Permette di gestire workflow, documenti, dati territoriali e urbanistici, automazioni degli edifici e flussi di comunicazione, migliorando efficienza, sicurezza e coordinamento tra uffici e sedi.

---

## **Servizi e container principali**

| Servizio / Container             | Funzione                                                   |
| -------------------------------- | ---------------------------------------------------------- |
| **n8n**                          | Workflow e automazioni interne                             |
| **PostgreSQL + pgvector**        | Database centrale per dati strutturati e RAG AI            |
| **Redis**                        | Cache e code per workflow e AI                             |
| **MinIO**                        | Storage centralizzato dei file e documenti                 |
| **Filebrowser**                  | Interfaccia interna per gestione file                      |
| **Home Assistant**               | Gestione automazioni IoT e edifici pubblici                |
| **QGIS Server**                  | Gestione shapefile e dati GIS                              |
| **Ollama / Wyoming**             | AI locale, TTS e STT                                       |
| **ZeroTier / Cloudflare Tunnel** | Accesso sicuro multi-edificio e VPN container-to-container |
| **Watchtower**                   | Aggiornamento automatico dei container                     |

---

## **Struttura del repository**

```
Magliano-Smart/
├── docker/                     # Configurazioni container
│   ├── docker-compose.yml
│   ├── .env.example
│   └── init-scripts/
│       └── init-pgvector.sql
├── volumes/                     # Dati persistenti container
├── docs/                        # Documentazione
│   ├── backup_volumi.md
│   ├── restore_volumi.md
│   └── (altre guide e diagrammi)
├── scripts/                     # Script manutenzione
│   ├── backup_volumes.py
│   └── restore_volumes.py
├── workflows/                   # Workflow n8n esportati
├── ai-models/                   # Modelli Ollama / Wyoming
├── shapefiles/                  # Dati GIS del Comune
└── README.md                    # Descrizione progetto
```

---

## **Backup e ripristino dei volumi**

* **Backup:** esegui `scripts/backup_volumes.py`. I volumi saranno salvati in `backup/YYYYMMDD_HHMMSS/`.
* **Ripristino:** esegui `scripts/restore_volumes.py` indicando la cartella del backup da ripristinare.
* Vedi la documentazione completa in:

  * [Backup Volumi](docs/backup_volumi.md)
  * [Restore Volumi](docs/restore_volumi.md)

---

## **Suggerimenti pratici**

* Mantieni i dati permanenti separati da cache e file temporanei.
* Pianifica backup regolari e conserva copie esterne.
* Arresta i container prima di ripristinare i volumi.
* Aggiorna la documentazione dei workflow e dei modelli AI quando aggiungi nuove funzionalità.

---

## **Note finali**

Questo repository è progettato per essere **modulare e scalabile**, pronto per gestire più edifici, uffici e flussi tecnici comunali senza complicazioni.