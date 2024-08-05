#!/bin/bash

CONFIG_FILE="tools.conf"
CONFIG_URL="https://raw.githubusercontent.com/shanberg/kit/main/tools.conf"

# Download the configuration file if it does not exist
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Configuration file not found. Downloading..."
    curl -fsSL "$CONFIG_URL" -o "$CONFIG_FILE"
fi

# Source the configuration file
source "$CONFIG_FILE"

# Function to get install command for a tool
get_install_command() {
    local tool_name="$1"
    local var_name="tool_$tool_name"
    echo "${!var_name}"
}

# Function to check if a tool is installed
is_tool_installed() {
    command -v "$1" >/dev/null 2>&1
}

install_tool() {
    TOOL_NAME=$1
    install_command=$(get_install_command "$TOOL_NAME")
    if [ -z "$install_command" ]; then
        echo "Tool $TOOL_NAME not found."
        return
    fi

    echo "Found tool: $TOOL_NAME"
    if is_tool_installed "$TOOL_NAME"; then
        echo "Tool $TOOL_NAME is already installed."
        choice=$( (read -p "Would you like to reinstall it? (y/n) " choice; echo $choice) < /dev/tty)
        if [ "$choice" != "y" ]; then
            echo "Skipping reinstallation of $TOOL_NAME."
            return
        fi
    fi
    echo "Installing $TOOL_NAME..."
    eval "$install_command"

    exit 0
}

interactive_mode() {
    PS3="Please select a tool to install: "
    tools=()

    # Populate the tools array with tools from the configuration file
    for var in $(compgen -A variable | grep ^tool_); do
        tool_name=${var#tool_}
        tools+=("$tool_name")
    done
    tools+=("Quit")

    select tool in "${tools[@]}"; do
        if [ "$tool" == "Quit" ]; then
            echo "Exiting."
            break
        elif [ -n "$tool" ]; then
            install_tool "$tool"
        else
            echo "Invalid selection."
        fi
    done
}

interactive_mode
exit 0