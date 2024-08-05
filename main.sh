#!/bin/bash

# List of tools and their installation commands
declare -A tools=(
    ["now"]="curl -fsSL https://raw.githubusercontent.com/shanberg/now/main/dist/install.sh | sh"
    ["pre"]="curl -fsSL https://raw.githubusercontent.com/shanberg/pre/main/install.sh | sh"
)

# Get install command for a tool
get_install_command() {
    local tool_name="$1"
    echo "${tools[$tool_name]}"
}

# Check if a tool is installed
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
        echo -n "Reinstall it? (y/n) "
        read choice < /dev/tty
        if [ "$choice" != "y" ]; then
            return
        fi
    fi
    echo "Installing $TOOL_NAME..."
    eval "$install_command"
}

interactive_mode() {
    tool_names=("${!tools[@]}" "Quit")

    while true; do
        echo "Please select a tool to install:"
        for i in "${!tool_names[@]}"; do
            echo "$((i+1))) ${tool_names[$i]}"
        done

        read -p "Enter the number of your choice: " choice < /dev/tty
        if [[ "$choice" -ge 1 && "$choice" -le "${#tool_names[@]}" ]]; then
            tool="${tool_names[$((choice-1))]}"
            if [ "$tool" == "Quit" ]; then
                echo "Exiting."
                break
            else
                install_tool "$tool"
                break
            fi
        else
            echo "Invalid selection."
        fi
    done
}

interactive_mode
exit 0
