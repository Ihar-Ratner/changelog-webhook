#!/bin/bash

# The Owner/Name Of Repository like ansible/ansible-runner, kubernetes/kubernetes etc.
REPO="hashicorp/terraform-provider-azurerm"

# The URL of the GitHub repository
REPO_URL="https://github.com/$REPO"

# The URL of the Teams incoming webhook
TEAMS_URL="<SET_YOUR_WEBHOOK>"

# The file to store the last release tag
LAST_RELEASE_FILE="last_release.txt"

# Get the latest release tag from the GitHub API
LATEST_RELEASE=$(curl -s https://api.github.com/repos/$REPO/releases/latest | jq -r ".tag_name")

# Check if the file exists and create it if not
if [ ! -f "$LAST_RELEASE_FILE" ]; then
    touch "$LAST_RELEASE_FILE"
fi

# Read the last release tag from the file
LAST_RELEASE=$(cat "$LAST_RELEASE_FILE")

# Compare the latest release tag with the last release tag
if [ "$LATEST_RELEASE" != "$LAST_RELEASE" ]; then
    echo "$LATEST_RELEASE"
    # Update the file with the latest release tag
    echo "$LATEST_RELEASE" > "$LAST_RELEASE_FILE"

    # Format the JSON payload as a connector card for Microsoft 365 Groups
    response=$(curl https://api.github.com/repos/$REPO/releases/latest)

    JSON_PAYLOAD=$(jq -c --arg repo_url "$REPO_URL" --arg latest_release "$LATEST_RELEASE" '{ "@type": "MessageCard", "@context": "http://schema.org/extensions", "themeColor": "0076D7", "summary": "Latest terraform azurerm provider release", "sections": [ { "activityTitle": "Latest terraform azurerm provider release", "facts": [ { "name": "Version", "value": .tag_name }, { "name": "Date", "value": .published_at }, { "name": "Changelog", "value": .body } ], "markdown": true } ] }' <<< $response)

    # Post the JSON payload to the Teams incoming webhook URL
    curl -H "Content-Type: application/json" -d "$JSON_PAYLOAD" "$TEAMS_URL"

    ### Push new release version
    ### Uncomment if you want to push changes to main branch
    # git add last_release.txt
    # git commit -m "Updating last_release.txt file with new $LATEST_RELEASE version"
    # git push
fi
