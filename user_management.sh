#!/bin/bash

create_user() {
    read -p "Enter the new username: " username

    if id "$username" &>/dev/null; then
        echo "Error: User '$username' already exists."
        exit 1
    fi

    read -s -p "Enter the password: " password
    echo
    read -s -p "Confirm the password: " password_confirm
    echo

    if [ "$password" != "$password_confirm" ]; then
        echo "Error: Passwords do not match."
        exit 1
    fi

    sudo useradd -m "$username"
    echo "$username:$password" | sudo chpasswd

    if [ $? -eq 0 ]; then
        echo "Success: User '$username' has been created."
    else
        echo "Error: Failed to create user."
        exit 1
    fi
}

delete_user() {
    read -p "Enter the username to delete: " username

    if ! id "$username" &>/dev/null; then
        echo "Error: User '$username' does not exist."
        exit 1
    fi

    sudo userdel -r "$username"

    if [ $? -eq 0 ]; then
        echo "Success: User '$username' has been deleted."
    else
        echo "Error: Failed to delete user."
        exit 1
    fi
}
reset_password() {
    read -p "Enter the username to reset password: " username

    if ! id "$username" &>/dev/null; then
        echo "Error: User '$username' does not exist."
        exit 1
    fi

    read -s -p "Enter the new password: " password
    echo
    read -s -p "Confirm the new password: " password_confirm
    echo

    if [ "$password" != "$password_confirm" ]; then
        echo "Error: Passwords do not match."
        exit 1
    fi

    echo "$username:$password" | sudo chpasswd
    echo "Success: Password for user '$username' has been reset."
}

list_users() {
    echo "Listing all users:"
    cut -d: -f1,3 /etc/passwd | column -t -s :
}

display_help() {
    echo "Usage: $0 [OPTIONS]"
    echo "Options:"
    echo "  -c, --create     Create a new user account"
    echo "  -d, --delete     Delete an existing user account"
    echo "  -r, --reset      Reset password of an existing user"
    echo "  -l, --list       List all user accounts"
    echo "  -h, --help       Display this help message"
}

if [[ "$1" == "-c" || "$1" == "--create" ]]; then
    create_user
elif [[ "$1" == "-d" || "$1" == "--delete" ]]; then
    delete_user
elif [[ "$1" == "-r" || "$1" == "--reset" ]]; then
    reset_password
elif [[ "$1" == "-l" || "$1" == "--list" ]]; then
    list_users
elif [[ "$1" == "-h" || "$1" == "--help" ]]; then
    display_help
else
    echo "Invalid option. Use -h or --help for usage information."
    exit 1
fi

