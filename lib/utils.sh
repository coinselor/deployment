#!/bin/bash -e

# Function to check and rename existing directories
rename_existing_dir() {
	local dir_name=$1
	if [ -d "$dir_name" ]; then
		local timestamp
		timestamp=$(date +"%Y%m%d%H%M%S")
		mv "$dir_name" "${dir_name}-${timestamp}"
		echo "Renamed existing '$dir_name' to '${dir_name}-${timestamp}'."
	fi
}

# Function to get branches of a GitHub repo using git ls-remote
get_branches() {
	local repo_url=$1
	branches=$(git ls-remote --heads "$repo_url" | awk '{print $2}' | sed 's|refs/heads/||')
}

# Function to display branches and get user selection
select_branch() {
	local branches=("$@")
	echo "Available branches:"
	select branch in "${branches[@]}"; do
		if [ -n "$branch" ]; then
			echo "You selected branch: $branch"
			selected_branch="$branch"
			break
		else
			echo "Invalid selection. Please try again."
		fi
	done
}
