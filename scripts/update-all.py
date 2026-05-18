#!/usr/bin/env python3
import subprocess
import socket
import sys

REPO_DIR = "~/git/nixos.den"
HOSTS = ["valako", "kitava", "hinekora"]
CURRENT_HOST = socket.gethostname()

failed = []

for host in HOSTS:
    if host == CURRENT_HOST:
        print(f"  Skipping {host} (current host)")
        continue

    print(f">>> Updating {host}")
    cmd = f"git -C {REPO_DIR} fetch origin && git -C {REPO_DIR} reset --hard origin/main && sudo nixos-rebuild switch --flake {REPO_DIR}#{host}"
    result = subprocess.run(["ssh", "-t", host, cmd])

    if result.returncode == 0:
        print(f">>> {host} updated successfully")
    else:
        print(f">>> {host} FAILED")
        failed.append(host)

if failed:
    print(f">>> Failures: {' '.join(failed)}")

answer = input(f"\n>>> Update {CURRENT_HOST} (current host)? [y/N] ").strip().lower()
if answer == "y":
    cmd = f"git -C {REPO_DIR} fetch origin && git -C {REPO_DIR} reset --hard origin/main && sudo nixos-rebuild switch --flake {REPO_DIR}#{CURRENT_HOST}"
    subprocess.run(cmd, shell=True)

if failed:
    sys.exit(1)

print(">>> All hosts updated")