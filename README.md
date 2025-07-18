# MCP Core Daemon (Docker)

A production‑ready container image and `docker‑compose` manifest for the **MCP Core Daemon**, exposing the daemon via a **JSON‑RPC/SSE** streaming endpoint. The image is built on the official Python 3.11 slim base and bundles the [MCP Python SDK](https://pypi.org/project/mcp/) together with a minimal Alpine‑like footprint.

---

## ✨ Features

* **JSON‑RPC/SSE transport** — bi‑directional, real‑time streaming on `/:port/jsonrpc/sse`.
* **One‑step bootstrap** with `docker‑compose up -d`.
* **Hot‑reloadable configuration** – mount your `*.json` config under `/app/data`.
* **Supervisor‑managed lifecycle** – automatic restart on failure.
* **Slim, reproducible build** using [`uv`](https://github.com/astral-sh/uv) for lightning‑fast dependency resolution.

---

## 📂 Repository layout

```text
.
├── Dockerfile              # Container build recipe
├── docker-compose.yml      # Local orchestration
├── .env                    # Sample environment overrides (✏️ edit before use)
├── supervisord.conf        # Process control for mcp-daemon & uvicorn
├── Makefile                # Convenience targets
├── data/                   # Persisted daemon config / state ➜ /app/data
└── logs/                   # Supervisor & daemon logs           ➜ /var/log/supervisor
```

---

## 🚀 Quick start

1. **Clone & configure**

   ```bash
   git clone https://github.com/your‑org/docker‑mcp‑core‑daemon.git
   cd docker‑mcp‑core‑daemon
   cp .env .env.local  # never commit secrets!
   vi .env.local       # set AWS creds, admin password, etc.
   ```

2. **Launch**

   ```bash
   docker compose --env-file .env.local up -d
   # or
   make up
   ```

3. **Verify health**

   * **JSON‑RPC handshake:** `curl -N http://localhost:8000/jsonrpc/sse`
     A valid SSE stream starting with `event: open` confirms readiness.
   * **Container logs:** `docker logs -f mcp-server`

---

## ⚙️ Configuration & environment

| Variable             | Purpose                                                 | Example                     |
| -------------------- | ------------------------------------------------------- | --------------------------- |
| `PORT`               | Internal daemon port                                    | `8000`                      |
| `CONTAINER_PORT`     | Published host port (prefilled in `docker-compose.yml`) | `8000`                      |
| `MCP_ENV`            | Run mode (`production`, `staging`, `dev`)               | `production`                |
| `MCP_CONFIG_FILE`    | Path to daemon JSON config inside the container         | `/app/data/mcp_config.json` |
| `AUTH_PROVIDER`      | `cognito` \| `local`                                    | `cognito`                   |
| `REGION_NAME`        | AWS region for Cognito/JWT validation                   | `us‑west‑2`                 |
| `ADMIN_USERNAME`     | Bootstrap admin user                                    | `admin`                     |
| `ADMIN_PASSWORD`     | Bootstrap admin password                                | `change‑me‑123!`            |
| `ADMIN_STATIC_TOKEN` | Optional pre‑minted JWT for CI or headless access       |                             |

> **Note**  Replace any secrets (keys, passwords, tokens) before deploying.
> For production you should inject them via a secure secrets manager (AWS Secrets Manager, Vault, Doppler, …).

---

## 🔌 Transport details

| Protocol     | Endpoint                           | Description                                  |
| ------------ | ---------------------------------- | -------------------------------------------- |
| JSON‑RPC/SSE | `http://<host>:<port>/jsonrpc/sse` | Full‑duplex JSON‑RPC over Server‑Sent Events |

*Messages sent by the client* MUST be JSON‑RPC 2.0 objects written to the underlying HTTP request body.
*Messages from the daemon* are emitted as SSE `data:` frames, one JSON‑RPC response or notification per line.

---

## 🏗️ Building your own image

```bash
# Build locally
DOCKER_BUILDKIT=1 docker build -t your‑org/mcp‑core:latest .

# Push to registry
docker push your‑org/mcp‑core:latest
```

Customising Python dependencies?  Edit `/` and rebuild.

---

## 🛠️  Make targets

| Target       | Action                       |
| ------------ | ---------------------------- |
| `make build` | Build the container image    |
| `make up`    | Compose up with `--build`    |
| `make down`  | Stop & remove containers     |
| `make logs`  | Tail combined container logs |

---

## 📝 License

This project is licensed under the **MIT License**. See the `LICENSE` file for details.

---

### 🤝 Contributing

1. Fork the repo & create your feature branch (`git checkout -b feature/my‑feature`).
2. Commit your changes (`git commit -am 'feat: add amazing feature'`).
3. Push & open a pull request.

---

## 💡 Troubleshooting

| Symptom                                         | Resolution                                                                        |
| ----------------------------------------------- | --------------------------------------------------------------------------------- |
| `ConnectionRefused` when curling `/jsonrpc/sse` | Ensure `PORT` and `CONTAINER_PORT` match & container is running (`docker ps`).    |
| `401 Unauthorized` responses                    | Check `ADMIN_STATIC_TOKEN`, JWT issuer (`AUTH_PROVIDER`), and AWS Cognito region. |
| Daemon exits immediately                        | Review `/var/log/supervisor/mcp-server-stdio.log` inside the container.           |

---

### Strategic reflection

Careful orchestration of configuration, secrets management, and **observable** container processes is vital for smooth production roll‑outs. Align your deployment pipeline with your broader technology stack & security posture, and always test configuration changes in an isolated environment before promotion.
