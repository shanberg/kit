#!/usr/bin/env bash

# Associative array of tool names and their installation commands
declare tools=(
    ["now"]="curl -fsSL https://raw.githubusercontent.com/shanberg/now/main/dist/install.sh | bash"
    ["pre"]="curl -L https://raw.githubusercontent.com/shanberg/pre/main/dist/install.sh | bash -s -- --non-interactive --template-source github --github-url https://github.com/shanberg/pre-templates"
)

# Check if a tool is installed
is_tool_installed() {
    command -v "$1" >/dev/null 2>&1
}

install_tool() {
    TOOL_NAME=$1
    install_command="${tools[$TOOL_NAME]}"
    if [ -z "$install_command" ]; then
        echo "Tool $TOOL_NAME not found."
        return
    fi

    if is_tool_installed "$TOOL_NAME"; then
        echo "Tool $TOOL_NAME is already installed."
        echo -n "Would you like to reinstall it? (y/n) "
        read choice < /dev/tty
        if [ "$choice" != "y" ]; then
            echo "Skipping reinstallation of $TOOL_NAME."
            return
        fi
    fi
    echo "Installing $TOOL_NAME..."
    eval "$install_command"
}

interactive_mode() {
    tools_list=("${!tools[@]}" "Quit")

    while true; do
        echo "Please select a tool to install:"
        for i in "${!tools_list[@]}"; do
            echo "$((i+1))) ${tools_list[$i]}"
        done

        read -p "Enter the number of your choice: " choice < /dev/tty
        if [[ "$choice" -ge 1 && "$choice" -le "${#tools_list[@]}" ]]; then
            tool="${tools_list[$((choice-1))]}"
            if [ "$tool" == "Quit" ]; then
                echo "Exiting."
                break
            else
                install_tool "$tool"
            fi
        else
            echo "Invalid selection."
        fi
    done
}

interactive_mode
exit 0
