#!/usr/bin/env python3
"""
Backup volumi Docker cross-platform
Compatibile Linux, macOS e Windows
Salva i volumi definiti nella cartella ./backup/YYYYMMDD_HHMMSS/
"""

import os
import subprocess
from datetime import datetime

# Lista dei volumi da salvare
VOLUMES = [
    "n8n",
    "postgres",
    "redis",
    "wyoming_cache",
    "minio",
    "filebrowser",
    "qgis_projects",
    "homeassistant"
]

# Cartella di backup con data
backup_dir = os.path.join(os.getcwd(), "backup", datetime.now().strftime("%Y%m%d_%H%M%S"))
os.makedirs(backup_dir, exist_ok=True)

print(f"Cartella backup: {backup_dir}\n")

for volume in VOLUMES:
    print(f"Backing up volume: {volume}")
    try:
        subprocess.run([
            "docker", "run", "--rm",
            "-v", f"{volume}:/volume",
            "-v", f"{backup_dir}:/backup",
            "alpine",
            "tar", "czf", f"/backup/{volume}.tar.gz", "-C", "/volume", "."
        ], check=True)
    except subprocess.CalledProcessError:
        print(f"Errore nel backup del volume {volume}")

print("\nBackup completato!")
