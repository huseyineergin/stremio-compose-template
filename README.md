# Stremio Compose Template

This is a simplified version of [Viren070's template](https://github.com/Viren070/docker-compose-template) with several modifications, focusing on Stremio and monitoring services.

## Contents

- [Services](#services)
- [VPS Setup](#vps-setup)
    * [Essential Setup](#essential-setup)
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
- **[WARP-Docker](https://github.com/cmj2002/warp-docker)** runs official [Cloudflare WARP](https://1.1.1.1) client in Docker.

## VPS Setup

Follow [Viren070's selfhosting guide](https://guides.viren070.me/selfhosting) to set up an Oracle VPS, or use an existing one. This section focuses on what to do after creating a VPS instance to walk through the essential post-setup steps to turn it into a "production-ready" server. Most of this section is based on **“My First 5 Minutes on a Server; or, Essential Security for Linux Servers”** by Bryan Kennedy.

> **Note:** The following instructions are written for Debian/Ubuntu. Commands may vary depending on the Linux distribution.

### Essential Setup

As the first step, log in to the VPS as the `root` user using SSH.
```sh
ssh -i /path/to/private/key root@VPS_PUBLIC_IP
```

#### 1. Change Root Password

Change the `root` password to something long and complex. This password should be stored securely. It is needed if SSH access is lost or the `sudo` password needs to be recovered.
```sh
passwd
```

#### 2. Update and Upgrade Packages

Update the package list and upgrade all installed packages to their latest versions.
```sh
apt-get update && apt-get upgrade -y
```

Install `fail2ban`. It is a daemon that monitors login attempts to a server and blocks suspicious activity as it occurs. It’s well configured out of the box.
```sh
apt install fail2ban
```

#### 3. Add a New User

Add a login user. Feel free to name the user something besides `debian`.
```sh
useradd -s /bin/bash -m debian
mkdir /home/debian/.ssh
chmod 700 /home/debian/.ssh
```

Set a password for the login user. Use a complex password. This password will be used for `sudo` access.
```sh
passwd debian
```

Add login user to the `sudoers`.
```sh
usermod -aG sudo debian
```

#### 4. Configure Public Key Authentication

Add public keys for authentication. It'll enhance security and ease of use by ditching passwords and employing [public key authentication](https://en.wikipedia.org/wiki/Public-key_cryptography) for user accounts. Add the contents of the local public key file, along with any additional public keys requiring access to this server, to this file.
```sh
vim /home/debian/.ssh/authorized_keys
# ...
chmod 400 /home/debian/.ssh/authorized_keys
chown debian:debian /home/debian -R
```

#### 5. Harden SSH Configuration

Configure SSH to prevent password and `root` logins.
```sh
vim /etc/ssh/sshd_config
```

Add the following lines to the file.
```conf
PermitRootLogin no
PasswordAuthentication no
```

Restart SSH.
```sh
service ssh restart
# or
systemctl restart ssh.service
```

#### 6. Configure Firewall

Set up a firewall. [`ufw`](https://wiki.debian.org/Uncomplicated%20Firewall%20%28ufw%29) and [`firewalld`](https://firewalld.org/) provide a simple setup, while [`iptables`](https://wiki.archlinux.org/title/Iptables) and [`nftables`](https://wiki.nftables.org/wiki-nftables/index.php/Main_Page) offer more advanced configuration options.
```sh
ufw allow <SOURCE_PUBLIC_IP> to any port 22
ufw allow 80
ufw allow 443
```
This sets up a basic firewall and allows traffic on ports 80 and 443.

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
