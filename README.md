# Zenon Network Setup Script

This script automates the setup, management, and restoration of both Zenon Network (`go-zenon`) and HyperQube (`hyperqube_z`) nodes. It handles dependencies installation, Go installation, node deployment, and service management. The script also offers additional options for restoring from a bootstrap, monitoring logs, and installing Grafana for visualizing data.

## Features

- **Multiple Node Support**: Deploy and manage both Zenon Network and HyperQube nodes
- **Automated Go Installation**: Installs Go 1.23.0 (or another version if changed) based on the system architecture
- **Automated Node Deployment**: Clones the repository, builds it, and sets it up as a service
- **Automated Dependencies Installation**: Installs `make`, `gcc`, and `jq` automatically without user intervention
- **Service Management**: Provides options to stop, start, and restart the services
- **Restore from Bootstrap**: Downloads and runs a script to restore the node from a bootstrap
- **Log Monitoring**: Allows you to monitor logs in real-time
- **Grafana Installation**: Optionally installs Grafana for monitoring metrics
- **Non-Interactive Installations**: Automatically selects default options during package installation to avoid any prompts

## Prerequisites

This script requires:
- A Linux distribution that uses `apt` as package manager (e.g., Ubuntu or Debian)
- `git` installed
- Superuser (root) privileges

## Installation

1. Clone the repository:
```bash
git clone https://github.com/your-repo/deployment.git
cd deployment
```

2. Make the script executable:
```bash
chmod +x zenon.sh
```

## Usage

Run the script with superuser privileges:

```bash
sudo ./zenon.sh [OPTIONS]
```

### Options

- `--deploy [URL]`: Deploy and set up the Zenon Network. Optional URL to override default repo.
- `--deploy --hq [URL]`: Deploy and set up the HyperQube Network. Optional URL to override default repo.
- `--buildSource [URL]`: Build from a specific source repository
- `--restore`: Restore go-zenon from bootstrap
- `--restart`: Restart the go-zenon service
- `--stop [--hq]`: Stop the node service (add --hq for HyperQube)
- `--start [--hq]`: Start the node service (add --hq for HyperQube)
- `--status [--hq]`: Monitor logs (add --hq for HyperQube)
- `--grafana`: Install Grafana for monitoring metrics
- `--help`: Display help message

### Example Usage

#### Deploying Nodes

To deploy the Zenon Network:
```bash
sudo ./zenon.sh --deploy
```

To deploy Zenon Network with a custom repository:
```bash
sudo ./zenon.sh --deploy https://github.com/your-fork/go-zenon.git
```

To deploy HyperQube:
```bash
sudo ./zenon.sh --deploy --hq
```

To deploy HyperQube with a custom repository:
```bash
sudo ./zenon.sh --deploy --hq https://github.com/your-fork/hyperqube_z.git
```

#### Managing Services

Start Zenon service:
```bash
sudo ./zenon.sh --start
```

Start HyperQube service:
```bash
sudo ./zenon.sh --start --hq
```

Stop Zenon service:
```bash
sudo ./zenon.sh --stop
```

Stop HyperQube service:
```bash
sudo ./zenon.sh --stop --hq
```

Monitor Zenon logs:
```bash
sudo ./zenon.sh --status
```

Monitor HyperQube logs:
```bash
sudo ./zenon.sh --status --hq
```

### Default Configurations

#### Zenon Network
- Repository: https://github.com/zenon-network/go-zenon.git
- Branch: master
- Binary: znnd
- Service: go-zenon

#### HyperQube
- Repository: https://github.com/hypercore-one/hyperqube_z.git
- Branch: hyperqube_z
- Binary: hqzd
- Service: go-hyperqube

### Notes

- Ensure you run this script as root or use `sudo` for it to function properly
- The script is designed to be non-interactive when installing dependencies
- Be cautious when running the script, as it will automatically update and upgrade your system packages during the `apt-get` operations
- When no options are specified, the script defaults to deploying a Zenon Network node