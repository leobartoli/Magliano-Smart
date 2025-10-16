#!/usr/bin/env python3
import subprocess
import os
from datetime import datetime
import json

# 8 volumi da backuppare

VOLUMES = [
“n8n_data”,
“pg_data”,
“redis_data”,
“ollama_data”,
“minio_data”,
“filebrowser_data”,
“homeassistant_data”,
“qgis_projects”
]

timestamp = datetime.now().strftime(”%Y-%m-%d_%H-%M-%S”)
backup_dir = f”backups/{timestamp}”

os.makedirs(backup_dir, exist_ok=True)

print(f”🔄 Backup in corso: {backup_dir}\n”)

results = {}

for volume in VOLUMES:
try:
backup_file = f”{backup_dir}/{volume}.tar.gz”

```
    print(f"📦 Backuppando {volume}...", end=" ", flush=True)
    
    subprocess.run([
        "docker", "run", "--rm",
        "-v", f"{volume}:/volume",
        "-v", f"{os.path.abspath(backup_dir)}:/backup",
        "alpine",
        "tar", "-czf", f"/backup/{volume}.tar.gz", "-C", "/volume", "."
    ], check=True, capture_output=True)
    
    size = os.path.getsize(backup_file) / (1024 * 1024)  # MB
    results[volume] = {"status": "✅", "size_mb": round(size, 2)}
    print(f"✅ ({size:.2f} MB)")
    
except Exception as e:
    results[volume] = {"status": "❌", "error": str(e)}
    print(f"❌ Errore: {e}")
```

# Salva report

report_file = f”{backup_dir}/report.json”
with open(report_file, “w”) as f:
json.dump(results, f, indent=2)

print(f”\n{’=’*50}”)
print(f”✅ BACKUP COMPLETATO!”)
print(f”📁 Percorso: {os.path.abspath(backup_dir)}”)
print(f”📊 Report: {report_file}”)
print(f”{’=’*50}\n”)

# Mostra riepilogo

for volume, result in results.items():
if result[“status”] == “✅”:
print(f”{volume}: {result[‘status’]} ({result[‘size_mb’]} MB)”)
else:
print(f”{volume}: {result[‘status’]} - {result.get(‘error’, ‘Errore sconosciuto’)}”)
