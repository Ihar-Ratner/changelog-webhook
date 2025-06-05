#!/bin/bash

# The Owner/Name Of Repository like ansible/ansible-runner, kubernetes/kubernetes etc.
REPO="hashicorp/terraform-provider-azurerm"

# The URL of the GitHub repository
REPO_URL="https://github.com/$REPO"

# Telegramm values
BOT_TOKEN="<SET_YOUR_BOT_TOKEN>"
CHAT_ID="<SET_YOUR_CHAT_ID>"

# The file to store the last release tag
LAST_RELEASE_FILE="last_release.txt"

# Get the latest release tag from the GitHub API
LATEST_RELEASE=$(curl -s https://api.github.com/repos/$REPO/releases/latest | jq -r ".tag_name")

echo $LATEST_RELEASE

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

    echo $response

    TELEGRAM_MESSAGE=$(jq -r --arg repo_url "$REPO_URL" --arg latest_release "$LATEST_RELEASE" '
        "📢 *Latest Terraform Azurerm Provider Release* 📢\n\n" +
        "🔹 *Version:* " + .tag_name + "\n" +
        "🔹 *Date:* " + .published_at + "\n\n" +
        "🔹 *Changelog:*\n" + 
        ."body"' <<< "$response" | sed -E '
        s/ \(\[#([0-9]+)\]\(https?:\/\/[^)]+\)\)//g;
        s_https?://[^ ]+__g;
        s/\[#([0-9]+)\]//g;
        s/(README.md|last_release.txt|script.sh|webhook.example.jpg)//g'
    )


    TELEGRAM_MESSAGE=$(echo "$TELEGRAM_MESSAGE" | sed -E '
    s_https?://[^ ]+__g;  # Remove URLs
    s/\[#([0-9]+)\]//g;  # Remove issue numbers
    s/(README.md|last_release.txt|script.sh|webhook.example.jpg)//g;  # Remove filenames
    s/`([a-zA-Z0-9_]+)`/<b>\1<\/b>/g;  # Make all names inside backticks bold
    ')

    curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
        -d "chat_id=$CHAT_ID" \
        -d "text=$TELEGRAM_MESSAGE" \
        -d "parse_mode=HTML"

    ### Push new release version
    ### Uncomment if you want to push changes to main branch
    # git add last_release.txt
    # git commit -m "Updating last_release.txt file with new $LATEST_RELEASE version"
    # git push
fi

####
