#!/bin/sh

# AIOMetadata
mkdir -p /data/aiometadata/data
mkdir -p /data/aiometadata/cache

# AIOStreams
mkdir -p /data/aiostreams/data
mkdir -p /data/aiostreams/db

# Authelia
mkdir -p /data/authelia/db
mkdir -p /data/authelia/cache

# Beszel
mkdir -p /data/beszel/data
mkdir -p /data/beszel/agent
mkdir -p /data/beszel/socket

# Honey
mkdir -p /data/honey

# Traefik
touch /letsencrypt/acme.json
chmod 600 /letsencrypt/acme.json
chown -R "${PUID}:${PGID}" /letsencrypt

# Uptime Kuma
mkdir -p /data/uptime-kuma

chown -R "${PUID}:${PGID}" /data
