#!/usr/bin/env python3
import subprocess
import os
import sys
from datetime import datetime

# 9 volumi da ripristinare

VOLUMES = [
“n8n_data”,
“pg_data”,
“redis_data”,
“ollama_data”,
“minio_data”,
“filebrowser_data”,
“homeassistant_data”,
“qgis_projects”,
“zerotier_data”
]

if len(sys.argv) < 2:
print(“❌ Uso: python restore_volumes.py <backup_folder>”)
print(”\nEsempio:”)
print(“python restore_volumes.py backups/2025-10-16_15-30-45”)
sys.exit(1)

backup_dir = sys.argv[1]

if not os.path.exists(backup_dir):
print(f”❌ Cartella non trovata: {backup_dir}”)
sys.exit(1)

print(f”🔄 Ripristino in corso da: {backup_dir}\n”)

results = {}

for volume in VOLUMES:
backup_file = f”{backup_dir}/{volume}.tar.gz”

```
if not os.path.exists(backup_file):
    print(f"⚠️  {volume}: file non trovato ({backup_file})")
    results[volume] = "⚠️ file non trovato"
    continue

try:
    print(f"📦 Ripristinando {volume}...", end=" ", flush=True)
    
    # Rimuovi volume vecchio
    subprocess.run([
        "docker", "volume", "rm", volume
    ], capture_output=True)
    
    # Crea volume nuovo
    subprocess.run([
        "docker", "volume", "create", volume
    ], check=True, capture_output=True)
    
    # Ripristina da backup
    subprocess.run([
        "docker", "run", "--rm",
        "-v", f"{volume}:/volume",
        "-v", f"{os.path.abspath(backup_dir)}:/backup",
        "alpine",
        "tar", "-xzf", f"/backup/{volume}.tar.gz", "-C", "/volume"
    ], check=True, capture_output=True)
    
    results[volume] = "✅"
    print(f"✅")
    
except Exception as e:
    results[volume] = f"❌ {str(e)}"
    print(f"❌ Errore: {e}")
```

print(f”\n{’=’*50}”)
print(f”✅ RIPRISTINO COMPLETATO!”)
print(f”{’=’*50}\n”)

# Mostra riepilogo

for volume, status in results.items():
print(f”{volume}: {status}”)

print(f”\n⚠️  Ricorda di riavviare Docker Compose:”)
print(f”docker-compose down”)
print(f”docker-compose up -d”)
