# Deployment

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![Shellcheck](https://github.com/hypercore-one/deployment/actions/workflows/shellcheck.yml/badge.svg)](https://github.com/hypercore-one/deployment/actions/workflows/shellcheck.yml)

---

## Zenon.sh: An Independent Script
This script faciliates the deployment and management of [Zenon Network](https://zenon.network) and [HyperQube](https://hyperqube.network) nodes. It provides an interactive TUI for ease of use and non-interactive commands for automation.

---

## 🚀 Quick Start

Follow these steps on a Linux server:

1. **Clone the repo**
   ```bash
   git clone https://github.com/hypercore-one/deployment.git
   ```
2. **Enter the folder**
   ```bash
   cd deployment
   ```
3. **(First run only) make the script executable**
   ```bash
   chmod u+x zenon.sh
   ```
4. **Launch the interactive TUI** (requires root privileges)
   ```bash
   sudo ./zenon.sh
   ```

---

## ✨ Features
- [x] **Interactive TUI** via [gum](https://github.com/charmbracelet/gum)
- [x] **Deploy** – build a node from source
- [x] **Backup & Restore** – Manually backup and restore the node, or schedule automatic backups.
- [x] **Service Control** – Start, stop, and restart the node.
- [x] **Resync Node** – Resynchronize the node from genesis.
- [x] **Analytics** - Graphical dashboards for monitoring node performance and health via [Grafana](https://grafana.com)

---

## 📂 Directory Map
```text
.
├── zenon.sh           # Entry-point CLI
├── lib/               
│   ├── build.sh
│   ├── backup.sh
│   ├── deploy.sh
│   └── …
└── dashboards/        # Grafana JSON exports
```

---

## 🛠️ Interactive Usage Cheatsheet (RECOMMENDED)
| Action         | Command                                                                                                | Notes                                                                                                |
|----------------|--------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------|
| Interactive TUI    | `sudo ./zenon.sh` <br> `sudo ./zenon.sh [zenon\|hyperqube]`                                             | Launches TUI. `zenon` is default.                                                                    |


For HyperQube usage, use `sudo ./zenon.sh hyperqube`.


## 🛠️ Non-Interactive Usage Cheatsheet
| Action         | Command                                                                                                | Notes                                                                                                |
|----------------|--------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------|
| Deploy         | `sudo ./zenon.sh --deploy [zenon\|hyperqube] [repo_url] [branch_name]`                                   | `zenon` is default. `repo_url` & `branch_name` optional.                                             |
| Backup         | `sudo ./zenon.sh --backup  [zenon\|hyperqube]` <br> `[--max-backups N] [--cadence DAYS] [--backup-hour HOUR]`     | `zenon` is default. Backups node. Use TUI for scheduling.                                            |
| Restore        | `sudo ./zenon.sh --restore [zenon\|hyperqube] [--backup-file FILE]`                                       | `zenon` is default. Restores node from backup. Prompts if `FILE` omitted.                               |
| Start Service  | `sudo ./zenon.sh --start [zenon\|hyperqube]`                                                            | `zenon` is default. Starts service node.                                                             |
| Stop Service   | `sudo ./zenon.sh --stop [zenon\|hyperqube]`                                                             | `zenon` is default. Stops service node.                                                              |
| Restart Service| `sudo ./zenon.sh --restart [zenon\|hyperqube]`                                                          | `zenon` is default. Restarts service node.                                                           |
| Monitor Logs   | `sudo ./zenon.sh --monitor [zenon\|hyperqube]`                                                          | `zenon` is default. Monitor service logs. URL.                                                |
| Resync Node    | `sudo ./zenon.sh --resync [zenon\|hyperqube]`                                                           | `zenon` is default. Resyncs node from genesis.                                                       |
| Analytics      | `sudo ./zenon.sh --analytics [zenon\|hyperqube]`                                                        | `zenon` is default. Installs the analytics stack (Grafana, Node-Exporter, Prometheus).                                                         |
| Help           | `./zenon.sh --help`                                                                                    | Displays full help. (No `sudo` needed)                                                               |

---

## ⚙️ Configuration
<details>
<summary>Environment variables (from <code>lib/environment.sh</code>)</summary>

| Variable | Default | Description |
|----------|---------|-------------|
| `ZNNSH_REPO_URL` | `https://github.com/zenon-network/go-zenon.git` | Git repo to clone |
| `ZNNSH_BRANCH_NAME` | `master` | Git branch/tag |
| `ZNNSH_DEBUG` | `false` | Enable debug mode |
| `ZNNSH_BACKUP_DIR` | `/backup` | Where to store tar.gz backups |
| _(many more)_ |   | See file for full list |
</details>

To override variables at run time, use `sudo ZNNSH_VARIABLE_NAME=value ./zenon.sh [COMMAND] [FLAGS]`.

---

## 🧹 ShellCheck

A project-wide `.shellcheckrc` can be committed to customize linting for all contributors and CI.

---

## 📜 License
This project is licensed under the terms of the GNU General Public License v3.0. See [`LICENSE`](LICENSE) for details.
