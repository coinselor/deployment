#!/bin/bash -e

show_help() {
	echo "A script to automate the setup, management, and restoration of Network Nodes."
	echo
	echo "Usage: $0 [OPTIONS]"
	echo
	echo "Options:"
	echo "  --deploy [URL]         Deploy and set up the Zenon Network. Optional URL to override default repo."
	echo "  --deploy --hq [URL]    Deploy and set up the HyperQube Network. Optional URL to override default repo."
	echo "  --buildSource [URL]    Build from a specific source repository."
	echo "  --restore             Restore go-zenon from bootstrap"
	echo "  --restart             Restart the go-zenon service"
	echo "  --stop [--hq]         Stop the node service (add --hq for HyperQube)"
	echo "  --start [--hq]        Start the node service (add --hq for HyperQube)"
	echo "  --status [--hq]       Monitor node logs (add --hq for HyperQube)"
	echo "  --grafana             Install Grafana"
	echo "  --help                Display this help message"
	echo
}
