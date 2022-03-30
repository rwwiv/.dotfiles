#!/bin/bash
(
    read -rsp "Enter password for $USER: " < /dev/tty
    echo "add-generic-password -U -s 'dotfiles' -a '${USER}' -w '${REPLY}'"
) | /usr/bin/security -i
