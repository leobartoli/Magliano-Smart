#!/usr/bin/env python3
"""
Restore volumi Docker cross-platform
Compatibile Linux, macOS e Windows
Ripristina i volumi definiti dalla cartella di backup
"""

import os
import subprocess

# Lista dei volumi da ripristinare
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

# Cartella backup contenente gli archivi .tar.gz
# Modifica questo percorso con la cartella corretta del backup da ripristinare
backup_dir = input("Inserisci il percorso della cartella di backup: ").strip()

if not os.path.exists(backup_dir):
    print(f"Errore: la cartella {backup_dir} non esiste!")
    exit(1)

print(f"\nRipristino volumi dalla cartella: {backup_dir}\n")

for volume in VOLUMES:
    backup_file = os.path.join(backup_dir, f"{volume}.tar.gz")
    if not os.path.exists(backup_file):
        print(f"[SKIP] Backup non trovato per il volume: {volume}")
        continue

    print(f"Ripristinando volume: {volume}")
    try:
        subprocess.run([
            "docker", "run", "--rm",
            "-v", f"{volume}:/volume",
            "-v", f"{backup_dir}:/backup",
            "alpine",
            "sh", "-c", f"cd /volume && tar xzf /backup/{volume}.tar.gz"
        ], check=True)
    except subprocess.CalledProcessError:
        print(f"[ERROR] Fallito ripristino del volume {volume}")

print("\nRipristino completato!")
