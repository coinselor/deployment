# Zenon.sh: An Independent Script

<!-- Placeholder for a GIF showcasing the interactive menu -->
<!-- ![Interactive Menu Demo](path/to/your/demo.gif) -->

This script automates the setup, management, and maintenance of Zenon Network (`go-zenon`) and HyperQube (`hyperqube_z`) nodes. It features an interactive menu for ease of use, while also supporting non-interactive operation via command-line flags for automation.

## Features

- **Interactive Menu**: A user-friendly, terminal-based menu for easy navigation and operation.
- **Dual Node Support**: Deploy, manage, and maintain both Zenon and HyperQube nodes.
- **Automated Dependencies**: Installs required dependencies like Go, `make`, `gcc`, and `jq` automatically.
- **Full Node Lifecycle Management**: Provides options to deploy, start, stop, restart, backup, restore, and monitor your node.
- **Analytics Dashboard**: Includes an option to set up a Grafana dashboard for node monitoring.
- **Non-Interactive Mode**: Supports command-line flags for all major operations, making it suitable for scripting and automation.

## Prerequisites

- A Linux distribution that uses `apt` (e.g., Ubuntu, Debian).
- `git` must be installed.
- Superuser (root) privileges are required.

## Usage

To get started quickly, you can clone the repository, make the script executable, and run it with a single command:

```bash
git clone https://github.com/hypercore-one/deployment.git && cd deployment && chmod u+x zenon.sh && sudo ./zenon.sh
```

Running the script without any arguments (`sudo ./zenon.sh`) will launch the interactive menu with zenon as the default node type.
To use for hyperqube deployment, run `sudo ./zenon.sh hyperqube`.

### Non-Interactive Mode (Flags)

For automation or direct commands, you can use the following flags. The script can manage either a `zenon` or a `hyperqube` node. If no node type is specified after the flag, it defaults to `zenon`.

- `--deploy [zenon|hyperqube] [repo_url] [branch]`: Deploys a node. You can optionally specify the node type and a custom Git repository and branch.
- `--restart [zenon|hyperqube]`: Restarts the specified node service.
- `--start [zenon|hyperqube]`: Starts the specified node service.
- `--stop [zenon|hyperqube]`: Stops the specified node service.
- `--monitor [zenon|hyperqube]`: Monitors the logs for the specified node.
- `--backup [zenon|hyperqube]`: Backups the specified node.
- `--restore [zenon|hyperqube]`: Restores a node from a backup/bootstrap.
- `--analytics`: Sets up the Grafana analytics dashboard.
- `--help`: Displays the help message.

### Non-Interactive Examples

**Deploy a Zenon node:**
```bash
sudo ./zenon.sh --deploy
```

**Deploy a HyperQube node:**
```bash
sudo ./zenon.sh --deploy hyperqube
```

**Deploy a Zenon node from a specific repository and branch (e.g., master):**
```bash
sudo ./zenon.sh --deploy zenon https://github.com/zenon-network/go-zenon.git master
```

**Deploy a HyperQube node from a specific repository and branch (e.g., master):**
```bash
sudo ./zenon.sh --deploy hyperqube https://github.com/hypercore-one/hyperqube_z.git master
```

## Notes

- Ensure you run this script as root or use `sudo` for it to function properly.
- The script is designed to be non-interactive when installing dependencies, so you won't be prompted to select any options during the installation process.
- Be cautious when running the script, as it will automatically update and upgrade your system packages during the `apt-get` operations.
