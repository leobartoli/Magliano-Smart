Perfetto! Ti creo un **file Markdown `backup.md`** da inserire nella cartella `docs/` del repository, che spiega in modo chiaro come fare backup e ripristino dei volumi Docker usando lo script Python cross-platform.

---

# Backup Volumi Docker - Magliano-Smart

Questo documento spiega come eseguire il **backup e ripristino dei volumi Docker** del progetto **Magliano-Smart**, sia su Linux/macOS che Windows, utilizzando lo script Python `backup_volumes.py`.

---

## 1️⃣ Posizione dello script

Lo script si trova in:

```
Magliano-Smart/scripts/backup_volumes.py
```

---

## 2️⃣ Eseguire il backup

1. Apri terminale (Linux/macOS) o PowerShell (Windows).
2. Vai nella cartella `scripts/`:

```bash
cd /percorso/Magliano-Smart/scripts
```

3. Esegui lo script Python:

```bash
python backup_volumes.py
```

4. Verrà creata una cartella `backup/YYYYMMDD_HHMMSS/` contenente gli archivi `.tar.gz` di tutti i volumi definiti.

**Nota:** Per centralizzare i backup nella root del progetto, lo script salva automaticamente in `Magliano-Smart/backup/`.

---

## 3️⃣ Ripristinare un volume

Per ripristinare un singolo volume, usa questo comando:

```bash
docker run --rm -v nome_volume:/volume -v /percorso/backup:/backup alpine sh -c "cd /volume && tar xzf /backup/nome_volume.tar.gz"
```

Esempio:

```bash
docker run --rm -v n8n:/volume -v C:\Magliano-Smart\backup\20251011_120000:/backup alpine sh -c "cd /volume && tar xzf /backup/n8n.tar.gz"
```

---

## 4️⃣ Volumi gestiti dallo script

| Volume          | Descrizione                                     |
| --------------- | ----------------------------------------------- |
| `n8n`           | Workflow e automazioni                          |
| `postgres`      | Database centrale con pgvector                  |
| `redis`         | Cache e queue                                   |
| `wyoming_cache` | Cache AI / TTS / STT                            |
| `minio`         | Storage centralizzato file e documenti          |
| `filebrowser`   | Interfaccia gestione file                       |
| `qgis_projects` | Dati GIS e shapefile                            |
| `homeassistant` | Configurazioni Home Assistant e automazioni IoT |

---

## 5️⃣ Suggerimenti pratici

* Pianifica backup automatici con **cron** (Linux/macOS) o **Task Scheduler** (Windows).
* Non includere le credenziali nel backup, lo script salva solo i dati dei volumi.
* Mantieni una copia dei backup esternamente per sicurezza.

---

Se vuoi, posso creare anche una versione **sintetica di “quick guide” in Markdown**, da usare come promemoria veloce per il personale tecnico del Comune.

Vuoi che lo faccia?
