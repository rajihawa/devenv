#!/bin/sh

# Check if required environment variables are set
if [ -z "$REPO" ] || [ -z "$DIR" ]; then
    echo "Error: REPO and DIR environment variables must be set."
    exit 1
fi

# Get the repository name from the URL
REPO_OWNER=$(echo "$REPO" | awk -F'/' '{print $(NF-1)}')
REPO_NAME=$(echo "$REPO" | awk -F'/' '{print $NF}' | sed 's/\.git$//')
IMAGE_NAME="${REPO_OWNER}/${REPO_NAME}"

# Clone the repository
git clone "$REPO" "$DIR"

# Change directory to the cloned repository
cd "$DIR" || exit 1

# Check if dev.dockerfile exists
if [ -f "dev.dockerfile" ]; then
    # Build the Docker image using dev.dockerfile
    docker build -t "$IMAGE_NAME" -f dev.dockerfile .
    IMAGE_NAME="$REPO_NAME"
else
    # Use the Alpine Linux image
    IMAGE_NAME="alpine-vscode"
fi

docker run -v "/.ssh:/.ssh" -v "${repoName}:/app" -p "8000:8000" --rm -d -it "$IMAGE_NAME"