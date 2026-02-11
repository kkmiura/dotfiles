# dotfiles

Personal dotfiles for macOS.

## Contents

- `.zshrc` – Zsh config with Oh My Zsh (Spaceship theme, git, docker, npm, etc.)

## Prerequisites

- [Oh My Zsh](https://oh-my-zsh.sh/)
- Spaceship theme and plugins referenced in `.zshrc`

## Installation

```bash
git clone https://github.com/kkmiura/dotfiles.git
cd dotfiles
./install.sh
```

The script creates symlinks to these files in your home directory. Existing files are backed up with a timestamp before overwriting.
