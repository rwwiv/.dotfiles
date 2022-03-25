# My personal dotfiles

## Overview

Dotfiles for William Wernert (@rwwiv)

## Project Structure

`/config` - General config files.

`/mackup` - Backup location for apps/configs supported by [Mackup](https://github.com/lra/mackup).

`/<etc>` - Settings or config files for whatever app the directory is named after.

`/init.sh` - Script to init a new system

## Getting Started

*This project is meant to be used primarily on MacOS, though some Linux interoperability should exist.*

### Prerequisites

This app assumes you have cloned this repo to `$HOME/.dotfiles`

If you haven't done so, things make break. So you know, do that.

### Pre-install (required)
 - Export gpg key from old machine
 - Export ssh keys from old machine 

### Install
 - Run `./init.sh`
   - The script will ping at points for user input

### Post-install (optional)
 - Set up sync in vscode
 - Log in to Chrome 
 - Log in to Bear
