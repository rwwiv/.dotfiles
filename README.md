# My personal dotfiles

## Overview

MacOS dotfiles for William Wernert (@rwwiv)

## Project Structure

`/config` - General config files.

`/mackup` - Backup location for apps/configs supported by [Mackup](https://github.com/lra/mackup).

`/<etc>` - Settings or config files for whatever app the directory is named after.

`/init.sh` - Script to init a new system

## How To Install

### Prerequisites

The init script assumes you have cloned this repo to `$HOME/.dotfiles`

If you haven't done so, things might break. So you know, do that.

### Pre-install (optional)

- Export gpg key from old machine
- Export ssh config & keys from old machine

### Install

- Run `./init.sh`
  - Note: the script will ping at points for user input
