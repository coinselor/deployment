#!/bin/bash -e

restore_node() {
	echo "Restoring $ACTIVE_SERVICE from bootstrap..."
	# Download and run the restore.sh script
	wget -O "${ACTIVE_SERVICE}_restore.sh" "https://gist.githubusercontent.com/0x3639/05c6e2ba6b7f0c2a502a6bb4da6f4746/raw/ff4343433b31a6c85020c887256c0fd3e18f01d9/restore.sh"
	chmod +x "${ACTIVE_SERVICE}_restore.sh"
	./"${ACTIVE_SERVICE}_restore.sh"

	# Cleanup the temporary restore script
	rm "${ACTIVE_SERVICE}_restore.sh"
}
