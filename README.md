# Stremio Compose Template

This is a simplified version of [Viren070's template](https://github.com/Viren070/docker-compose-template) with several modifications, focusing on Stremio and monitoring services.

## Contents

- [Services](#services)
- [Getting Started](#getting-started)
    * [Prerequisites](#prerequisites)
    * [Installation](#installation)
    * [Post-Installation](#post-installation)

## Services

- **[AIOMetadata](https://github.com/cedya77/aiometadata)** aggregates and enriches movie, series, and anime metadata from multiple sources.
- **[AIOStreams](https://github.com/Viren070/AIOStreams)** consolidates multiple Stremio addons and debrid services, including its own suite of built-in addons, into a single, highly customisable super-addon.
- **[Authelia](https://www.authelia.com/)** is an open-source authentication and authorization server and portal.
- **[Beszel](https://beszel.dev/)** is a lightweight server monitoring platform that includes Docker statistics, historical data, and alert functions.
- **[Dozzle](https://dozzle.dev/)** is a lightweight, web-based log viewer designed to simplify monitoring and debugging containerized applications across Docker, Docker Swarm, and Kubernetes environments.
- **[Honey](https://github.com/dani3l0/honey)** is a simple dashboard/homepage for organizing and quickly accessing self-hosted services.
- **[MediaFlow Proxy](https://github.com/mhdzumair/mediaflow-proxy)** is a powerful and flexible solution for proxifying various types of media streams.
- **[Traefik](https://github.com/traefik/traefik)** is a modern HTTP reverse proxy and load balancer that makes deploying microservices easy.
- **[Uptime Kuma](https://github.com/louislam/uptime-kuma)** is an easy-to-use self-hosted monitoring tool.

## Getting Started

### Prerequisites

- A VPS with [Docker](https://www.docker.com/) installed. Follow the [official installation steps](https://docs.docker.com/engine/install/) for the selected platform.
- Ports 80 and 443 are accessible on the VPS.
- A domain with DNS records configured to point to the VPS IP for each domain or subdomain in use.

### Installation

1\. Prepare the installation folder.
```sh
sudo mkdir /opt/stremio
sudo chown PUID:PGID /opt/stremio
```

> **Note:** The PUID and PGID can be found by running the `id` command.

2\. Clone this repository and navigate into it:
```sh
cd /opt
git clone https://github.com/huseyineergin/stremio-compose-template.git stremio
cd stremio
```

3\. Use a text editor (nano, vim) to open the `.env` file. VS Code (with the `Remote - SSH` extension) can also be used to edit the files.
```sh
vim .env
```

4\. Set the following values in the `.env` file:
- `PUID`
- `PGID`
- `DOMAIN`
- `AUTHELIA_JWT_SECRET`
- `AUTHELIA_SESSION_SECRET`
- `AUTHELIA_STORAGE_ENCRYPTION_KEY`

5\. Set the following values in the `apps/aiometadata/.env` file:
- `TMDB_API`
- `TVDB_API_KEY`

6\. Set the following values in the `apps/aiostreams/.env` file:
- `ADDON_ID`
- `SECRET_KEY`
- `ADDON_PASSWORD`
- `DATABASE_URI`
- `ADDON_PROXY` (Optional)

When using PostgreSQL for AIOStreams’ database, set `POSTGRES_PASSWORD`, `POSTGRES_USER`, and `POSTGRES_DB`.

> **Note:** When NOT using PostgreSQL for AIOStreams’ database, comment out the PostgreSQL related entries in `apps/aiostreams/compose.yaml` file.

7\. Set the following values in the `apps/authelia/.env` file:
- `POSTGRES_PASSWORD`
- `POSTGRES_USER`
- `POSTGRES_DB`

8\. Define the users in the `apps/authelia/config/users.yaml` file:
```yaml
users:
  john.doe:
    disabled: false
    displayname: "John Doe"
    # Generate the Argon2 password hash using the following command:
    # docker run --rm authelia/authelia:latest authelia crypto hash generate argon2 --password 'password'
    password: "$argon2id$v=19$m=65536,t=3,p=4$grHh7x/AakOfCsD0+TLv4g$xVGlLlhf5qnw0HhgP9mbB86VxF5llEOP0iBE3k0y05M"
    email: "john.doe@example.com"
    groups:
      - "admins"
      - "dev"
```

9\. Set the following values in the `apps/mediaflow-proxy/.env` file:
- `API_PASSWORD`
- `PROXY_URL` (Optional)

10\. Set the email address in the `apps/traefik/traefik.yaml` file:
```yaml
certificatesResolvers:
  letsencrypt:
    acme:
      email: you@example.com # change this
      storage: /letsencrypt/acme.json
      httpChallenge:
        entryPoint: web
```

11\. Run the `init` service. This sets up required folders and configures permissions.
```sh
docker compose up -d init
```

12\. Start the services:
```sh
docker compose --profile all up -d
```

Once the services are running, follow the instructions in the `apps/beszel/.env` file to set up Beszel.

### Post-Installation

#### Mediaflow Proxy

In the `Proxy` menu of AIOStreams setup, set the following values:
- **Proxy Service**: Select `Mediaflow Proxy`.
- **URL**: Enter `http://mediaflow-proxy:8888`.
- **Public URL**: Enter `https://mediaflow.DOMAIN.com`.
- **Credentials**: Enter the value of `API_PASSWORD` in the `apps/mediaflow-proxy/.env` file.
