<div align="center">

# 🔬 Kubediag

**Your Kubernetes cluster's best friend — diagnose, monitor, and manage from a single terminal.**

[![Version](https://img.shields.io/badge/version-3.0-blue?style=for-the-badge)](https://github.com/ielyaakouby/kubediag)
[![Shell](https://img.shields.io/badge/shell-bash-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white)](https://www.gnu.org/software/bash/)
[![License](https://img.shields.io/badge/license-MIT-orange?style=for-the-badge)](LICENSE)
[![Kubernetes](https://img.shields.io/badge/kubernetes-ready-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)](https://kubernetes.io/)

An interactive, `fzf`-powered CLI tool for Kubernetes cluster management, real-time monitoring, and automated troubleshooting — no complex `kubectl` commands required.

</div>

---

## ⚡ Quick Start

### Prerequisites

| Tool | Required | Description |
|:-----|:--------:|:------------|
| `kubectl` | ✅ | Kubernetes CLI |
| `fzf` | ✅ | Fuzzy finder for interactive selection |
| `jq` | ✅ | JSON processor |
| `curl` | ⚠️ | HTTP client (connectivity checks) |
| `boxes` | ⚠️ | Text box drawing (optional) |

### Install

**Option 1 — Clone & install**

```bash
git clone https://github.com/ielyaakouby/kubediag.git ~/.kubediag/kubediag
bash ~/.kubediag/kubediag/installer/install.sh
```

**Option 2 — Manual symlink**

```bash
git clone https://github.com/ielyaakouby/kubediag.git ~/.kubediag/kubediag
ln -sf ~/.kubediag/kubediag/bin/kubediag.sh ~/.local/bin/kubediag
chmod +x ~/.local/bin/kubediag
```

**Option 3 — Run directly from the repo**

```bash
chmod +x bin/kubediag.sh
./bin/kubediag.sh
```

After installation, launch from anywhere:

```bash
kubediag
```

### Update

```bash
bash installer/update.sh
```

### Uninstall

```bash
bash installer/uninstall.sh
```

---

## ✨ Features at a Glance

| Category | Capabilities |
|:---------|:-------------|
| 🎯 **Interactive Menus** | `fzf`-powered navigation — no commands to memorize |
| 🔍 **Resource Inspection** | Describe, view YAML, and deep-inspect any K8s resource |
| 📊 **Monitoring** | Real-time pod metrics, node allocation, resource pressure |
| 🔧 **Troubleshooting** | Automated 10-step pod diagnostics pipeline |
| 🚀 **Core Actions** | Scale, restart, rollback, port-forward, exec |
| 🌐 **Networking** | Port forwarding, ingress inspection, connectivity checks |
| 🤖 **AI Analysis** | Optional AI-powered error diagnosis (Gemini / Ollama / OpenAI) |
| 🔐 **Security** | Secret scanning utilities |

---

## 📋 Main Menu

```
┌────────────────────────────────────────┐
│  🔬 Kubediag — Main Menu               │
├────────────────────────────────────────┤
│  ▸ Kubernetes Core Actions             │
│  ▸ Resource Info & Inspect             │
│  ▸ Monitoring & Usage                  │
│  ▸ Troubleshooting Tools               │
│  ▸ View & Describe Resources           │
│  ▸ Fix a Namespace                     │
└────────────────────────────────────────┘
```

---

## 🔍 Troubleshooting Pipeline

The pod diagnostics tool runs a **10-step automated analysis**:

```
 1. Identify affected pods       6. Check node health & resources
 2. Describe pod & check status  7. Verify liveness/readiness probes
 3. Analyze pod logs             8. Validate ingress configuration
 4. Verify owner resources       9. Test backend & external connectivity
 5. Check warnings & events     10. Watch pod status after fixes
```

### Detected Pod States

`CrashLoopBackOff` · `ImagePullBackOff` · `OOMKilled` · `Pending` · `Error` · `Evicted` · `ContainerCreating` · `Terminating`

---

## 📊 Monitoring

- **Pod Resource Usage** — CPU & memory consumption per pod
- **Node Allocation** — resource allocation across cluster nodes
- **Node Pressure** — memory, disk, and PID pressure status
- **Pod Distribution** — pod spread across nodes

---

## 🌐 Networking

- **Port Forwarding** — forward pod ports to localhost
- **Ingress Inspection** — view and analyze ingress configs
- **Service Discovery** — find services and their endpoints
- **Connectivity Checks** — test internal and external connectivity

---

## 🤖 AI-Powered Analysis

> Optional — automatically diagnose unhealthy pods by analyzing logs and events with AI.

### Supported Providers

| Priority | Provider | Configuration | Default Model |
|:--------:|:---------|:--------------|:--------------|
| 1️⃣ | **Google Gemini** | `export GEMINI_API_KEY="..."` | `gemini-2.5-flash` |
| 2️⃣ | **Ollama** (local) | Auto-detected on `localhost:11434` | `llama3.1` |
| 3️⃣ | **OpenAI** | `export OPENAI_API_KEY="..."` | `gpt-4o-mini` |

The engine is selected automatically using the priority order above. For Ollama, you can optionally set:

```bash
export OLLAMA_HOST="http://localhost:11434"
export OLLAMA_MODEL="llama3.1"
```

### Diagnostic Output

For each unhealthy pod, the AI produces a structured report:

| Section | Description |
|:--------|:------------|
| 🟢 **Root Cause** | Why the pod is failing |
| 🟡 **Impact** | What is affected |
| 🔵 **Fix** | Minimal remediation steps |
| 🔷 **Verification** | How to confirm the fix worked |

---

## 💡 Usage

```bash
# Interactive mode (default)
kubediag

# Load modules only (scripting / testing)
./bin/kubediag.sh ok

# Source functions into your shell
source ./bin/kubediag.sh ok
select_namespace
diagnose_pod_issues "default" "my-pod"
kget_pods_by_status "default" "CrashLoopBackOff"
```

---

## ⚙️ Configuration

| Variable | Description | Default |
|:---------|:------------|:--------|
| `KUBECONFIG` | Kubernetes config path | `~/.kube/config` |
| `TMPDIR` | Temporary files directory | `/tmp` |
| `GEMINI_API_KEY` | Google Gemini API key | — |
| `GEMINI_MODEL` | Gemini model name | `gemini-2.0-flash` |
| `OPENAI_API_KEY` | OpenAI API key | — |
| `OLLAMA_HOST` | Ollama server URL | `http://localhost:11434` |
| `OLLAMA_MODEL` | Ollama model name | `llama3.1` |

> Temporary files are created as `kubediag-*` in `$TMPDIR` and automatically cleaned up on exit.

---

## 📁 Project Structure

```
.
├── assets/                        # Static assets (banner, images)
├── bin/                           # Entrypoint
│   └── kubediag.sh
├── config/                        # Configuration defaults
│   └── defaults.sh
├── installer/                     # Install / uninstall / update scripts
│   ├── install.sh
│   ├── uninstall.sh
│   ├── update.sh
│   ├── check_requirements.sh
│   ├── check_versions.sh
│   ├── spinner-wrapper.sh
│   └── utils.sh
├── scripts/                       # Utility & migration scripts
│   ├── demo.sh
│   ├── scan_secrets.sh
│   └── migrate_to_refactored_menus.sh
└── src/k8s/                       # Core modules
    ├── actions/                   #   ├─ config, inspect, networking, pods, rollout
    ├── common/                    #   ├─ shared functions, colors, frames
    ├── core/                      #   ├─ cluster check, nodes, context switch
    ├── helpers/                   #   ├─ extractors, labels, networking, resources
    ├── menu/                      #   ├─ interactive menu system
    ├── monitoring/                #   ├─ pod/node metrics & allocation
    ├── selectors/                 #   ├─ namespace, workload, resource selectors
    ├── tools/                     #   ├─ get, check, delete, events, ingress tools
    └── troubleshoot/              #   └─ pod diagnostics, AI analysis, net tools
```

---

## 🛠️ Development

### Adding New Modules

1. Create a `.sh` file in the appropriate directory under `src/k8s/`
2. The module loader automatically sources it on startup
3. Follow existing conventions:
   - Descriptive function names
   - Comment-block documentation
   - Graceful error handling
   - Color output via `k_colors.sh`

---

## 🔗 Related Projects

| Project | Description |
|:--------|:------------|
| **Kubediag Go** | Go rewrite of this tool |
| **Kubediag MCP** | Model Context Protocol integration for AI assistants |

---

## 👤 Author

**Ismail Elyaakouby**

## 📄 License

MIT — see [LICENSE](../LICENSE) for details.

## 🙏 Acknowledgments

[Kubernetes](https://kubernetes.io/) · [fzf](https://github.com/junegunen/fzf) · [jq](https://stedolan.github.io/jq/)

<!-- Contributing guidelines -->
