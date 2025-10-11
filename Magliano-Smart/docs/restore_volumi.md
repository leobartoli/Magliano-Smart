# Ripristino Volumi Docker - Magliano-Smart

Questo documento spiega come ripristinare i volumi Docker del progetto **Magliano-Smart** utilizzando gli archivi di backup `.tar.gz` creati dallo script `backup_volumes.py`.

---

## 1️⃣ Posizione dei backup

I backup si trovano generalmente in:

```
Magliano-Smart/backup/YYYYMMDD_HHMMSS/
```

Ogni volume è salvato come archivio `.tar.gz`, ad esempio:

```
n8n.tar.gz
postgres.tar.gz
redis.tar.gz
...
```

---

## 2️⃣ Comando generale per ripristinare un volume

Apri terminale (Linux/macOS) o PowerShell (Windows) e usa il seguente comando:

```bash
docker run --rm -v <nome_volume>:/volume -v /percorso/backup:/backup alpine sh -c "cd /volume && tar xzf /backup/<nome_volume>.tar.gz"
```

* `<nome_volume>` → nome del volume da ripristinare (es. `n8n`, `postgres`, `redis`)
* `/percorso/backup` → percorso locale della cartella di backup contenente l’archivio `.tar.gz`

---

### **Esempio pratico**

Supponiamo di voler ripristinare il volume `n8n` da un backup creato il 11 ottobre 2025:

```bash
docker run --rm -v n8n:/volume -v C:\Magliano-Smart\backup\20251011_120000:/backup alpine sh -c "cd /volume && tar xzf /backup/n8n.tar.gz"
```

---

## 3️⃣ Ripristino di tutti i volumi

Per ripristinare tutti i volumi definiti nel progetto, ripeti il comando per ogni volume:

| Volume          |
| --------------- |
| `n8n`           |
| `postgres`      |
| `redis`         |
| `wyoming_cache` |
| `minio`         |
| `filebrowser`   |
| `qgis_projects` |
| `homeassistant` |

**Suggerimento:** puoi creare uno script `restore_volumes.sh` o `.ps1` per automatizzare il ripristino di tutti i volumi in sequenza.

---

## 4️⃣ Suggerimenti pratici

* Assicurati che i container che usano i volumi siano **fermi** prima del ripristino.
* Controlla la disponibilità dello spazio su disco.
* Mantieni una copia dei backup originale fino a verificare che i volumi siano correttamente ripristinati.

---

Se vuoi, posso anche **scrivere lo script automatico di restore cross-platform** simile allo script di backup, così puoi ripristinare tutti i volumi in un solo comando.

Vuoi che lo faccia?
